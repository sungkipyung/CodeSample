//
//  Camera.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 11..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit
import AVFoundation

enum CameraManualSetupResult: Int {
    case success, cameraNotAuthorized, sessionConfigurationFailed
}
/**
 mapping
 
 public enum AVCaptureVideoOrientation : Int {
 
 case Portrait
 case PortraitUpsideDown
 case LandscapeRight
 case LandscapeLeft
 }
 
 public enum UIInterfaceOrientation : Int {
 
 case Unknown
 case Portrait
 case PortraitUpsideDown
 case LandscapeLeft
 case LandscapeRight
 }
 */
extension UIInterfaceOrientation {
    func toAVCaptureVideoOrientation() -> (AVCaptureVideoOrientation) {
        switch self {
        case .portrait:
            return AVCaptureVideoOrientation.portrait
        case .landscapeLeft:
            // TODO: Check left Right Conversion
            return AVCaptureVideoOrientation.landscapeRight
        case .landscapeRight:
            // TODO: Check left Right Conversion
            return AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            return AVCaptureVideoOrientation.portraitUpsideDown
        default:
            return AVCaptureVideoOrientation.portrait
        }
    }
}

typealias CameraSetupComplete = ((_ result:CameraManualSetupResult) -> (Void))
typealias CameraTakePictureComplete = ((_ imageData:Data?) -> (Void))

private var SessionRunningContext = 0
private var CapturingStillImageContext = 0
private var FocusModeContext = 0
private var LensPositionContext = 0
private var ExposureModeContext = 0
private var ExposureDurationContext = 0
private var ISOContext = 0
private var ExposureTargetOffsetContext = 0
private var WhiteBalanceModeContext = 0
private var DeviceWhiteBalanceGainsContext = 0
private var LensStabilizationContext = 0

class Camera: NSObject {
    // MARK: properties
    internal var session: AVCaptureSession = AVCaptureSession.init()
    fileprivate var sessionQueue: DispatchQueue = DispatchQueue(label: "com.campmobile.band.Camera", attributes: [])
    fileprivate var videoDevice: AVCaptureDevice!
    fileprivate var videoDeviceInput: AVCaptureDeviceInput!
    fileprivate var stillImageOutput: AVCaptureStillImageOutput!
    fileprivate var movieFileOutput: AVCaptureMovieFileOutput!
    
    fileprivate var videoOutput: AVCaptureVideoDataOutput!
    
    // MARK: Utilities
    internal var setupResult:CameraManualSetupResult = CameraManualSetupResult.cameraNotAuthorized
    internal fileprivate(set) var sessionRunning:Bool = false
    fileprivate var backgroundRecordingID:UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    internal func setupWithPreview(_ preview:CameraPreview, complete:@escaping CameraSetupComplete) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        self.setupResult = CameraManualSetupResult.success;
        preview.session = self.session
        
        switch (authorizationStatus) {
        case.authorized:
            // The user has previously granted access to the camera.
            break;
        case .notDetermined:
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            self.sessionQueue.suspend();
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted:Bool) in
                if (!granted) {
                    self.setupResult = CameraManualSetupResult.cameraNotAuthorized;
                }
                self.sessionQueue.resume();
            })
            break;
        default:
            // The user has previously denied access.
            self.setupResult = CameraManualSetupResult.cameraNotAuthorized;
            break;
        }
        
        setupCaptureSession(preview, complete: complete)
    }
    
    internal func turnOn(_ complete:@escaping CameraSetupComplete) {
        self.sessionQueue.async {
            if (self.setupResult == .success) {
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.sessionRunning = self.session.isRunning
            }
            DispatchQueue.main.async {
                complete(self.setupResult)
            };
        }
    }
    
    internal func turnOff(_ complete: @escaping (Void) -> (Void)) {
        self.sessionQueue.async { 
            if (self.setupResult == .success) {
                self.session.stopRunning()
                self.removeObservers();
            }
            DispatchQueue.main.async {
                complete()
            };
        }
    }
    
    internal func takePicture(_ complete:@escaping CameraTakePictureComplete, withPreview preview:CameraPreview) {
        self.sessionQueue.async {
            let stillImageConnection = self.stillImageOutput.connection(withMediaType: AVMediaTypeVideo)
            let previewLayer = preview.layer as! AVCaptureVideoPreviewLayer
            
            // Update the orientation on the still image output video connection before capturing.
            stillImageConnection?.videoOrientation = previewLayer.connection.videoOrientation
            
            // Flash set to Auto for Still Capture
            if (self.videoDevice.exposureMode == AVCaptureExposureMode.custom ) {
                Camera.setFlashMode(AVCaptureFlashMode.off, forDevice: self.videoDevice)
            }
            else {
                Camera.setFlashMode(AVCaptureFlashMode.auto, forDevice: self.videoDevice)
            }
            
            if #available(iOS 9.0, *) {
                if (true == self.stillImageOutput.isLensStabilizationDuringBracketedCaptureEnabled) {
                    return ;
                }
            }
            
            var soundId: SystemSoundID = 0
            if (soundId == 0) {
                let url = Bundle.main.url(forResource: "photoShutter2", withExtension: "caf")
                AudioServicesCreateSystemSoundID(url as! CFURL, &soundId)
            }
            AudioServicesPlaySystemSound(soundId)
            
//            // Capture a still image
            self.stillImageOutput.captureStillImageAsynchronously(from: stillImageConnection, completionHandler: { (imageDataSampleBuffer, error) in
                if (error != nil) {
                    NSLog("Error capture still image \(error)")
                    return
                }
                
                if (imageDataSampleBuffer != nil) {
                    let imageData:Data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    complete(imageData)
                    return
                }
                
                complete(nil)
            })
        }
        
    }
    
    internal func toggleCamera(_ complete: @escaping (_ error:NSError?) -> (Void)) {
        self.sessionQueue.async {
            
            var preferredPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.unspecified
            
            switch (self.videoDevice.position) {
            case .unspecified:
                preferredPosition = AVCaptureDevicePosition.back;
            case .front:
                preferredPosition = AVCaptureDevicePosition.back;
                break;
            case .back:
                preferredPosition = AVCaptureDevicePosition.front;
                break;
            }
            
            do {
                let newVideoDevice = Camera.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition)
                let newVideoDeviceInput = try AVCaptureDeviceInput.init(device: newVideoDevice)
                
                self.session.beginConfiguration()
                self.session .removeInput(self.videoDeviceInput)
                
                if (self.session.canAddInput(newVideoDeviceInput)) {
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: self.videoDevice)
                    NotificationCenter.default.addObserver(self, selector:#selector(self.subjectAreaDidChange), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: newVideoDevice)
                    
                    self.session.addInput(newVideoDeviceInput)
                    self.videoDeviceInput = newVideoDeviceInput
                    self.videoDevice = newVideoDevice
                } else {
                    self.session.addInput(self.videoDeviceInput)
                }
                
                let connection: AVCaptureConnection = self.movieFileOutput.connection(withMediaType: AVMediaTypeVideo)
                
                if (connection.isVideoStabilizationSupported) {
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                }
                
                self.session .commitConfiguration()
                
                DispatchQueue.main.async(execute: {
                    complete(nil)
                })
            } catch let error as NSError {
                DispatchQueue.main.async(execute: {
                    complete(error)
                })
            }
        }
    }
    
    // MARK: KVO
    
    fileprivate func addObservers() {
        self.session.addObserver(self, forKeyPath:"running", options: NSKeyValueObservingOptions.new, context: &SessionRunningContext)
        self.stillImageOutput.addObserver(self, forKeyPath:"capturingStillImage", options: NSKeyValueObservingOptions.new, context: &CapturingStillImageContext)
        self.videoDevice.addObserver(self, forKeyPath:"focusMode", options: NSKeyValueObservingOptions.old.union(NSKeyValueObservingOptions.new), context: &FocusModeContext)
        self.videoDevice.addObserver(self, forKeyPath:"lensPosition", options: NSKeyValueObservingOptions.new, context: &LensPositionContext)
        self.videoDevice.addObserver(self, forKeyPath:"exposureMode", options: NSKeyValueObservingOptions.old.union(NSKeyValueObservingOptions.new), context: &ExposureModeContext)
        self.videoDevice.addObserver(self, forKeyPath:"exposureDuration", options: NSKeyValueObservingOptions.new, context: &ExposureDurationContext)
        self.videoDevice.addObserver(self, forKeyPath:"ISO", options: NSKeyValueObservingOptions.new, context: &ISOContext)
        self.videoDevice.addObserver(self, forKeyPath:"exposureTargetOffset", options: NSKeyValueObservingOptions.new, context: &ExposureTargetOffsetContext)
        self.videoDevice.addObserver(self, forKeyPath:"whiteBalanceMode", options: NSKeyValueObservingOptions.old.union(NSKeyValueObservingOptions.new), context: &WhiteBalanceModeContext)
        self.videoDevice.addObserver(self, forKeyPath:"deviceWhiteBalanceGains", options: NSKeyValueObservingOptions.new, context: &DeviceWhiteBalanceGainsContext)
        self.stillImageOutput.addObserver(self, forKeyPath:"lensStabilizationDuringBracketedCaptureEnabled", options: NSKeyValueObservingOptions.old.union(NSKeyValueObservingOptions.new), context: &LensStabilizationContext)
        
        NotificationCenter.default.addObserver(self, selector:#selector(subjectAreaDidChange), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: self.videoDevice)
        NotificationCenter.default.addObserver(self, selector:#selector(sessionRuntimeError), name: NSNotification.Name.AVCaptureSessionRuntimeError, object: self.session)
        
        // A session can only run when the app is full screen. It will be interrupted in a multi-app layout, introduced in iOS 9,
        // see also the documentation of AVCaptureSessionInterruptionReason. Add observers to handle these session interruptions
        // and show a preview is paused message. See the documentation of AVCaptureSessionWasInterruptedNotification for other
        // interruption reasons.
        NotificationCenter.default.addObserver(self, selector:#selector(sessionWasInterrupted), name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: self.session)
        NotificationCenter.default.addObserver(self, selector:#selector(sessionInterruptionEnded), name: NSNotification.Name.AVCaptureSessionInterruptionEnded, object: self.session)
    }
    
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        self.session.removeObserver(self, forKeyPath:"running", context:&SessionRunningContext)
        self.stillImageOutput.removeObserver(self, forKeyPath:"capturingStillImage", context:&CapturingStillImageContext)
        
        self.videoDevice.removeObserver(self, forKeyPath:"focusMode", context:&FocusModeContext)
        self.videoDevice.removeObserver(self, forKeyPath:"lensPosition", context:&LensPositionContext)
        self.videoDevice.removeObserver(self, forKeyPath:"exposureMode", context:&ExposureModeContext)
        self.videoDevice.removeObserver(self, forKeyPath:"exposureDuration", context:&ExposureDurationContext)
        self.videoDevice.removeObserver(self, forKeyPath:"ISO", context:&ISOContext)
        self.videoDevice.removeObserver(self, forKeyPath:"exposureTargetOffset", context:&ExposureTargetOffsetContext)
        self.videoDevice.removeObserver(self, forKeyPath:"whiteBalanceMode", context:&WhiteBalanceModeContext)
        self.videoDevice.removeObserver(self, forKeyPath:"deviceWhiteBalanceGains", context:&DeviceWhiteBalanceGainsContext)
        
        self.stillImageOutput.removeObserver(self, forKeyPath:"lensStabilizationDuringBracketedCaptureEnabled", context:&LensStabilizationContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        var oldValue:AnyObject? = change?[NSKeyValueChangeOldKey] is NSNull ? nil : change?[NSKeyValueChangeOldKey]
//        var newValue:AnyObject? = change?[NSKeyValueChangeNewKey] is NSNull ? nil : change?[NSKeyValueChangeNewKey]
//        
        // TODO: Handle changed camera option values
    }
    
    @objc func subjectAreaDidChange(_ notification: Notification) {
    }
    
    @objc func sessionRuntimeError(_ notification: Notification) {
        if let error: NSError = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError {
            NSLog("Capture Session runtime error \(error)")
            
            if (error.code == AVError.Code.mediaServicesWereReset.rawValue) {
                self.sessionQueue.async {
                    // If we aren't trying to resume the session running, then try to restart it since it must have been stopped due to an error. See also -[resumeInterruptedSession:].
                    if (self.sessionRunning) {
                        self.session.startRunning()
                        self.sessionRunning = self.session.isRunning
                    } else {
                        // TODO : Have to restart Session
                    }
                };
            } else {
                // TODO : Have to restart Session
            }
        }
    }
    
    @objc func sessionWasInterrupted(_ notification: Notification) {
        // In some scenarios we want to enable the user to resume the session running.
        // For example, if music playback is initiated via control center while using AVCamManual,
        // then the user can let AVCamManual resume the session running, which will stop music playback.
        // Note that stopping music playback in control center will not automatically resume the session running.
        // Also note that it is not always possible to resume, see -[resumeInterruptedSession:].
        
        // In iOS 9 and later, the userInfo dictionary contains information on why the session was interrupted.
        if #available(iOS 9.0, *) {
            guard let anyObj = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] else { return }
            
            if let number = anyObj as? NSNumber {
                let reason:AVCaptureSessionInterruptionReason = AVCaptureSessionInterruptionReason.init(rawValue: number.intValue)!
                switch reason {
                case .audioDeviceInUseByAnotherClient:
                    break
                case .videoDeviceInUseByAnotherClient:
                    break
                default:
                    break
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func sessionInterruptionEnded(_ notification: Notification) {
    }
    // MARK: KVO END
    
    // Setup the capture session.
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
    // so that the main queue isn't blocked, which keeps the UI responsive.
    fileprivate func setupCaptureSession(_ preview:CameraPreview, complete:@escaping CameraSetupComplete) {
        self.sessionQueue.async {
            
            
            if ( self.setupResult != CameraManualSetupResult.success ) {
                
                DispatchQueue.main.async {
                    complete(self.setupResult)
                }
                return;
            }
        
            self.backgroundRecordingID = UIBackgroundTaskInvalid
            
    //        var error:NSError? = nil

            do {
                // create and add VideoDeviceInput
                self.session.beginConfiguration()
                self.session.sessionPreset = AVCaptureSessionPresetInputPriority
                self.videoOutput = AVCaptureVideoDataOutput()
                
                let videoDevice = Camera.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.back)
                let videoDeviceInput: AVCaptureDeviceInput = try AVCaptureDeviceInput.init(device: videoDevice)
                
                if (self.session.canAddInput(videoDeviceInput)) {
                    self.session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                    self.videoDevice = videoDevice
                    try self.videoDevice.lockForConfiguration()
                    self.videoDevice.videoZoomFactor = 1.0
                    self.videoDevice.unlockForConfiguration()
                    
                    DispatchQueue.main.async {
                        // Why are we dispatching this to the main queue?
                        // Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
                        // can only be manipulated on the main thread.
                        // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                        // on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                        
                        // Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
                        // -[viewWillTransitionToSize:withTransitionCoordinator:].
                        let statusBarOrientation:UIInterfaceOrientation = UIApplication.shared.statusBarOrientation;
                        
                        if let previewLayer:AVCaptureVideoPreviewLayer = preview.layer as? AVCaptureVideoPreviewLayer {
                            previewLayer.connection.videoOrientation = statusBarOrientation.toAVCaptureVideoOrientation();
                        }
                    }
                }
                
                if self.session.canAddOutput(self.videoOutput) {
                   self.session.addOutput(self.videoOutput)
                    self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
                }
                
                let audioDevice:AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
                let audioDeviceInput:AVCaptureDeviceInput = try AVCaptureDeviceInput.init(device: audioDevice)
                
                if (self.session.canAddInput(audioDeviceInput)) {
                    self.session.addInput(audioDeviceInput)
                }
                
//                let movieFileOutput:AVCaptureMovieFileOutput = AVCaptureMovieFileOutput.init()
//                if (self.session.canAddOutput(movieFileOutput)) {
//                    self.session.addOutput(movieFileOutput)
//                    
//                    let connection:AVCaptureConnection  = movieFileOutput.connection(withMediaType: AVMediaTypeVideo);
//                    
//                    if (connection.isVideoStabilizationSupported) {
//                        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto;
//                    }
//                    self.movieFileOutput = movieFileOutput;
//                }
                
                
                let stillImageOutput:AVCaptureStillImageOutput = AVCaptureStillImageOutput.init()
                if (self.session.canAddOutput(stillImageOutput)) {
                    self.session.addOutput(stillImageOutput)
                    
                    stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                    stillImageOutput.isHighResolutionStillImageOutputEnabled = true
                    
                    self.stillImageOutput = stillImageOutput
                }
                
                self.session.commitConfiguration()
                
                DispatchQueue.main.async {
                    complete(self.setupResult)
                }
            } catch let error as NSError {
                NSLog("Could not create device input: %@", error)
                self.setupResult = CameraManualSetupResult.sessionConfigurationFailed
            }
        };
    }
    
    fileprivate func resumeInterruptedSession() {
        
    }
    
    static func deviceWithMediaType(_ mediaType:String, preferringPosition position:(AVCaptureDevicePosition)) -> AVCaptureDevice? {
        if let devices:Array<AVCaptureDevice> = AVCaptureDevice.devices(withMediaType: mediaType) as? Array<AVCaptureDevice> {
            var captureDevice = devices.first
            
            for device in devices {
                if (device.position == position) {
                    captureDevice = device
                    break
                }
            }
            var bestFormat: AVCaptureDeviceFormat?
//            var bestFrameRateRange: AVFrameRateRange?
            var maxResolution:Int32  = 0
            let formats = captureDevice?.formats as! [AVCaptureDeviceFormat]
            formats.forEach({ (format) in
                
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                let value = dimensions.width * dimensions.height
                if maxResolution < value {
                    bestFormat = format
                    maxResolution = value
                }
            })
            
            
            if let format = bestFormat {
                try? captureDevice?.lockForConfiguration()
                captureDevice?.activeFormat = format
                captureDevice?.unlockForConfiguration()
            }
            
            return captureDevice
        }
        return nil;
    }
    
    static func setFlashMode(_ flashMode:AVCaptureFlashMode, forDevice device:AVCaptureDevice) {
        if (device.hasFlash && device.isFlashModeSupported(flashMode)) {
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.unlockForConfiguration()
            } catch let error as NSError {
                NSLog("Could not lock device for configuration \(error)")
            }
        }
    }
    
    static func setScaleFactor(_ scaleFactor:CGFloat, forDevice device:AVCaptureDevice) {
    }
}

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let bufferWidth = CVPixelBufferGetWidth(cameraFrame);
        let bufferHeight = CVPixelBufferGetHeight(cameraFrame);
        print("sample Buffer size : \(CGSize(width: bufferWidth, height: bufferHeight))")
    }
}

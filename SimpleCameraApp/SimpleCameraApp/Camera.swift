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
    case Success, CameraNotAuthorized, SessionConfigurationFailed
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
        case .Portrait:
            return AVCaptureVideoOrientation.Portrait
        case .LandscapeLeft:
            // TODO: Check left Right Conversion
            return AVCaptureVideoOrientation.LandscapeRight
        case .LandscapeRight:
            // TODO: Check left Right Conversion
            return AVCaptureVideoOrientation.LandscapeLeft
        case .PortraitUpsideDown:
            return AVCaptureVideoOrientation.PortraitUpsideDown
        default:
            return AVCaptureVideoOrientation.Portrait
        }
    }
}

typealias CameraSetupComplete = ((result:CameraManualSetupResult) -> (Void))
typealias CameraTakePictureComplete = ((imageData:NSData?) -> (Void))

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
    private var sessionQueue: dispatch_queue_t = dispatch_queue_create("com.campmobile.band.Camera", DISPATCH_QUEUE_SERIAL)
    private var videoDevice:AVCaptureDevice!
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var stillImageOutput:AVCaptureStillImageOutput!
    private var movieFileOutput:AVCaptureMovieFileOutput!
    
    // MARK: Utilities
    internal var setupResult:CameraManualSetupResult = CameraManualSetupResult.CameraNotAuthorized
    internal private(set) var sessionRunning:Bool = false
    private var backgroundRecordingID:UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    internal func setupWithPreview(preview:CameraPreview, complete:CameraSetupComplete) {
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        self.setupResult = CameraManualSetupResult.Success;
        preview.session = self.session
        
        switch (authorizationStatus) {
        case.Authorized:
            // The user has previously granted access to the camera.
            break;
        case .NotDetermined:
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            dispatch_suspend( self.sessionQueue );
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted:Bool) in
                if (!granted) {
                    self.setupResult = CameraManualSetupResult.CameraNotAuthorized;
                }
                dispatch_resume( self.sessionQueue );
            })
            break;
        default:
            // The user has previously denied access.
            self.setupResult = CameraManualSetupResult.CameraNotAuthorized;
            break;
        }
        
        setupCaptureSession(preview, complete: complete)
    }
    
    internal func turnOn(complete:CameraSetupComplete) {
        dispatch_async(self.sessionQueue) {
            if (self.setupResult == .Success) {
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.sessionRunning = self.session.running
            }
            dispatch_async(dispatch_get_main_queue()) {
                complete(result:self.setupResult)
            };
        }
    }
    
    internal func turnOff(complete: (Void) -> (Void)) {
        dispatch_async(self.sessionQueue) { 
            if (self.setupResult == .Success) {
                self.session.stopRunning()
                self.removeObservers();
            }
            dispatch_async(dispatch_get_main_queue()) {
                complete()
            };
        }
    }
    
    internal func takePicture(complete:CameraTakePictureComplete, withPreview preview:CameraPreview) {
        dispatch_async(self.sessionQueue) {
            let stillImageConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
            let previewLayer = preview.layer as! AVCaptureVideoPreviewLayer
            
            // Update the orientation on the still image output video connection before capturing.
            stillImageConnection.videoOrientation = previewLayer.connection.videoOrientation
            
            // Flash set to Auto for Still Capture
            if (self.videoDevice.exposureMode == AVCaptureExposureMode.Custom ) {
                Camera.setFlashMode(AVCaptureFlashMode.Off, forDevice: self.videoDevice)
            }
            else {
                Camera.setFlashMode(AVCaptureFlashMode.Auto, forDevice: self.videoDevice)
            }
            
            if #available(iOS 9.0, *) {
                if (true == self.stillImageOutput.lensStabilizationDuringBracketedCaptureEnabled) {
                    return ;
                }
            }
            
            // Capture a still image
            self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo), completionHandler: { (imageDataSampleBuffer:CMSampleBuffer?, error:NSError?) in
                if (error != nil) {
                    NSLog("Error capture still image \(error)")
                    return
                }
                
                if (imageDataSampleBuffer != nil) {
                    let imageData:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    complete(imageData: imageData)
                    return
                }
                
                complete(imageData: nil)
            })
        }
        
    }
    
    internal func toggleCamera(complete: (error:NSError?) -> (Void)) {
        dispatch_async(self.sessionQueue) {
            
            var preferredPosition: AVCaptureDevicePosition = AVCaptureDevicePosition.Unspecified
            
            switch (self.videoDevice.position) {
            case .Unspecified:
                preferredPosition = AVCaptureDevicePosition.Back;
            case .Front:
                preferredPosition = AVCaptureDevicePosition.Back;
                break;
            case .Back:
                preferredPosition = AVCaptureDevicePosition.Front;
                break;
            }
            
            do {
                let newVideoDevice = Camera.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition)
                let newVideoDeviceInput = try AVCaptureDeviceInput.init(device: newVideoDevice)
                
                self.session.beginConfiguration()
                self.session .removeInput(self.videoDeviceInput)
                
                if (self.session.canAddInput(newVideoDeviceInput)) {
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDevice)
                    NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(self.subjectAreaDidChange), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: newVideoDevice)
                    
                    self.session.addInput(newVideoDeviceInput)
                    self.videoDeviceInput = newVideoDeviceInput
                    self.videoDevice = newVideoDevice
                } else {
                    self.session.addInput(self.videoDeviceInput)
                }
                
                let connection: AVCaptureConnection = self.movieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
                
                if (connection.supportsVideoStabilization) {
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Auto
                }
                
                self.session .commitConfiguration()
                
                dispatch_async(dispatch_get_main_queue(), {
                    complete(error: nil)
                })
            } catch let error as NSError {
                dispatch_async(dispatch_get_main_queue(), {
                    complete(error:error)
                })
            }
        }
    }
    
    // MARK: KVO
    
    private func addObservers() {
        self.session.addObserver(self, forKeyPath:"running", options: NSKeyValueObservingOptions.New, context: &SessionRunningContext)
        self.stillImageOutput.addObserver(self, forKeyPath:"capturingStillImage", options: NSKeyValueObservingOptions.New, context: &CapturingStillImageContext)
        self.videoDevice.addObserver(self, forKeyPath:"focusMode", options: NSKeyValueObservingOptions.Old.union(NSKeyValueObservingOptions.New), context: &FocusModeContext)
        self.videoDevice.addObserver(self, forKeyPath:"lensPosition", options: NSKeyValueObservingOptions.New, context: &LensPositionContext)
        self.videoDevice.addObserver(self, forKeyPath:"exposureMode", options: NSKeyValueObservingOptions.Old.union(NSKeyValueObservingOptions.New), context: &ExposureModeContext)
        self.videoDevice.addObserver(self, forKeyPath:"exposureDuration", options: NSKeyValueObservingOptions.New, context: &ExposureDurationContext)
        self.videoDevice.addObserver(self, forKeyPath:"ISO", options: NSKeyValueObservingOptions.New, context: &ISOContext)
        self.videoDevice.addObserver(self, forKeyPath:"exposureTargetOffset", options: NSKeyValueObservingOptions.New, context: &ExposureTargetOffsetContext)
        self.videoDevice.addObserver(self, forKeyPath:"whiteBalanceMode", options: NSKeyValueObservingOptions.Old.union(NSKeyValueObservingOptions.New), context: &WhiteBalanceModeContext)
        self.videoDevice.addObserver(self, forKeyPath:"deviceWhiteBalanceGains", options: NSKeyValueObservingOptions.New, context: &DeviceWhiteBalanceGainsContext)
        self.stillImageOutput.addObserver(self, forKeyPath:"lensStabilizationDuringBracketedCaptureEnabled", options: NSKeyValueObservingOptions.Old.union(NSKeyValueObservingOptions.New), context: &LensStabilizationContext)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(subjectAreaDidChange), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDevice)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(sessionRuntimeError), name: AVCaptureSessionRuntimeErrorNotification, object: self.session)
        
        // A session can only run when the app is full screen. It will be interrupted in a multi-app layout, introduced in iOS 9,
        // see also the documentation of AVCaptureSessionInterruptionReason. Add observers to handle these session interruptions
        // and show a preview is paused message. See the documentation of AVCaptureSessionWasInterruptedNotification for other
        // interruption reasons.
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(sessionWasInterrupted), name: AVCaptureSessionWasInterruptedNotification, object: self.session)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(sessionInterruptionEnded), name: AVCaptureSessionInterruptionEndedNotification, object: self.session)
    }
    
    private func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        var oldValue:AnyObject? = change?[NSKeyValueChangeOldKey] is NSNull ? nil : change?[NSKeyValueChangeOldKey]
//        var newValue:AnyObject? = change?[NSKeyValueChangeNewKey] is NSNull ? nil : change?[NSKeyValueChangeNewKey]
//        
        // TODO: Handle changed camera option values
    }
    
    @objc func subjectAreaDidChange(notification: NSNotification) {
    }
    
    @objc func sessionRuntimeError(notification: NSNotification) {
        if let error: NSError = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError {
            NSLog("Capture Session runtime error \(error)")
            
            if (error.code == AVError.MediaServicesWereReset.rawValue) {
                dispatch_async(self.sessionQueue) {
                    // If we aren't trying to resume the session running, then try to restart it since it must have been stopped due to an error. See also -[resumeInterruptedSession:].
                    if (self.sessionRunning) {
                        self.session.startRunning()
                        self.sessionRunning = self.session.running
                    } else {
                        // TODO : Have to restart Session
                    }
                };
            } else {
                // TODO : Have to restart Session
            }
        }
    }
    
    @objc func sessionWasInterrupted(notification: NSNotification) {
        // In some scenarios we want to enable the user to resume the session running.
        // For example, if music playback is initiated via control center while using AVCamManual,
        // then the user can let AVCamManual resume the session running, which will stop music playback.
        // Note that stopping music playback in control center will not automatically resume the session running.
        // Also note that it is not always possible to resume, see -[resumeInterruptedSession:].
        
        // In iOS 9 and later, the userInfo dictionary contains information on why the session was interrupted.
        if #available(iOS 9.0, *) {
            let anyObj:AnyObject? = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] is NSNull ? nil : notification.userInfo?[AVCaptureSessionInterruptionReasonKey]
            if let number = anyObj as? NSNumber {
                let reason:AVCaptureSessionInterruptionReason = AVCaptureSessionInterruptionReason.init(rawValue: number.integerValue)!
                switch reason {
                case .AudioDeviceInUseByAnotherClient:
                    break
                case .VideoDeviceInUseByAnotherClient:
                    break
                default:
                    break
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func sessionInterruptionEnded(notification: NSNotification) {
    }
    // MARK: KVO END
    
    // Setup the capture session.
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
    // so that the main queue isn't blocked, which keeps the UI responsive.
    private func setupCaptureSession(preview:CameraPreview, complete:CameraSetupComplete) {
        dispatch_async(self.sessionQueue) {
            if ( self.setupResult != CameraManualSetupResult.Success ) {
                
                dispatch_async(dispatch_get_main_queue()) {
                    complete(result:self.setupResult)
                }
                return;
            }
        
            self.backgroundRecordingID = UIBackgroundTaskInvalid
            
    //        var error:NSError? = nil

            do {
                // create and add VideoDeviceInput
                self.session.beginConfiguration()
                self.session.sessionPreset = AVCaptureSessionPresetPhoto
                let videoDevice = Camera.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Back)
                let videoDeviceInput: AVCaptureDeviceInput = try AVCaptureDeviceInput.init(device: videoDevice)
                
                
                if (self.session.canAddInput(videoDeviceInput)) {
                    self.session .addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                    self.videoDevice = videoDevice
                    try self.videoDevice.lockForConfiguration()
                    self.videoDevice.videoZoomFactor = 1.0
                    self.videoDevice.unlockForConfiguration()
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        // Why are we dispatching this to the main queue?
                        // Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
                        // can only be manipulated on the main thread.
                        // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                        // on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                        
                        // Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
                        // -[viewWillTransitionToSize:withTransitionCoordinator:].
                        let statusBarOrientation:UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation;
                        
                        if let previewLayer:AVCaptureVideoPreviewLayer = preview.layer as? AVCaptureVideoPreviewLayer {
                            previewLayer.connection.videoOrientation = statusBarOrientation.toAVCaptureVideoOrientation();
                        }
                    }
                }
                
                let audioDevice:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
                let audioDeviceInput:AVCaptureDeviceInput = try AVCaptureDeviceInput.init(device: audioDevice)
                
                if (self.session.canAddInput(audioDeviceInput)) {
                    self.session.addInput(audioDeviceInput)
                }
                
                let movieFileOutput:AVCaptureMovieFileOutput = AVCaptureMovieFileOutput.init()
                if (self.session.canAddOutput(movieFileOutput)) {
                    self.session.addOutput(movieFileOutput)
                    
                    let connection:AVCaptureConnection  = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo);
                    
                    if (connection.supportsVideoStabilization) {
                        connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Auto;
                    }
                    self.movieFileOutput = movieFileOutput;
                }
                
                
                let stillImageOutput:AVCaptureStillImageOutput = AVCaptureStillImageOutput.init()
                if (self.session.canAddOutput(stillImageOutput)) {
                    self.session.addOutput(stillImageOutput)
                    
                    stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                    stillImageOutput.highResolutionStillImageOutputEnabled = true
                    
                    self.stillImageOutput = stillImageOutput
                }
                
                self.session.commitConfiguration()
                
                dispatch_async(dispatch_get_main_queue()) {
                    complete(result:self.setupResult)
                }
            } catch let error as NSError {
                NSLog("Could not create device input: %@", error)
                self.setupResult = CameraManualSetupResult.SessionConfigurationFailed
            }
        };
    }
    
    private func resumeInterruptedSession() {
        
    }
    
    static func deviceWithMediaType(mediaType:String, preferringPosition position:(AVCaptureDevicePosition)) -> AVCaptureDevice? {
        if let devices:Array<AVCaptureDevice> = AVCaptureDevice.devicesWithMediaType(mediaType) as? Array<AVCaptureDevice> {
            var captureDevice = devices.first
            
            for device in devices {
                if (device.position == position) {
                    captureDevice = device
                    break;
                }
            }
            return captureDevice
        }
        return nil;
    }
    
    static func setFlashMode(flashMode:AVCaptureFlashMode, forDevice device:AVCaptureDevice) {
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
    
    static func setScaleFactor(scaleFactor:CGFloat, forDevice device:AVCaptureDevice) {
    }
}

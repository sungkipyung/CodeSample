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
            return AVCaptureVideoOrientation.LandscapeLeft
        case .LandscapeRight:
            return AVCaptureVideoOrientation.LandscapeRight
        case .PortraitUpsideDown:
            return AVCaptureVideoOrientation.PortraitUpsideDown
        default:
            return AVCaptureVideoOrientation.Portrait
        }
    }
}

typealias CameraSetupComplete = ((CameraManualSetupResult) -> (Void))

class Camera: NSObject {
    // MARK: properties
    internal var session: AVCaptureSession = AVCaptureSession.init()
    private var sessionQueue: dispatch_queue_t = dispatch_queue_create("com.campmobile.band.Camera", DISPATCH_QUEUE_SERIAL)
    private var videoDevice:AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var stillImageOutput:AVCaptureStillImageOutput?
    
    // MARK: Utilities
    internal var setupResult:CameraManualSetupResult = CameraManualSetupResult.CameraNotAuthorized
    internal private(set) var sessionRunning:Bool = false
    private var backgroundRecordingID:UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    // MARK: handler
    var onStartCamera: ((CameraManualSetupResult) -> (Void))? = nil
    
    internal func setupWithPreview(preview:CameraPreview, complete:CameraSetupComplete) {
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
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
                complete(self.setupResult)
            };
        }
    }
    
    internal func turnOff(complete: (Void) -> (Void)) {
        dispatch_async(self.sessionQueue) { 
            if (self.setupResult == CameraManualSetupResult.Success) {
                self.session.stopRunning()
                self.removeObservers();
            }
            dispatch_async(dispatch_get_main_queue()) {
                complete()
            };
        }
    }
    
    private func addObservers() {
    }
    
    private func removeObservers() {
    }
    
    // Setup the capture session.
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
    // so that the main queue isn't blocked, which keeps the UI responsive.
    private func setupCaptureSession(preview:CameraPreview, complete:CameraSetupComplete) {
        dispatch_async(self.sessionQueue) {
            if ( self.setupResult != CameraManualSetupResult.Success ) {
                return;
            }
        
            self.backgroundRecordingID = UIBackgroundTaskInvalid
            
    //        var error:NSError? = nil

            do {
                // create and add VideoDeviceInput
                self.session.beginConfiguration()
                
                let videoDevice = Camera.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Back)
                let videoDeviceInput: AVCaptureDeviceInput = try AVCaptureDeviceInput.init(device: videoDevice)
                
                
                if (self.session.canAddInput(videoDeviceInput)) {
                    self.session .addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                    self.videoDevice = videoDevice
                    
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
                
                let movieFileOut:AVCaptureMovieFileOutput = AVCaptureMovieFileOutput.init()
                if (self.session.canAddOutput(movieFileOut)) {
                    self.session.addOutput(movieFileOut)
                }
                
                
                let stillImageOutput:AVCaptureStillImageOutput = AVCaptureStillImageOutput.init()
                if (self.session.canAddOutput(stillImageOutput)) {
                    self.session.addOutput(stillImageOutput)
                    
                    stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                    stillImageOutput.highResolutionStillImageOutputEnabled = true
                    
                    self.stillImageOutput = stillImageOutput
                }
                
                self.session.commitConfiguration()
            } catch let error as NSError {
                NSLog("Could not create device input: %@", error)
                self.setupResult = CameraManualSetupResult.SessionConfigurationFailed
            }
        };
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
}

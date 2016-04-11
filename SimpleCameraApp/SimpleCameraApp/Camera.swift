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
class Camera: NSObject {
    // MARK: properties
    internal var session: AVCaptureSession = AVCaptureSession.init()
    internal var setupResult:CameraManualSetupResult = CameraManualSetupResult.CameraNotAuthorized
    private var sessionQueue: dispatch_queue_t = dispatch_queue_create("com.campmobile.band.Camera", DISPATCH_QUEUE_SERIAL)
    private var backgroundRecordingID:UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    
    private var videoDevice:AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?

    
    // MARK: handler
    var onCompleteInitialization: ((CameraManualSetupResult) -> (Void))? = nil
    
    private func setupWithPreview(preview:UIView) {
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
        
        setupCaptureSession(preview)
    }
    
    // Setup the capture session.
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
    // so that the main queue isn't blocked, which keeps the UI responsive.
    private func setupCaptureSession(preview:UIView) {
        
        dispatch_async(self.sessionQueue) {
            if ( self.setupResult != CameraManualSetupResult.Success ) {
                return;
            }
        
            self.backgroundRecordingID = UIBackgroundTaskInvalid
            
    //        var error:NSError? = nil

            do {
                // create and add VideoDeviceInput
                let videoDevice = Camera.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Back)
                let videoDeviceInput: AVCaptureDeviceInput = try AVCaptureDeviceInput.init(device: videoDevice)
                
                self.session.beginConfiguration()
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
                        var initialVideoOrientation:AVCaptureVideoOrientation = AVCaptureVideoOrientation.Portrait;
                        
                        /* 
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
                        
                        switch statusBarOrientation {
                        case .Portrait:
                            initialVideoOrientation = AVCaptureVideoOrientation.Portrait
                            break;
                        case .LandscapeLeft:
                            initialVideoOrientation = AVCaptureVideoOrientation.LandscapeLeft
                            break;
                        case .LandscapeRight:
                            initialVideoOrientation = AVCaptureVideoOrientation.LandscapeRight
                            break;
                        case .PortraitUpsideDown:
                            initialVideoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
                            break;
                        default:
                            break;
                        }
                        
                        if let previewLayer:AVCaptureVideoPreviewLayer = preview.layer as? AVCaptureVideoPreviewLayer {
                            previewLayer.connection.videoOrientation = initialVideoOrientation;
                        }
                    }
                }
                self.session.commitConfiguration()
                
            } catch let error as NSError {
                NSLog("Could not create video device input: %@", error )
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

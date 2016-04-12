//
//  CameraPreview.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 11..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreview: UIView {
    
    var session: AVCaptureSession? {
        get {
            if (self.layer is AVCaptureVideoPreviewLayer) {
                let previewLayer:AVCaptureVideoPreviewLayer = self.layer as! AVCaptureVideoPreviewLayer
                return previewLayer.session
            }
            return nil;
        }
        
        set (newSession) {
            if (self.layer is AVCaptureVideoPreviewLayer) {
                let previewLayer:AVCaptureVideoPreviewLayer = self.layer as! AVCaptureVideoPreviewLayer
                previewLayer.setSessionWithNoConnection(newSession)
            }
        }
    }

    override class func layerClass() -> AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

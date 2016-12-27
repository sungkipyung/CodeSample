//
//  CameraViewController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 5..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    @IBOutlet weak var cameraPreview: CameraPreview!
    @IBOutlet weak var cameraToggleButton: UIButton!
    @IBOutlet weak var cameraFlashButton: UIButton!
    @IBOutlet weak var cameraShotButton: UIButton!
    
    var camera:Camera = Camera.init()
    
    override func loadView() {
        super.loadView()
        let avLayer = cameraPreview.layer as? AVCaptureVideoPreviewLayer
        avLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraToggleButton.layer.cornerRadius = cameraToggleButton.frame.width / 2
        cameraToggleButton.layer.masksToBounds = true
        cameraToggleButton.layer.borderColor = cameraPreview.tintColor.cgColor
        cameraToggleButton.layer.borderWidth = 1
        
        cameraFlashButton.layer.cornerRadius = cameraFlashButton.frame.width / 2
        cameraFlashButton.layer.masksToBounds = true
        cameraFlashButton.layer.borderColor = cameraPreview.tintColor.cgColor
        cameraFlashButton.layer.borderWidth = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        camera.setupWithPreview(cameraPreview) { (result:CameraManualSetupResult) -> (Void) in
            
        }
        camera.turnOn({ (result:CameraManualSetupResult) -> (Void) in
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        camera.turnOff { () -> (Void) in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onTouchBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil);
    }
    @IBAction func onTouchShotButton(_ sender: UIButton) {
        self.camera.takePicture({ (imageData:Data?) -> (Void) in
            if (imageData == nil) {
                return
            }            
            let capturedImage:UIImage = UIImage.init(data:imageData!)!
            // TODO: Save Image
            }, withPreview: self.cameraPreview)
    }
    
    @IBAction func onTouchDownControl(_ sender: UIControl) {
    }
    
    @IBAction func onTouchUpControl(_ sender: UIControl) {
    }
    
    @IBAction func onTouchCameraToggleButton(_ sender: UIControl) {
        cameraShotButton.isEnabled = false
        cameraToggleButton.isEnabled = false
        
        self.camera.toggleCamera { (error) -> (Void) in
            self.cameraShotButton.isEnabled = true
            self.cameraToggleButton.isEnabled = true
        }
    }
}

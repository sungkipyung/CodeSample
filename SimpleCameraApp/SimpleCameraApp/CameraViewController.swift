//
//  CameraViewController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 5..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    @IBOutlet weak var cameraPreview: CameraPreview!
    @IBOutlet weak var cameraToggleButton: UIButton!
    @IBOutlet weak var cameraFlashButton: UIButton!
    
    var camera:Camera = Camera.init()
    
    override func loadView() {
        super.loadView()
        cameraToggleButton.layer.cornerRadius = cameraToggleButton.frame.width / 2
        cameraToggleButton.layer.masksToBounds = true
        cameraToggleButton.layer.borderColor = cameraPreview.tintColor.CGColor
        cameraToggleButton.layer.borderWidth = 1
        
        cameraFlashButton.layer.cornerRadius = cameraFlashButton.frame.width / 2
        cameraFlashButton.layer.masksToBounds = true
        cameraFlashButton.layer.borderColor = cameraPreview.tintColor.CGColor
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
    
    override func viewWillDisappear(animated: Bool) {
        camera.turnOff { () -> (Void) in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
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

    @IBAction func onTouchBackButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
}

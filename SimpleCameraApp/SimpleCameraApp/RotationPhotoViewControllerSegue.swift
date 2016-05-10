//
//  RotationPhotoViewControllerSegue.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 10..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class RotationPhotoViewControllerSegue: UIStoryboardSegue {
    override func perform() {
        
        let srcVC = self.sourceViewController // collage
        let destVC = self.destinationViewController // RotationPhotoViewController
        
        srcVC.presentViewController(destVC, animated: false, completion: nil)
    }
}

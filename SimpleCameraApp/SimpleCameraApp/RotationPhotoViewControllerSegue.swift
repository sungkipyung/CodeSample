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
        
        let srcVC = self.sourceViewController as! CollageViewController // collage
        let destVC = self.destinationViewController as! RotationPhotoViewController // RotationPhotoViewController
        
        let containerView = srcVC.view.superview
        
        containerView?.addSubview(destVC.view)
//        destVC.view.hidden = true
        
        UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 4.0, options: UIViewAnimationOptions(rawValue: 0), animations: {
//            srcVC.view.hidden = true
//            destVC.view.hidden = false
            containerView?.bringSubviewToFront(destVC.view)
            }) { (complete) in
                destVC.view .removeFromSuperview()
                srcVC.presentViewController(destVC, animated: false, completion: nil)
        }
    }
}

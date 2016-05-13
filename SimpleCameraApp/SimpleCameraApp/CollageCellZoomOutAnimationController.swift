//
//  CollageCellZoomOutAnimationController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 13..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class CollageCellZoomOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    // This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
    // synchronize with the main animation.
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 2.0
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) ,
            let containerView = transitionContext.containerView(),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                return
        }
        let collageVC = toVC as! CollageViewController
        let rotationPhotoVC = fromVC as! RotationPhotoViewController
        let selectedCollageCell = collageVC.bubbleView.selectedCollageCell!
//
//        let initialFrame = selectedCollageCell.superview!.convertRect(selectedCollageCell.frame, toView: collageVC.view)
        let initailFrame = rotationPhotoVC.targetView.superview!.convertRect(rotationPhotoVC.targetView.frame, toView: rotationPhotoVC.targetView.superview!)
        
        let finalPoint = selectedCollageCell.superview!.convertPoint(selectedCollageCell.center, toView: collageVC.view)
//        
//        let finalPoint = CGPoint(x:rotationPhotoVC.view.center.x, y:(rotationPhotoVC.view.frame.size.height - 134) / 2)
//        
//        let snapshot = collageVC.bubbleView.selectedCollageCell!.snapshotViewAfterScreenUpdates(true)
        let snapshot = rotationPhotoVC.targetView.snapshotViewAfterScreenUpdates(true)
        
//        snapshot.frame = initialFrame
//        snapshot.layer.masksToBounds = true
//        
//        containerView.addSubview(snapshot)
//        toVC.view.hidden = true
//        
//        let duration = transitionDuration(transitionContext)
//        
//        UIView.animateKeyframesWithDuration(duration, delay: 0, options: .CalculationModeCubic, animations: {
//            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/3, animations: {
//                fromVC.view.hidden = true
//            })
//            
//            UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
//                snapshot.center = finalPoint
//            })
//            
//            UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
//                toVC.view.hidden = false
//            })
//            
//        }) { (complete) in
//            toVC.view.hidden = false
//            fromVC.view.hidden = false
//            
//            containerView.addSubview(toVC.view)
//            
//            rotationPhotoVC.targetView.frame = snapshot.bounds
//            
//            rotationPhotoVC.targetView.imageScrollView.contentSize = selectedCollageCell.imageScrollView.contentSize
//            rotationPhotoVC.targetView.imageScrollView.contentOffset = selectedCollageCell.imageScrollView.contentOffset
//            rotationPhotoVC.targetView.imageScrollView.zoomScale = selectedCollageCell.imageScrollView.zoomScale
//            rotationPhotoVC.targetView.imageView.image = selectedCollageCell.imageView.image
//            rotationPhotoVC.targetView.imageView.frame = selectedCollageCell.imageView.bounds
//            rotationPhotoVC.targetView.imageView.contentMode = selectedCollageCell.imageView.contentMode
//            rotationPhotoVC.targetView.polygon = selectedCollageCell.polygon.copy()
//            
//            rotationPhotoVC.targetView.center = snapshot.center
//            
//            rotationPhotoVC.targetView.hidden = false
//            
//            snapshot.removeFromSuperview()
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
//        }
    }
}

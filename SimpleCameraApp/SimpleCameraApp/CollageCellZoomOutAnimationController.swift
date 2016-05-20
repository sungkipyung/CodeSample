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
        
        guard
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) ,
            let containerView = transitionContext.containerView(),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                return
        }
        
        guard
            let collageVC = toVC as? CollageViewController,
            let rotationPhotoVC = fromVC as? RotationPhotoViewController,
            let selectedCollageCell = collageVC.bubbleView.selectedCollageCell else {
                return
        }
        
        containerView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        

        let fromView = rotationPhotoVC.imageScrollView
        let initialFrame = fromView.superview!.convertRect(fromView.frame, toView: fromView.superview!)

        let finalPoint = selectedCollageCell.superview!.convertPoint(selectedCollageCell.center, toView: collageVC.view)
//        let finalFrame = selectedCollageCell.superview!.convertRect(selectedCollageCell.frame, toView: collageVC.view)

        let snapshot = fromView.snapshotViewAfterScreenUpdates(true)
        
        snapshot.frame = initialFrame
        snapshot.layer.masksToBounds = true

        containerView.addSubview(snapshot)
        toVC.view.hidden = true
        
        let duration = transitionDuration(transitionContext)
        
        UIView.animateKeyframesWithDuration(duration, delay: 0, options: .CalculationModeCubicPaced, animations: { 
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/3, animations: {
                fromVC.view.hidden = true
            })
            
            UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: { 
                snapshot.center = finalPoint
            })
            
            UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: { 
                
            })
            
            }) { (complete) in
                containerView.addSubview(toVC.view)
                
                selectedCollageCell.imageView.transform = rotationPhotoVC.imageView!.transform
                selectedCollageCell.imageView.frame = rotationPhotoVC.imageView!.frame
                
                selectedCollageCell.imageScrollView.contentOffset = rotationPhotoVC.imageScrollView.contentOffset
                selectedCollageCell.imageScrollView.zoomScale = rotationPhotoVC.imageScrollView.zoomScale
                
                snapshot.removeFromSuperview()

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                toVC.view.hidden = false
                fromVC.view.hidden = false
        }
    }
}

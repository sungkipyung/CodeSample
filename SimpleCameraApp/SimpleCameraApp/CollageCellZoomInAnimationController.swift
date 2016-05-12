//
//  CollageCellZoomInAnimationController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 12..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class CollageCellZoomInAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    // This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
    // synchronize with the main animation.
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 5.0
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) ,
            let containerView = transitionContext.containerView(),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                return
        }
        
        let collageVC = fromVC as! CollageViewController
        let rotationPhotoVC = toVC as! RotationPhotoViewController
        let selectedCollageCell = collageVC.bubbleView.selectedCollageCell!
        
        
        
        let initialFrame = selectedCollageCell.superview!.convertRect(selectedCollageCell.frame, toView: collageVC.view)
        let finalFrame = rotationPhotoVC.contentView.superview!.convertRect(rotationPhotoVC.contentView.frame, toView:rotationPhotoVC.view)
        
        
        let snapshot = collageVC.bubbleView.selectedCollageCell!.snapshotViewAfterScreenUpdates(true)
        snapshot.frame = initialFrame
        snapshot.layer.masksToBounds = true
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(fromVC.view)
        containerView.addSubview(snapshot)
        
        fromVC.view.hidden = false
        toVC.view.hidden = true
        
        let duration = transitionDuration(transitionContext)
        
        UIView.animateKeyframesWithDuration(duration, delay: 0, options: .CalculationModeCubic, animations: {
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/3, animations: {
                fromVC.view.hidden = true
            })
            
            UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                snapshot.frame = finalFrame
            })
            
            UIView.addKeyframeWithRelativeStartTime(3/4, relativeDuration: 1/3, animations: {
                toVC.view.hidden = false
//                toVC.view.hidden = false
            })
            
        }) { (complete) in
            snapshot.removeFromSuperview()
            fromVC.view.removeFromSuperview()
            toVC.view.hidden = false
            fromVC.view.hidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

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
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) ,
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        let containerView = transitionContext.containerView
        
        let collageVC = fromVC as! CollageViewController
        let rotationPhotoVC = toVC as! RotationPhotoViewController
        let selectedCollageCell = collageVC.bubbleView.selectedCollageCell!
        
        rotationPhotoVC.view.layoutIfNeeded()
        
        let initialFrame = selectedCollageCell.superview!.convert(selectedCollageCell.frame, to: collageVC.view)
        
        let finalPoint = rotationPhotoVC.imageScrollView.center
        
        guard let snapshot = collageVC.bubbleView.selectedCollageCell!.snapshotView(afterScreenUpdates: true) else { return }
        snapshot.frame = initialFrame
        snapshot.layer.masksToBounds = true
        
        containerView.addSubview(snapshot)
        
        
        let duration = transitionDuration(using: transitionContext)
        
        toVC.view.isHidden = true
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubicPaced, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: {
                fromVC.view.isHidden = true
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                snapshot.center = finalPoint
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                toVC.view.isHidden = false
            })
            
        }) { (complete) in
            toVC.view.isHidden = false
            fromVC.view.isHidden = false
            
            containerView.addSubview(toVC.view)    
            
            let success = !transitionContext.transitionWasCancelled
            
            if (success == false) {
                toVC.view.removeFromSuperview()
            }
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(success)
        }
    }
}

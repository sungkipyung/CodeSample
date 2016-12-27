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
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) ,
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        let toView = toVC.view
        
        guard
            let collageVC = toVC as? CollageViewController,
            let rotationPhotoVC = fromVC as? RotationPhotoViewController,
            let selectedCollageCell = collageVC.bubbleView.selectedCollageCell else {
                return
        }
        
        let imageScrollView = rotationPhotoVC.imageScrollView
        let initialFrame = imageScrollView?.superview!.convert((imageScrollView?.frame)!, to: imageScrollView?.superview!)

        let finalPoint = selectedCollageCell.superview!.convert(selectedCollageCell.center, to: collageVC.view)

        guard let snapshot = imageScrollView?.snapshotView(afterScreenUpdates: true) else { return }
        
        snapshot.frame = initialFrame!
        snapshot.layer.masksToBounds = true

        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        
        toVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubicPaced, animations: { 
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: {
                fromVC.view.isHidden = true
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: { 
                snapshot.center = finalPoint
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: { 
                
            })
            
            }) { (complete) in
                snapshot.removeFromSuperview()
                fromVC.view.removeFromSuperview()

                let success = !transitionContext.transitionWasCancelled
                
                if success {
                    toView?.removeFromSuperview()
                }
                
                transitionContext.completeTransition(success)
                /**
                 http://stackoverflow.com/questions/24338700/from-view-controller-disappears-using-uiviewcontrollercontexttransitioning
                 */
                UIApplication.shared.keyWindow!.addSubview(toVC.view)
                toVC.view.isHidden = false
                fromVC.view.isHidden = false
        }
    }
}

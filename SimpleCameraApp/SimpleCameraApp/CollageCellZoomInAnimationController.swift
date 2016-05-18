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
        return 2.0
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
        
        let finalPoint = rotationPhotoVC.imageScrollView.center
        
        let snapshot = collageVC.bubbleView.selectedCollageCell!.snapshotViewAfterScreenUpdates(true)
        snapshot.frame = initialFrame
        snapshot.layer.masksToBounds = true
        
        containerView.addSubview(snapshot)
        toVC.view.hidden = true
        
        let duration = transitionDuration(transitionContext)
        
        rotationPhotoVC.imageScrollView.hidden = true
        
        UIView.animateKeyframesWithDuration(duration, delay: 0, options: .CalculationModeCubicPaced, animations: {
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/3, animations: {
                fromVC.view.hidden = true
            })
            
            UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                snapshot.center = finalPoint
            })
            
            UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                toVC.view.hidden = false
            })
            
        }) { (complete) in
            toVC.view.hidden = false
            fromVC.view.hidden = false
            
            containerView.addSubview(toVC.view)
            
            rotationPhotoVC.imageScrollViewWidth.constant = selectedCollageCell.frame.size.width
            rotationPhotoVC.imageScrollViewHeight.constant = selectedCollageCell.frame.size.height
            rotationPhotoVC.view.layoutIfNeeded()
            
            let imageView = UIImageView(image: selectedCollageCell.imageView.image)
            imageView.contentMode = UIViewContentMode.ScaleToFill
            rotationPhotoVC.imageScrollView.addSubview(imageView)
            rotationPhotoVC.imageView = imageView
            imageView.sizeThatFit(rotationPhotoVC.imageScrollView)
            
            let polygon = selectedCollageCell.polygon.copy()
            rotationPhotoVC.shapeLayerPath = polygon.path()
            rotationPhotoVC.imageScrollView.hidden = false
            
            rotationPhotoVC.imageScrollView.contentOffset = selectedCollageCell.imageScrollView.contentOffset
            rotationPhotoVC.imageScrollView.zoomScale = selectedCollageCell.imageScrollView.zoomScale
            
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

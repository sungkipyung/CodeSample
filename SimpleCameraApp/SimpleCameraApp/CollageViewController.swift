//
//  CollageViewController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 14..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class CollageViewController: UIViewController {

    @IBOutlet weak var collageView: CollageView!
    
    @IBOutlet weak var intervalControlButton: RadioButton!
    @IBOutlet weak var intervalProgressView: UIProgressView!
    
    @IBOutlet weak var roundControlButton: RadioButton!
    @IBOutlet weak var roundProgressView: UIProgressView!
    
    @IBOutlet weak var layoutControlView: UIView!
    fileprivate static let MAX_BORDER_WIDTH: CGFloat = 10
    @IBOutlet weak var bubbleView: BubbleView!
    
    fileprivate let collageCellZoomInAnimationController = CollageCellZoomInAnimationController()
    fileprivate let collageCellZoomOutAnimationController = CollageCellZoomOutAnimationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bubbleView.delegate = self
        
        let image = UIImage(named: "pattern-repeat-4.png")!
        collageView.backgroundColor = UIColor(patternImage: image)
        // Do any additional setup after loading the view.
        
        intervalControlButton.onChangeLocation = { [weak self] (view: RadioButton, originalPosition: CGPoint, incX: CGFloat, incY: CGFloat) -> (Void) in
            guard let strongSelf = self else { return }
            
            let buttonRadious = view.frame.size.width / 2
            
            let start = buttonRadious
            let end = view.superview!.frame.size.width - buttonRadious
            
            view.center.x = min(max(originalPosition.x + incX, start), end)
            
            let progress: Float = (Float)(view.center.x - start)/(Float)(end - start)
            strongSelf.collageView.layout?.border = CGFloat(progress) * CollageViewController.MAX_BORDER_WIDTH
            strongSelf.intervalProgressView.setProgress(progress, animated: false)
            strongSelf.collageView.redraw()
        }
        
        roundControlButton.onChangeLocation = { [weak self] (view: RadioButton, originalPosition: CGPoint, incX: CGFloat, incY: CGFloat) -> (Void) in
            guard let strongSelf = self else { return }
            
            let buttonRadious = view.frame.size.width / 2
            
            let start = buttonRadious
            let end = view.superview!.frame.size.width - buttonRadious
            
            view.center.x = min(max(originalPosition.x + incX, start), end)
            let progress: Float = (Float)(view.center.x - start)/(Float)(end - start)
            strongSelf.collageView.layout?.curvature = CGFloat(progress)
            strongSelf.roundProgressView.setProgress(progress, animated: false)
            strongSelf.collageView.redraw()
        }
        
        let layout = LayoutFactory.sharedInstance.getLayout(0, limit: 1)![0]
        let width = UIScreen.main.bounds.size.width - 32
        collageView.frame.size.width = width
        collageView.frame.size.height = width
        collageView.layout = layout
        collageView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        layoutControlView.addObserver(self, forKeyPath: "hidden", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        layoutControlView.removeObserver(self, forKeyPath: "hidden")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let view = object as? UIView {
            if view == layoutControlView {
                updateLayoutcontrolView()
            }
        }
    }
    
    @IBAction func onTouchFrameControlButton(_ sender: AnyObject) {
        layoutControlView.isHidden = !layoutControlView.isHidden
        clearBubbleView()
    }
    
    @IBAction func onTapGesture(_ sender: UITapGestureRecognizer) {
        if view == sender.view {
            layoutControlView.isHidden = true
            clearBubbleView()
        }
    }
    
    @IBAction func onTouchBackButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        super.prepareForSegue(segue, sender: sender)
        
        let destVC = segue.destination as! RotationPhotoViewController
        destVC.transitioningDelegate = self
        destVC.modalPresentationStyle = UIModalPresentationStyle.custom
        destVC.view.layoutIfNeeded()
        destVC.rpvcDelegate = self
        
        let selectedCollageCell = bubbleView.selectedCollageCell!
        destVC.imageScrollViewWidth.constant = selectedCollageCell.frame.size.width
        destVC.imageScrollViewHeight.constant = selectedCollageCell.frame.size.height
        
        //
        let imageView = UIImageView.copyImageView(selectedCollageCell.imageView)
        
        destVC.imageView = imageView
        destVC.imageScrollView.addSubview(imageView)
        destVC.imageScrollViewWidth.constant = selectedCollageCell.imageScrollView.bounds.width
        destVC.imageScrollViewHeight.constant = selectedCollageCell.imageScrollView.bounds.height
        destVC.imageScrollView.copyContentOffsetInsetSizeFromOtherScrollView(selectedCollageCell.imageScrollView)

        let polygon = selectedCollageCell.polygon.copy()
        destVC.shapeLayerPath = polygon.path()
    }
    
    // MARK: - private
    fileprivate func clearBubbleView() {
        bubbleView.selectedCollageCell = nil
        bubbleView.isHidden = true
    }
    
    fileprivate func updateLayoutcontrolView() {
        if (layoutControlView.isHidden) {
            collageView.drawGrapButtons = false
            collageView.swappable = true
        } else {
            collageView.drawGrapButtons = true
            collageView.cellGrapButtons.forEach({ (button) in
                collageView.bringSubview(toFront: button)
            })
            collageView.swappable = false
        }
    }
}

// MARK: - RotationPhotoViewControllerDelegate
extension CollageViewController : RotationPhotoViewControllerDelegate {
    func rotationPhotoVCWillFinish(_ vc: RotationPhotoViewController, applyChanges: Bool) {
        let selectedCollageCell = bubbleView.selectedCollageCell!
        let imageView = vc.imageView!
        let imageScrollView = selectedCollageCell.imageScrollView
        let image = imageView.image!
        selectedCollageCell.imageView.image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: image.imageOrientation)
        selectedCollageCell.imageView.applyTransform(imageView.transform, andSizeToFitScrollView: imageScrollView!)
        imageScrollView?.copyContentOffsetInsetSizeFromOtherScrollView(vc.imageScrollView)
        bubbleView.isHidden = true
    }
}

// MARK: -CollageViewDelegate
extension CollageViewController : CollageViewDelegate {
    func collageCellSelected(_ collageView: CollageView, selectedCell: CollageCell) {
        bubbleView.selectedCollageCell = selectedCell
        bubbleView.isHidden = false
        
        let axisView = bubbleView.superview!
        
        // transfer coordinate collageView to axisView
        let point = axisView.convert(selectedCell.center, from:selectedCell.superview)
        bubbleView.center = point
        
        // bubbleView's tail will be located at selectedCollageCell's center
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension CollageViewController : UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return collageCellZoomInAnimationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return collageCellZoomOutAnimationController
    }

}

// MARK: - BubbleViewDelegate
extension CollageViewController : BubbleViewDelegate {
    func bubbleViewRotationButtonTouched(_ bubbleView: BubbleView, sender:AnyObject) {
        // RotationPhotoViewControllerSegue
        performSegue(withIdentifier: "RotationPhotoViewControllerSegue", sender: self)
    }
    
}

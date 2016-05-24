//
//  RotationPhotoViewController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 3..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

protocol RotationPhotoViewControllerDelegate : class {
    func rotationPhotoVCWillFinish(viewController: RotationPhotoViewController, applyChanges: Bool)
    
}

class RotationPhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var cursorView: UIView!
    @IBOutlet weak var rulerCollectionView: UICollectionView!
    @IBOutlet weak var controlBottom: NSLayoutConstraint!
    
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageScrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageScrollViewHeight: NSLayoutConstraint!
    
    weak var rpvcDelegate: RotationPhotoViewControllerDelegate?
    
    var shapeLayerPath: UIBezierPath?
    var imageViewOriginalFrame: CGRect?
    weak var imageView: UIImageView? {
        didSet {
            if let imageView = self.imageView {
                self.imageViewOriginalFrame = imageView.frame
            }
        }
    }
    
    private let CELL_WIDTH: CGFloat = 50
    private let CELL_COUNT: Int = 19
    private let CELL_MID_INDEX: Int = 9
    private var ignoreRotation: Bool = true
    
    
    /// test
    @IBOutlet weak var cropView: UIView!
    @IBOutlet weak var testImageView: UIImageView!
    
    @IBAction func touchCropMode(sender: AnyObject) {
        self.cropView.hidden = false
        self.cropView.layer.borderColor = UIColor.orangeColor().CGColor
        self.cropView.layer.borderWidth = 3.0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "RulerCell", bundle: NSBundle.mainBundle())
        self.rulerCollectionView.registerNib(nib, forCellWithReuseIdentifier: "rulerCell")
        self.rulerCollectionView.decelerationRate = UIScrollViewDecelerationRateNormal
        let hw = self.view.bounds.size.width / 2 - CELL_WIDTH / 2
        self.rulerCollectionView.contentInset = UIEdgeInsets(top: 0, left: hw, bottom: 0, right: hw)
        // Do any additional setup after loading the view.
        self.ignoreRotation = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        
        addMaskIfExist()
        clearRuler()
    }
    
    private func clearRuler() {
        self.rulerCollectionView.hidden = true
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(100 * NSEC_PER_MSEC)), dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.1, animations: {
                self.clearRotation(false)
            }) { (complete) in
                self.rulerCollectionView.hidden = false
                self.ignoreRotation = false
                self.cursorView.hidden = false
            }
        }
    }
    
    private func addMaskIfExist() {
        if let innerPath = self.shapeLayerPath {
            let mask: CAShapeLayer = CAShapeLayer()
            mask.frame = self.contentView.bounds
            
            let path = UIBezierPath(rect: self.contentView.bounds)
            innerPath.applyTransform(CGAffineTransformMakeTranslation(self.imageScrollView.frame.origin.x, self.imageScrollView.frame.origin.y))
            path.appendPath(innerPath)
            
            mask.path = path.CGPath
            mask.fillRule = kCAFillRuleEvenOdd
            
            self.maskView.layer.mask = mask
            self.maskView.hidden = false
            self.maskView.alpha = 1.0
        }
    }
    
    private func clearRotation(animated: Bool) {
        self.rulerCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: CELL_MID_INDEX, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

    // MARK: - IBAction
    @IBAction func touchCloseButton(sender: AnyObject) {
        rpvcDelegate?.rotationPhotoVCWillFinish(self, applyChanges: false)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func touchClearButton(sender: AnyObject) {
        clearRotation(true)
    }
    
    @IBAction func touchLeftButton(sender: AnyObject) {
    }
    
    @IBAction func touchRightButton(sender: AnyObject) {
    }
    
    @IBAction func touchHorizontalMirrorButton(sender: AnyObject) {
    }
    
    @IBAction func touchVerticalMirrorButton(sender: AnyObject) {
    }
    
    @IBAction func touchDoneButton(sender: AnyObject) {
        rpvcDelegate?.rotationPhotoVCWillFinish(self, applyChanges: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UICollectionViewDelegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CELL_COUNT
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: RulerCell = collectionView.dequeueReusableCellWithReuseIdentifier("rulerCell", forIndexPath: indexPath) as! RulerCell
        
        cell.degreeLabel.text = degreeString(indexPath)
        
        cell.showLeft = true
        cell.showRight = true
        
        if (indexPath.row == 0) {
            cell.showLeft = false
        } else if (indexPath.row == CELL_COUNT - 1) {
            cell.showRight = false
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        hideDim()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            hideDim()
        }
    }
    private func hideDim() {
        self.maskView.alpha = 1.0
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1000 * NSEC_PER_MSEC)), dispatch_get_main_queue()) {
            self.degreeLabel.hidden = true
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.ignoreRotation {
            return
        }
        
        self.maskView.alpha = 0.5
        let cells = self.rulerCollectionView.visibleCells().filter { (cell) -> Bool in
            let cellFrame = cell.frame
            let cellFrameInSuperView = self.rulerCollectionView.convertRect(cellFrame, toView: self.rulerCollectionView.superview!)
            return CGRectContainsPoint(cellFrameInSuperView, self.rulerCollectionView.center)
        }
        
        if cells.count > 0 {
            let degree = degreeOf(cells[0] as! RulerCell)
            let radian = degree / 180.0 * CGFloat(M_PI)
            self.imageView!.applyTransform(CGAffineTransformMakeRotation(radian), andSizeToFitScrollView: self.imageScrollView)
            self.degreeLabel.text = String(format: "%.1f°", CGFloat(degree))
            self.degreeLabel.hidden = false
            
            self.testImageView.rotateAndSizeToFit(self.cropView.bounds.size, degree: degree)
        }
    }

    
    // MARK : - Private
    private func degreeString(indexPath: NSIndexPath) -> String {
        return "\(degree(indexPath))°"
    }
    
    private func degree(indexPath: NSIndexPath) -> Int {
        return (indexPath.row - CELL_MID_INDEX) * 5
    }
    
    private func degreeOf(cell: RulerCell) -> CGFloat {
        let cellFrame = cell.frame
        
        let cellFrameInSuperView = self.rulerCollectionView.convertRect(cellFrame, toView: self.rulerCollectionView.superview!)
        
        let start = cellFrameInSuperView.origin.x
        let end = cellFrameInSuperView.size.width + start
        
        let value = self.rulerCollectionView.center.x - start
        
        // - 2.5 ~ 2.5
        let floatPoint = 5 * (value / (end - start) - 0.5)
        
        let indexPath = self.rulerCollectionView.indexPathForCell(cell)!
        
        // 소수점 1번째 자리 까지 유효함
        let degree = floor(10 * (CGFloat(self.degree(indexPath)) + floatPoint)) / 10
        return degree
    }
    
//    private func test(from: CGPoint, to: CGPoint, center: CGPoint, radius: CGFloat) {
//        let f1 = OneDimentionalFunction.createFunctionBetweenFromPoint(from, to: to)
//        let f2 = f1.orthogonalFuncitonPassPoint(center)
//        
//        guard let intersectionPoint = f1.intersectionPointWith(f2) else {
//            return
//        }
//        let distance = intersectionPoint.distanceTo(center)
//        
//        if distance < radius {
//            // have to scale
//            print("have to scale")
//        }
//    }
}

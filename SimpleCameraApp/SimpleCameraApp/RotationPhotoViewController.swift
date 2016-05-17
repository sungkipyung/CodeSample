//
//  RotationPhotoViewController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 3..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

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
    
    var shapeLayerPath: UIBezierPath?
    weak var imageView: UIImageView?
    
    private let CELL_WIDTH: CGFloat = 50
    private let CELL_COUNT: Int = 19
    private let CELL_MID_INDEX: Int = 9
    private var ignoreRotation: Bool = true
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func touchCloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func touchClearButton(sender: AnyObject) {
        clearRotation(true)
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
    func degreeString(indexPath: NSIndexPath) -> String {
        return "\(degree(indexPath))°"
    }
    
    func degree(indexPath: NSIndexPath) -> Int {
        return (indexPath.row - CELL_MID_INDEX) * 5
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.maskView.alpha = 1.0
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
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
            let cell = cells[0] as! RulerCell
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
            
            let radian = degree / 180.0 * CGFloat(M_PI)
            
            if let imageView = self.imageView {
                imageView.transform = CGAffineTransformMakeRotation(radian)
            }
            self.degreeLabel.text = String(format: "%.1f°", CGFloat(degree))
            self.degreeLabel.hidden = false
        }
    }
}

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
    @IBOutlet weak var degreeLabel: UILabel!
    
    internal weak private(set) var targetView: CollageCell!

    @IBOutlet weak var cursorView: UIView!
    @IBOutlet weak var rulerCollectionView: UICollectionView!
    @IBOutlet weak var controlBottom: NSLayoutConstraint!
    private let CELL_WIDTH: CGFloat = 50
    private let CELL_COUNT: CGFloat = 91
    private var ignoreRotation: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cell = UINib(nibName: "CollageCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? CollageCell {
            cell.hidden = true
            self.contentView.addSubview(cell)
            cell.clipsToBounds = false
            self.targetView = cell
            self.targetView.userInteractionEnabled = true
        }
        
        self.rulerCollectionView.delegate = self
        self.rulerCollectionView.dataSource = self
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
    private func clearRotation(animated: Bool) {
        self.rulerCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: 45, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: animated)
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
        return 91
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: RulerCell = collectionView.dequeueReusableCellWithReuseIdentifier("rulerCell", forIndexPath: indexPath) as! RulerCell
        
        cell.degreeLabel.text = "\(indexPath.row - 45)°"
        
        cell.showLeft = true
        cell.showRight = true
        
        if (indexPath.row == 0) {
            cell.showLeft = false
        } else if (indexPath.row == 90) {
            cell.showRight = false
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
//            self.degreeLabel.hidden = true
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.ignoreRotation {
            return
        }
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
            
            // - 0.5 ~ 0.5
            let floatPoint = value / (end - start) - 0.5
            
            let indexPath = self.rulerCollectionView.indexPathForCell(cell)!
            let degree = CGFloat(indexPath.row - 45) + floatPoint
            
            let degreeString = String(format: "%.1f°", CGFloat(degree))
            let radian = degree / 180.0 * CGFloat(M_PI)
            targetView.imageView.transform = CGAffineTransformMakeRotation(radian)
            self.degreeLabel.text = degreeString
            self.degreeLabel.hidden = false
        }
        
        if (scrollView.decelerating) {
            
        } else {
            
        }
    }
}
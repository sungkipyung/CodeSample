//
//  RotationPhotoViewController.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 3..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

protocol RotationPhotoViewControllerDelegate : class {
    func rotationPhotoVCWillFinish(_ viewController: RotationPhotoViewController, applyChanges: Bool)
    
}

class RotationPhotoViewController: UIViewController {
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
    
    fileprivate let cellWidth: CGFloat = 50.0
    fileprivate let numberOfCells: Int = 19
    fileprivate let middleIndexOfCells: Int = 9
    fileprivate var ignoreRotation: Bool = true
    fileprivate var additionalDegreeForRotation: CGFloat = 0
    
    /// test
    @IBOutlet weak var cropView: UIView!
    @IBOutlet weak var testImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "RulerCell", bundle: Bundle.main)
        self.rulerCollectionView.register(nib, forCellWithReuseIdentifier: "rulerCell")
        self.rulerCollectionView.decelerationRate = UIScrollViewDecelerationRateNormal
        let hw = self.view.bounds.size.width / 2 - cellWidth / 2
        self.rulerCollectionView.contentInset = UIEdgeInsets(top: 0, left: hw, bottom: 0, right: hw)
        // Do any additional setup after loading the view.
        self.ignoreRotation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        
        addMaskIfExist()
        clearRuler()
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
    // MARK: - IBAction
    
    @IBAction func touchCropMode(_ sender: AnyObject) {
        self.cropView.isHidden = false
        self.cropView.layer.borderColor = UIColor.orange.cgColor
        self.cropView.layer.borderWidth = 3.0
    }
    
    @IBAction func touchCloseButton(_ sender: AnyObject) {
        rpvcDelegate?.rotationPhotoVCWillFinish(self, applyChanges: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchClearButton(_ sender: AnyObject) {
        clearRotation(true)
    }
    
    @IBAction func touchLeftButton(_ sender: AnyObject) {
        additionalDegreeForRotation = additionalDegreeForRotation - 90
        if (additionalDegreeForRotation < 0) {
            additionalDegreeForRotation = additionalDegreeForRotation + 360
        }
        rotationImageView(true)
    }
    
    @IBAction func touchRightButton(_ sender: AnyObject) {
        additionalDegreeForRotation = additionalDegreeForRotation + 90
        additionalDegreeForRotation = additionalDegreeForRotation.truncatingRemainder(dividingBy: 360)
        rotationImageView(true)
    }
    
    @IBAction func touchHorizontalMirrorButton(_ sender: AnyObject) {
        if let imageView = self.imageView, imageView.image != nil {
            let image = imageView.image!
            let scale = image.scale
            let changedImage = UIImage(cgImage: image.cgImage!, scale: scale, orientation: image.imageOrientation.mirroredImageOrientation())
            self.imageView?.image = changedImage
        }
        clearRotation(false)
    }
    
    @IBAction func touchVerticalMirrorButton(_ sender: AnyObject) {
        if let imageView = self.imageView, imageView.image != nil {
            let image = imageView.image!
            let scale = image.scale
            let changedImage = UIImage(cgImage: image.cgImage!, scale: scale, orientation: image.imageOrientation.verticalMirroredImageOrientation())
            self.imageView?.image = changedImage
        }
        clearRotation(false)
    }
    
    @IBAction func touchDoneButton(_ sender: AnyObject) {
        rpvcDelegate?.rotationPhotoVCWillFinish(self, applyChanges: true)
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK : - Private
    fileprivate func calcDegree() -> CGFloat {
        let cells = self.rulerCollectionView.visibleCells.filter { (cell) -> Bool in
            let cellFrame = cell.frame
            let cellFrameInSuperView = self.rulerCollectionView.convert(cellFrame, to: self.rulerCollectionView.superview!)
            return cellFrameInSuperView.contains(self.rulerCollectionView.center)
        }
        
        if cells.count == 0 {
            return 0
        }
        
        let degree = degreeOf(cells[0] as! RulerCell)
        
        return degree
    }
    
    fileprivate func rotationImageView(_ animate: Bool) {
        let degree = self.calcDegree()
        let radian = (degree + self.additionalDegreeForRotation) / 180.0 * CGFloat(M_PI)
        
        let animations: (() -> Void) = {
            self.imageView!.applyTransform(CGAffineTransform(rotationAngle: radian), andSizeToFitScrollView: self.imageScrollView)
            self.degreeLabel.text = String(format: "%.1f°", CGFloat(degree))
            self.degreeLabel.isHidden = false
        }
        
        if animate {
            UIView.animate(withDuration: 0.5, animations: animations, completion: { (complete) in
                self.testImageView.rotateAndSizeToFit(self.cropView.bounds.size, degree: degree)
            })
        } else {
            animations()
            self.testImageView.rotateAndSizeToFit(self.cropView.bounds.size, degree: degree)
        }
    }
    
    fileprivate func degreeString(_ indexPath: IndexPath) -> String {
        return "\(degree(indexPath))°"
    }
    
    fileprivate func degree(_ indexPath: IndexPath) -> Int {
        return (indexPath.row - middleIndexOfCells) * 5
    }
    
    fileprivate func degreeOf(_ cell: RulerCell) -> CGFloat {
        let cellFrame = cell.frame
        
        let cellFrameInSuperView = self.rulerCollectionView.convert(cellFrame, to: self.rulerCollectionView.superview!)
        
        let start = cellFrameInSuperView.origin.x
        let end = cellFrameInSuperView.size.width + start
        
        let value = self.rulerCollectionView.center.x - start
        
        // - 2.5 ~ 2.5
        let floatPoint = 5 * (value / (end - start) - 0.5)
        
        let indexPath = self.rulerCollectionView.indexPath(for: cell)!
        
        // 소수점 1번째 자리 까지 유효함
        let degree = floor(10 * (CGFloat(self.degree(indexPath)) + floatPoint)) / 10
        return degree
    }
    
    fileprivate func clearRuler() {
        self.rulerCollectionView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(100 * NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)) {
            UIView.animate(withDuration: 0.1, animations: {
                self.clearRotation(false)
            }, completion: { (complete) in
                self.rulerCollectionView.isHidden = false
                self.ignoreRotation = false
                self.cursorView.isHidden = false
            }) 
        }
    }
    
    fileprivate func addMaskIfExist() {
        if let innerPath = self.shapeLayerPath {
            let mask: CAShapeLayer = CAShapeLayer()
            mask.frame = self.contentView.bounds
            
            let path = UIBezierPath(rect: self.contentView.bounds)
            innerPath.apply(CGAffineTransform(translationX: self.imageScrollView.frame.origin.x, y: self.imageScrollView.frame.origin.y))
            path.append(innerPath)
            
            mask.path = path.cgPath
            mask.fillRule = kCAFillRuleEvenOdd
            
            self.maskView.layer.mask = mask
            self.maskView.isHidden = false
            self.maskView.alpha = 1.0
        }
    }
    
    fileprivate func clearRotation(_ animated: Bool) {
        let animations = {
            self.additionalDegreeForRotation = 0
            self.rulerCollectionView.scrollToItem(at: IndexPath(row: self.middleIndexOfCells, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
        }
        
        if animated {
            UIView.animate(withDuration: 0.5, animations: animations, completion:nil)
        } else {
            animations()
        }
        
    }

}

extension RotationPhotoViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RulerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "rulerCell", for: indexPath) as! RulerCell
        
        cell.degreeLabel.text = degreeString(indexPath)
        
        cell.showLeft = true
        cell.showRight = true
        
        if (indexPath.row == 0) {
            cell.showLeft = false
        } else if (indexPath.row == numberOfCells - 1) {
            cell.showRight = false
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        hideDim()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            hideDim()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.ignoreRotation {
            return
        }
        
        self.maskView.alpha = 0.5
        
        self.rotationImageView(false)
    }
    
    fileprivate func hideDim() {
        self.maskView.alpha = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1000 * NSEC_PER_MSEC)) / Double(NSEC_PER_SEC)) {
            self.degreeLabel.isHidden = true
        }
    }
}

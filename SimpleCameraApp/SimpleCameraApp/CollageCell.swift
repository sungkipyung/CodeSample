//
//  CollageCell.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 14..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class CollageCell: UIView, UIScrollViewDelegate {
//
//    @IBOutlet weak var marginTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var marginLeftConstraint: NSLayoutConstraint!
//    @IBOutlet weak var marginRightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var marginBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cameraPreview: CameraPreview!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageScrollViewOriginX: NSLayoutConstraint!
    @IBOutlet weak var imageScrollViewOriginY: NSLayoutConstraint!
    
    @IBOutlet weak var imageScrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageScrollViewHeight: NSLayoutConstraint!
    
    weak var imageView: UIImageView!
    @IBOutlet weak var lineView: UIView!
    private static let BORDER_WIDTH:CGFloat = 0
    
    var shapeLayerPath: UIBezierPath? {
        didSet (newLayer) {
            let shapeLayerPath = self.shapeLayerPath!
            let path = shapeLayerPath.CGPath
            
            let mask: CAShapeLayer = CAShapeLayer()
            mask.path = path
            self.layer.mask = mask
            
            self.lineView.layer.sublayers?.forEach({ (sublayer) in
                sublayer.removeFromSuperlayer()
            })
            if (self.imageView.image == nil) {
                let line = CAShapeLayer.init()
                line.path = path
                line.lineDashPattern = [8, 8]
                line.lineWidth = 2
                line.fillColor = UIColor.clearColor().CGColor
                line.strokeColor = UIColor.whiteColor().CGColor
                self.lineView.layer.addSublayer(line)
            }
            
            let frame = CGRectInset(CGPathGetPathBoundingBox(path), CollageCell.BORDER_WIDTH, CollageCell.BORDER_WIDTH)
            
            self.imageScrollViewOriginX.constant = frame.origin.x == CGFloat.infinity ? 0 : frame.origin.x
            self.imageScrollViewOriginY.constant = frame.origin.y == CGFloat.infinity ? 0 : frame.origin.y
            self.imageScrollViewWidth.constant = frame.size.width
            self.imageScrollViewHeight.constant = frame.size.height
            
        }
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if let path:UIBezierPath =  self.shapeLayerPath {
            return path.containsPoint(point)
        } else {
            return super.pointInside(point, withEvent: event)
        }
    }
    
    override var frame: CGRect {
        didSet {
            // update subview's bounds
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        self.imageScrollView.delegate = self
//        self.imageScrollView.frame = CGRectInset(self.bounds, CollageCell.BORDER_WIDTH, CollageCell.BORDER_WIDTH)
//        
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageScrollView.addSubview(imageView)
        self.imageView = imageView
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

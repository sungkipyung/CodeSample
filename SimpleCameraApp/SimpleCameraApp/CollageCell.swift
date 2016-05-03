//
//  CollageCell.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 14..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

@IBDesignable
class CollageCell: UIView, UIScrollViewDelegate {

    @IBOutlet weak var cameraPreview: CameraPreview!
    @IBOutlet weak var imageScrollView: UIScrollView!

    weak var imageView: UIImageView!
    
    @IBOutlet weak var lineView: UIView!
    private static let BORDER_WIDTH:CGFloat = 0
    
    var shapeLayerPath: UIBezierPath? {
        didSet (newLayer) {
            let shapeLayerPath = self.shapeLayerPath!
            
//            shapeLayerPath.applyTransform(CGAffineTransformMakeScale(0.9, 0.9))
//            let tx = self.frame.size.width * 0.1
//            let ty = self.frame.size.height * 0.1
//            shapeLayerPath.applyTransform(CGAffineTransformMakeTranslation(tx, ty))
            
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
        }
    }
    func pointInside(point: CGPoint) -> Bool {
        if let path:UIBezierPath =  self.shapeLayerPath {
            return path.containsPoint(point)
        }
        return false
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
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageScrollView.addSubview(imageView)
        self.imageView = imageView
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.superview?.bringSubviewToFront(self)
    }
    
    @IBAction func imageScrollViewTapped(sender: AnyObject) {
        self.superview?.bringSubviewToFront(self)
    }
}

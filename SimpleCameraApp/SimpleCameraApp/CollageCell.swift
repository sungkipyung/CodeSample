//
//  CollageCell.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 14..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class CollageCell: UIView {
//
//    @IBOutlet weak var marginTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var marginLeftConstraint: NSLayoutConstraint!
//    @IBOutlet weak var marginRightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var marginBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var contentView: UIView!
    
    var shapeLayerPath: UIBezierPath! {
        didSet {
            if let subLayers: Array<CALayer> = self.layer.sublayers {
                for layer in subLayers {
                    layer.removeFromSuperlayer()
                }
            }
            let mask: CAShapeLayer = CAShapeLayer.init()
            mask.path = self.shapeLayerPath.CGPath
            self.layer.mask = mask
            
            let line = CAShapeLayer.init()
            line.path = self.shapeLayerPath.CGPath
            line.lineWidth = 2
            line.fillColor = UIColor.clearColor().CGColor
            line.strokeColor = UIColor.whiteColor().CGColor
            self.layer.addSublayer(line)
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
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  RulerCell.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 9..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class RulerCell: UICollectionViewCell {
    @IBOutlet weak var degreeLabel: UILabel!
    
    var showLeft: Bool! = false {
        didSet {
            if showLeft! == true {
               self.leftLayer.hidden = false
            } else {
               self.leftLayer.hidden = true
            }
        }
    }
    
    var showRight: Bool! = false {
        didSet {
            if showRight! == true {
                self.rightLayer.hidden = false
            } else {
                self.rightLayer.hidden = true
            }
        }
    }

    private weak var leftLayer: CALayer!
    private weak var centerLayer: CALayer!
    private weak var rightLayer: CALayer!
    
    private let SMALL_H: CGFloat = 20
    private let CENTER_H: CGFloat = 29
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
    }
     */
    
    override func awakeFromNib() {
        let leftLayer = createLeftLayer()
        let centerLayer = createCenterLayer()
        let rightLayer = createRightLayer()
        
        self.layer.addSublayer(leftLayer)
        self.layer.addSublayer(centerLayer)
        self.layer.addSublayer(rightLayer)
        
        self.leftLayer = leftLayer
        self.rightLayer = rightLayer
        self.centerLayer = centerLayer
    }
    
    private func createLeftLayer() -> CALayer {
        let lineShapeLayer = CAShapeLayer()
        
        lineShapeLayer.lineWidth = 0.5
        lineShapeLayer.strokeColor = UIColor.whiteColor().CGColor
        
        var cursor: CGFloat = 5
        
        let path: UIBezierPath = UIBezierPath()
        
        path.moveToPoint(CGPoint(x: cursor, y: 0))
        path.addLineToPoint(CGPoint(x: cursor, y: SMALL_H))
        
        cursor = 15
        path.moveToPoint(CGPoint(x: cursor, y: 0))
        path.addLineToPoint(CGPoint(x: cursor, y: SMALL_H))
        
        
        lineShapeLayer.path = path.CGPath
        return lineShapeLayer
    }
    
    private func createRightLayer() -> CALayer {
        let lineShapeLayer = CAShapeLayer()
            
        lineShapeLayer.lineWidth = 0.5
        lineShapeLayer.strokeColor = UIColor.whiteColor().CGColor
        
        var cursor: CGFloat = 5
        
        let path: UIBezierPath = UIBezierPath()
        
        cursor = 35
        path.moveToPoint(CGPoint(x: cursor, y: 0))
        path.addLineToPoint(CGPoint(x: cursor, y: SMALL_H))
        
        cursor = 45
        path.moveToPoint(CGPoint(x: cursor, y: 0))
        path.addLineToPoint(CGPoint(x: cursor, y: SMALL_H))
        
        lineShapeLayer.path = path.CGPath
        return lineShapeLayer
    }
    
    private func createCenterLayer() -> CALayer {
        let lineShapeLayer = CAShapeLayer()
        
        lineShapeLayer.lineWidth = 0.5
        lineShapeLayer.strokeColor = UIColor.whiteColor().CGColor
        
        
        var cursor: CGFloat = 5
        
        let path: UIBezierPath = UIBezierPath()
        
        cursor = 25
        path.moveToPoint(CGPoint(x: cursor, y: 0))
        path.addLineToPoint(CGPoint(x: cursor, y: CENTER_H))
        
        lineShapeLayer.path = path.CGPath
        return lineShapeLayer
    }
}

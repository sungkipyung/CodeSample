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
               self.leftLayer.isHidden = false
            } else {
               self.leftLayer.isHidden = true
            }
        }
    }
    
    var showRight: Bool! = false {
        didSet {
            if showRight! == true {
                self.rightLayer.isHidden = false
            } else {
                self.rightLayer.isHidden = true
            }
        }
    }

    fileprivate weak var leftLayer: CALayer!
    fileprivate weak var centerLayer: CALayer!
    fileprivate weak var rightLayer: CALayer!
    
    fileprivate let SMALL_H: CGFloat = 20
    fileprivate let CENTER_H: CGFloat = 29
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
    
    fileprivate func createLeftLayer() -> CALayer {
        let lineShapeLayer = CAShapeLayer()
        
        lineShapeLayer.lineWidth = 0.5
        lineShapeLayer.strokeColor = UIColor.white.cgColor
        
        var cursor: CGFloat = 5
        
        let path: UIBezierPath = UIBezierPath()
        
        path.move(to: CGPoint(x: cursor, y: 0))
        path.addLine(to: CGPoint(x: cursor, y: SMALL_H))
        
        cursor = 15
        path.move(to: CGPoint(x: cursor, y: 0))
        path.addLine(to: CGPoint(x: cursor, y: SMALL_H))
        
        
        lineShapeLayer.path = path.cgPath
        return lineShapeLayer
    }
    
    fileprivate func createRightLayer() -> CALayer {
        let lineShapeLayer = CAShapeLayer()
            
        lineShapeLayer.lineWidth = 0.5
        lineShapeLayer.strokeColor = UIColor.white.cgColor
        
        var cursor: CGFloat = 5
        
        let path: UIBezierPath = UIBezierPath()
        
        cursor = 35
        path.move(to: CGPoint(x: cursor, y: 0))
        path.addLine(to: CGPoint(x: cursor, y: SMALL_H))
        
        cursor = 45
        path.move(to: CGPoint(x: cursor, y: 0))
        path.addLine(to: CGPoint(x: cursor, y: SMALL_H))
        
        lineShapeLayer.path = path.cgPath
        return lineShapeLayer
    }
    
    fileprivate func createCenterLayer() -> CALayer {
        let lineShapeLayer = CAShapeLayer()
        
        lineShapeLayer.lineWidth = 0.5
        lineShapeLayer.strokeColor = UIColor.white.cgColor
        
        
        var cursor: CGFloat = 5
        
        let path: UIBezierPath = UIBezierPath()
        
        cursor = 25
        path.move(to: CGPoint(x: cursor, y: 0))
        path.addLine(to: CGPoint(x: cursor, y: CENTER_H))
        
        lineShapeLayer.path = path.cgPath
        return lineShapeLayer
    }
}

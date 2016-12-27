//
//  LayoutGripView.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 15..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

//typealias LayoutGripViewDidChangeLocation = (view:LayoutGripView, origin:CGPoint) -> (Void)
typealias LayoutGripViewDidChangeLocation = (_ view: LayoutGripView, _ originalPosition: CGPoint, _ incX: CGFloat, _ incY: CGFloat) -> (Void)

class LayoutGripView: UIView {
    fileprivate var originalPosition: CGPoint?
    fileprivate var touchOffset: CGPoint?
    
    var onChangeLocation:LayoutGripViewDidChangeLocation?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = min(frame.width, frame.height) / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        originalPosition = self.center
        if let position:CGPoint = touches.first?.location(in: self.superview)  {
            touchOffset = position
        }
        self.alpha = 0.8
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let loc:CGPoint = touches.first!.location(in: self.superview) {
            let deltaX = loc.x - self.touchOffset!.x
            let deltaY = loc.y - self.touchOffset!.y
            self.onChangeLocation?(self, self.originalPosition!, deltaX, deltaY)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 1.0
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    

}

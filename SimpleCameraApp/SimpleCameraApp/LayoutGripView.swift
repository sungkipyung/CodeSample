//
//  LayoutGripView.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 15..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

typealias LayoutGripViewDidChangeLocation = (view:LayoutGripView, origin:CGPoint) -> (Void)

class LayoutGripView: UIView {
    private var originalPosition: CGPoint?
    private var touchOffset: CGPoint?
    
    var onChangeLocation:LayoutGripViewDidChangeLocation?
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        originalPosition = self.center
        if let position:CGPoint = touches.first?.locationInView(self.superview)  {
            touchOffset = CGPoint(x: self.center.x - position.x, y: self.center.y - position.y)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let loc:CGPoint = touches.first!.locationInView(self.superview) {
            let deltaX = fabs(loc.x - self.touchOffset!.x)
            let deltaY = fabs(loc.y - self.touchOffset!.y)
            self.onChangeLocation?(view: self, origin: CGPoint(x: deltaX, y: deltaY))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
    }
    

}

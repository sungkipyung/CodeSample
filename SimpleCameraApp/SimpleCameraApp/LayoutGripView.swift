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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = min(frame.width, frame.height) / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        originalPosition = self.center
        if let position:CGPoint = touches.first?.locationInView(self.superview)  {
            touchOffset = position
        }
        self.alpha = 0.8
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let loc:CGPoint = touches.first!.locationInView(self.superview) {
            let deltaX = loc.x - self.touchOffset!.x
            let deltaY = loc.y - self.touchOffset!.y
            self.onChangeLocation?(view: self, origin: CGPoint(x: self.originalPosition!.x + deltaX, y: self.originalPosition!.y + deltaY))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.alpha = 1.0
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
    }
    

}

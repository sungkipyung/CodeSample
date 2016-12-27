//
//  UIView+Extensions.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 23..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

extension UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    /**
     // http://stackoverflow.com/questions/26824513/zoom-a-rotated-image-inside-scroll-view-to-fit-fill-frame-of-overlay-rect
     */
    func rotateAndSizeToFit(_ size : CGSize, degree: CGFloat) {
        let image_rect_width = size.width
        let image_rect_height = size.height
        
        let radian = degree / 180.0 * CGFloat(M_PI)
        let absRad = abs(degree) / 180.0 * CGFloat(M_PI)
        
        let a = image_rect_height * sin(absRad)
        let b = image_rect_width * cos(absRad)
        let c = image_rect_width * sin(absRad)
        let d = image_rect_height * cos(absRad)
        
        let crop_rect_width = size.width
        let crop_rect_height = size.height
        
        let scaleFactor = max(crop_rect_width / (a + b), crop_rect_height / (c + d))
        
        let t = CGAffineTransform(rotationAngle: radian)
        let t2 = CGAffineTransform(scaleX: 1 / scaleFactor, y: 1 / scaleFactor)
        self.transform = t.concatenating(t2)
    }
}

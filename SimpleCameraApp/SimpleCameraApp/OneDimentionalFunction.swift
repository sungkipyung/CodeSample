//
//  OneDimentionalFunction.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 15..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

// y = ax + b
class OneDimentionalFunction: NSObject {
    var a: CGFloat
    var b: CGFloat
    
    init(a: CGFloat, b: CGFloat) {
        self.a = a
        self.b = b
    }
    
    /**
     평행은 해를 뱉지 않는다.
     */
    func intersectionPointWith(oneDimentionalFunction:OneDimentionalFunction) -> (CGPoint?) {
        
        if (self.a - oneDimentionalFunction.a == 0) {
            return nil
        }
        
        let x = -1 * (self.b - oneDimentionalFunction.b) / (self.a - oneDimentionalFunction.a)
        let y = a * x + b
        
        return CGPoint(x:x, y:y)
    }
}

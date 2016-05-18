//
//  OneDimentionalFunction.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 15..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

// ax + by + c = 0
struct OneDimentionalFunction {
    var a: CGFloat
    var b: CGFloat
    var c: CGFloat
}
extension OneDimentionalFunction {
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
    
    static func createFunctionBetweenFromPoint(from: CGPoint, to: CGPoint) -> OneDimentionalFunction {
        let a = (to.y - from.y) / (to.x - from.x)
        let b: CGFloat = -1
        let c = (from.y - a * from.x)
        return OneDimentionalFunction(a: a, b: b, c: c)
    }
    
    func orthogonalFuncitonPassPoint(point: CGPoint) -> OneDimentionalFunction {
        var a: CGFloat = 0
        var b: CGFloat = 0
        var c: CGFloat = 0
        // ax + by + c = 0
        if self.a == 0 && self.b != 0 {
            // y = 1, y = -1 과 같은 특수 케이스
            a = 0
            b = 1
            c = -1 * point.y
        } else if self.a != 0 && self.b == 0 {
            // x = 1, x = 2와 같은 특수한 케이스
            a = 1
            b = 0
            c = -1 * point.x
        }
        else {
            a = -1 / self.a
            b = -1
            c = point.y + point.x / self.a
        }
        return OneDimentionalFunction(a: a, b: b, c: c)
    }
}

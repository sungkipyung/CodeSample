//
//  Layout.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 14..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit
/**
 Layout Class for collage
 */
typealias UnitPolygon = Array<NSValue>
struct Layout {
//    var pictures: Array<UIImage>?
//    var polygons: Array<UIBezierPath>?
//    var margin: CGFloat = 0
//    var borderWidth: CGFloat = 0
//    var curve: CGFloat = 0
//    var backgroundImage: UIImage?
    
    let numberOfCells: Int
    
    // variablePoint
    var alpha: CGFloat
    var point: CGPoint
    
    func polygons() -> Array<UnitPolygon>  {
        let p1 = [
            NSValue.init(CGPoint: CGPoint(x:0, y:0)),
            NSValue.init(CGPoint: CGPoint(x:alpha, y:0)),
            NSValue.init(CGPoint: CGPoint(x:alpha, y:1)),
            NSValue.init(CGPoint: CGPoint(x:0, y:1)),
            NSValue.init(CGPoint: CGPoint(x:0, y:0)),
        ]
        let p2 = [
            NSValue.init(CGPoint: CGPoint(x:alpha, y:0)),
            NSValue.init(CGPoint: CGPoint(x:1, y:0)),
            NSValue.init(CGPoint: CGPoint(x:1, y:1)),
            NSValue.init(CGPoint: CGPoint(x:alpha, y:1)),
            NSValue.init(CGPoint: CGPoint(x:alpha, y:0))
        ]
        return [p1, p2]
    }
    
    init(numberOfCells: Int, alpha: CGFloat, point:CGPoint) {
        self.numberOfCells = numberOfCells
        self.alpha = alpha
        self.point = point
    }
}

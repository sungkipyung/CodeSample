//
//  Layout.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 15..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit
/*
 Collage Type
    Axis
    1 variable = 1 button for axis move
    
    Single Point
    Points Ref Single Point
 
    y = ax + b
    y = a'x + b'
    intersection of two function
    Points ref intersection
 */
typealias UnitPolygon = [NSValue]

protocol Layout {
    func layout() -> [UnitPolygon]
    func numberOfCells() -> Int
    func getGrapPoints() -> [NSValue]
}
// input : variable vector
// output : unit polygon points reference variable vector


// MARK: Define AxisLayout Type
typealias AxisLayoutPolygons = [CGFloat] -> [UnitPolygon]
typealias AxisLayoutGrapPoints = [CGFloat] -> [NSValue]
typealias AxisLayoutGrapButtonPointChange = (CGPoint, [CGFloat]) -> [CGFloat]
struct AxisLayout {
    let cellCount: Int
    
    var vs: [CGFloat]
    let originalVS:[CGFloat]
    var grapPoints: AxisLayoutGrapPoints
    var grapPointsChangeHandlers:[AxisLayoutGrapButtonPointChange]
    let points:AxisLayoutPolygons
}

extension AxisLayout : Layout {
    func layout() -> [UnitPolygon] {
        return self.points(self.vs)
    }
    func getGrapPoints() -> [NSValue] {
        return self.grapPoints(self.vs)
    }
    func numberOfCells() -> Int {
        return cellCount
    }
    mutating func changeGrapPoints(index:Int, point:CGPoint) -> [CGFloat] {
        return self.grapPointsChangeHandlers[index](point, self.vs)
    }
}
// MARK: End define AxisLayout Type


// MARK: Utilities
func PointObj(x:CGFloat, y:CGFloat) -> NSValue {
    return NSValue(CGPoint: CGPoint(x: x, y: y))
}
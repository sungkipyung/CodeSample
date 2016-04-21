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
    mutating func changeGrapPoints(index:Int, unitPoint:CGPoint) -> ([CGFloat], [CGFloat])
//    mutating func changeGrapPoints(index:Int, oldUnitPoint:CGPoint, incX: CGFloat, incY: CGFloat) -> (xs:[CGFloat], ys:[CGFloat])
}
// input : variable vector
// output : unit polygon points reference variable vector

// MARK: Define AxisLayout Type
//typealias AxisLayoutPolygons = [CGFloat] -> [UnitPolygon]
//typealias AxisLayoutGrapPoints = [CGFloat] -> [NSValue]
//typealias AxisLayoutGrapButtonPointChange = (CGPoint, [CGFloat]) -> [CGFloat]

//struct AxisLayout {
//    let cellCount: Int
//    
//    // xs, ys로 분리하는게 좀 더 이해하기 좋을 것 같습니다.
//    var vs: [CGFloat]
//    
//    let originalVS:[CGFloat]
//    var grapPoints: AxisLayoutGrapPoints
//    var grapPointsChangeHandlers:[AxisLayoutGrapButtonPointChange]
//    let points:AxisLayoutPolygons
//}

//extension AxisLayout : Layout {
//    func layout() -> [UnitPolygon] {
//        return self.points(self.vs)
//    }
//    func getGrapPoints() -> [NSValue] {
//        return self.grapPoints(self.vs)
//    }
//    func numberOfCells() -> Int {
//        return cellCount
//    }
//    mutating func changeGrapPoints(index:Int, unitPoint:CGPoint) -> ([CGFloat], [CGFloat]) {
//        return self.grapPointsChangeHandlers[index](unitPoint, self.vs)
//    }
//}
// MARK: End define AxisLayout Type

//typealias LayoutPolygons = (xs:[CGFloat], ys:[CGFloat]) -> [UnitPolygon]
typealias LayoutPoints = (xs:[CGFloat], ys:[CGFloat]) -> [NSValue]
typealias LayoutPolygons = (ps:[NSValue]) -> [UnitPolygon]
typealias LayoutGrapPoints = (xs:[CGFloat], ys:[CGFloat]) -> [NSValue]
typealias LayoutGrapPointsChangeHandler = (newUnitGrapPoint:CGPoint, xs:[CGFloat], ys:[CGFloat]) -> (xs:[CGFloat], ys:[CGFloat])
//typealias LayoutGrapPointsChangeHandler = (oldUnitGrapPoint: CGPoint, incX: CGFloat, incY: CGFloat, xs:[CGFloat], ys:[CGFloat]) -> (xs:[CGFloat], ys:[CGFloat])
typealias LayoutGrapPointsChangeHandlers = [LayoutGrapPointsChangeHandler]

struct NormalLayout {
    var xs: [CGFloat]
    var ys: [CGFloat]
    let cellCount: Int
    // grap points
    var gs: LayoutGrapPoints
    var grapPointsChangeHandlers:LayoutGrapPointsChangeHandlers
    // points
    var ps:LayoutPoints
    var polygons:LayoutPolygons
    
//    private var original_xs: [CGFloat]
//    private var original_ys: [CGFloat]
}

extension NormalLayout : Layout {
    func layout() -> [UnitPolygon] {
        let ps = self.ps(xs: xs, ys: ys)
        return self.polygons(ps: ps)
    }
    func numberOfCells() -> Int {
        return cellCount
    }
    func getGrapPoints() -> [NSValue] {
        return self.gs(xs: xs, ys: ys)
    }
    func changeGrapPoints(index: Int, unitPoint: CGPoint) -> ([CGFloat], [CGFloat]) {
        return self.grapPointsChangeHandlers[index](newUnitGrapPoint: unitPoint, xs: xs, ys: ys)
    }
}

struct PointLayout {
    let cellCount: Int
}

// MARK: Utilities
func PointObj(x:CGFloat, y:CGFloat) -> NSValue {
    return NSValue(CGPoint: CGPoint(x: x, y: y))
}
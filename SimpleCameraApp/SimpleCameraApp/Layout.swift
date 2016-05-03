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
typealias GeneratePS = (xs:[CGFloat], ys:[CGFloat], border: CGFloat, size: CGSize) -> [CGPoint]
//typealias Polygon = [CGPoint]
struct Polygon {
    let origin: CGPoint
    let points: [CGPoint]
}

typealias GeneratePolygons = (ps: [CGPoint]) -> [Polygon]
typealias GenerateGS = (xs: [CGFloat], ys: [CGFloat], size: CGSize) -> [CGPoint]
typealias GrapPointChangeHandler = (newUnitGrapPoint: CGPoint, xs: [CGFloat], ys: [CGFloat]) -> ([CGFloat], [CGFloat])

protocol Copy {
    func copy() -> AnyObject
}

class Layout : Copy {
    var size: CGSize! {
        didSet {
            updatePS()
        }
    }
    var curvature:CGFloat! // 0 ~ 100
    
    var border: CGFloat! {
        didSet {
            updatePS()
        }
    }
    var xs: [CGFloat]! {
        didSet {
            updatePS()
        }
    }
    var ys: [CGFloat]! {
        didSet {
            updatePS()
        }
    }
    
    private var ps: [CGPoint]!
    
    let generatePS: GeneratePS!

    let cellCount: Int
    let generatePolygons:GeneratePolygons!
    // grap points
    let generateGS:GenerateGS
    let gsChangeHandlers: [GrapPointChangeHandler]
    
    required init (
        size: CGSize
        , curvature: CGFloat
        , border: CGFloat
        , xs: [CGFloat]
        , ys:[CGFloat]
        , generatePS: GeneratePS
        , cellCount: Int
        , generatePolygons: GeneratePolygons
        , generateGS: GenerateGS
        , gsChangeHandlers: [GrapPointChangeHandler]) {
        
        self.size = size
        self.curvature = curvature
        self.border = border
        self.cellCount = cellCount
        self.xs = xs
        self.ys = ys
        self.generatePS = generatePS
        self.generatePolygons = generatePolygons
        self.generateGS = generateGS
        self.gsChangeHandlers = gsChangeHandlers
        updatePS()
    }
    private func updatePS() {
        self.ps = self.generatePS(xs:xs, ys:ys, border: border, size: size)
    }

    func layout() -> [Polygon] {
        return self.generatePolygons(ps:self.ps)
    }
    func grapPoints() -> [CGPoint] {
        return self.generateGS(xs: xs, ys: ys, size: size)
    }
    func changeGrapPoints(index: Int, unitPoint: CGPoint) -> ([CGFloat], [CGFloat]) {
        return self.gsChangeHandlers[index](newUnitGrapPoint: unitPoint, xs: xs, ys: ys)
    }
    
    func copy() -> AnyObject {
        return Layout(size: size, curvature: curvature, border: border, xs: Array(xs), ys: Array(ys), generatePS: generatePS, cellCount: cellCount, generatePolygons: generatePolygons, generateGS: generateGS, gsChangeHandlers: gsChangeHandlers)
    }
}

// MARK: Utilities
func PointObj(x:CGFloat, y:CGFloat) -> NSValue {
    return NSValue(CGPoint: CGPoint(x: x, y: y))
}
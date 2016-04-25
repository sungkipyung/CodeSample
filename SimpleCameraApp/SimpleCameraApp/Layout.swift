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
typealias Polygon = [CGPoint]
typealias GeneratePolygons = (ps: [CGPoint]) -> [Polygon]
typealias GenerateGS = (xs: [CGFloat], ys: [CGFloat], size: CGSize) -> [CGPoint]
typealias GrapPointChangeHandler = (newUnitGrapPoint: CGPoint, xs: [CGFloat], ys: [CGFloat]) -> ([CGFloat], [CGFloat])

class Layout {
    var size: CGSize! {
        didSet {
            updatePS()
        }
    }
    var cornerRadius:CGFloat!
    
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
    
    init (
        size: CGSize
        , cornerRadius: CGFloat
        , border: CGFloat
        , xs: [CGFloat]
        , ys:[CGFloat]
        , generatePS: GeneratePS
        , cellCount: Int
        , generatePolygons: GeneratePolygons
        , generateGS: GenerateGS
        , gsChangeHandlers: [GrapPointChangeHandler]) {
        
        self.size = size
        self.cornerRadius = cornerRadius
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
}

// MARK: Utilities
func PointObj(x:CGFloat, y:CGFloat) -> NSValue {
    return NSValue(CGPoint: CGPoint(x: x, y: y))
}
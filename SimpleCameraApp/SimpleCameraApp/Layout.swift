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
    var origin: CGPoint
    var points: [CGPoint]
    var curvature: CGFloat
}

extension Polygon {
    func copy() -> Polygon {
        var copyPoints = Array<CGPoint>()
        self.points.forEach { (point) in
            copyPoints.append(point)
        }
        let copyObj = Polygon(origin: origin, points: copyPoints, curvature: self.curvature)
        return copyObj
    }
    
    func path() -> UIBezierPath {
        let path = UIBezierPath()
        
        for (index, value) in self.points.enumerate() {
            let newPoint = value
            
            if (index == 0) {
                path.moveToPoint(newPoint)
            }
            
            if (curvature == 0) {
                if (index != 0) {
                    path.addLineToPoint(newPoint)
                }
            }
            else {
                let from = self.points[index - 1 < 0 ? self.points.count - 1 : index - 1]
                let via = value
                let to = self.points[(index + 1) % self.points.count]
                
                let maxRadius = min(from.distanceTo(via), via.distanceTo(to)) / 2
                if (maxRadius > 0) {
                    let radius = self.curvature * maxRadius
                    let cornerPoint = self.roundedCorner(from, via: via, to: to, radius: radius)
                    path.addArcWithCenter(cornerPoint.centerPoint, radius: radius, startAngle: cornerPoint.startAngle, endAngle: cornerPoint.endAngle, clockwise: true)
                }
            }
        }
        path.closePath()
        
        return path
    }
    
    private func roundedCorner(from: CGPoint, via: CGPoint, to: CGPoint, radius: CGFloat) -> CornerPoint {
        let fromAngle = atan2f(Float(via.y - from.y), Float(via.x - from.x))
        let toAngle = atan2f(Float(to.y - via.y), Float(to.x - via.x))
        
        let fromOffset: CGVector = CGVector(dx: CGFloat(-sinf(fromAngle)) * radius, dy: CGFloat(cosf(fromAngle)) * radius)
        let toOffset: CGVector = CGVector(dx: CGFloat(-sinf(toAngle)) * radius, dy: CGFloat(cosf(toAngle)) * radius)
        
        let x1 = from.x + fromOffset.dx
        let y1 = from.y + fromOffset.dy
        
        let x2 = via.x + fromOffset.dx
        let y2 = via.y + fromOffset.dy
        
        let x3 = via.x + toOffset.dx
        let y3 = via.y +  toOffset.dy
        
        let x4 = to.x + toOffset.dx
        let y4 = to.y + toOffset.dy
        
        let intersectionX = ((x1*y2-y1*x2)*(x3-x4) - (x1-x2)*(x3*y4-y3*x4)) / ((x1-x2)*(y3-y4) - (y1-y2)*(x3-x4));
        let intersectionY = ((x1*y2-y1*x2)*(y3-y4) - (y1-y2)*(x3*y4-y3*x4)) / ((x1-x2)*(y3-y4) - (y1-y2)*(x3-x4));
        
        let intersection = CGPointMake(intersectionX, intersectionY);
        
        let pi = Float(M_PI_2)
        let corner = CornerPoint(centerPoint: intersection, startAngle: CGFloat(fromAngle - pi), endAngle: CGFloat(toAngle - pi))
        
        return corner;
        
    }
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

    func polygons() -> [Polygon] {
        var polygons = self.generatePolygons(ps:self.ps)
        
        for (index, _) in polygons.enumerate() {
            polygons[index].curvature = self.curvature
        }
        return polygons
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
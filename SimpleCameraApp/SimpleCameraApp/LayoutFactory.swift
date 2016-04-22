//
//  LayoutFactory.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 20..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class LayoutFactory: NSObject {
    static let sharedInstance = LayoutFactory()
    
    private var layouts:[Layout]!
    
    override init() {
        super.init()
        var layoutArray: [Layout] = []
        
        layoutArray.append(normalLayout())
        layoutArray.append(axisLayout())
        
        self.layouts = layoutArray
    }
    
    private func normalLayout() -> NormalLayout {
        let xs: [CGFloat] = [0.0, 1.0]
        let ys: [CGFloat] = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
        let cellCount = 3
        let gs:LayoutGrapPoints = { (xs, ys) -> [NSValue] in
            var newGS:[NSValue] = []
            newGS.append(PointObj((xs[0] + xs[1]) / 2, y: (ys[1] + ys[2]) / 2))
            newGS.append(PointObj((xs[0] + xs[1]) / 2, y: (ys[3] + ys[4]) / 2))
            return newGS
        }
        let grapPointsChangeHandlers:LayoutGrapPointsChangeHandlers = [
            // g0 changed
            // LayoutGrapPointsChangeHandler
            { (newUnitGrapPoint:CGPoint, xs: [CGFloat], ys: [CGFloat]) -> (xs: [CGFloat], ys: [CGFloat]) in
                var newYS = Array(ys)
                let gs:[NSValue] = gs(xs: xs, ys: ys)
                
                // 0 < newUnitGrapPoint.y < gs[1].CGPointValue().y
                let newUnitGrapPointY = min(max(newUnitGrapPoint.y, 0), gs[1].CGPointValue().y)
                
                newYS[1] = newUnitGrapPointY - 0.1
                newYS[2] = newUnitGrapPointY + 0.1
                
                return (xs:xs, ys:newYS)
            },
            // g1 changed
            { (newUnitGrapPoint:CGPoint, xs: [CGFloat], ys: [CGFloat]) -> (xs: [CGFloat], ys: [CGFloat]) in
                var newYS: [CGFloat] = Array(ys)
                let gs:[NSValue] = gs(xs: xs, ys: ys)
                
                // gs[0].CGPointValue().y < newUnitGrapPoint.y < 1
                let newUnitGrapPointY = min(max(newUnitGrapPoint.y, gs[0].CGPointValue().y), 1)
                
                newYS[3] = newUnitGrapPointY - 0.1
                newYS[4] = newUnitGrapPointY + 0.1
                
                return (xs:xs, ys:newYS)
            }
        ]
        let ps:LayoutPoints = { (xs, ys) -> [NSValue] in
            var newPS:[NSValue] = []
            newPS.append(PointObj(xs[0], y: ys[0])) // p0
            newPS.append(PointObj(xs[1], y: ys[0])) // p1
            newPS.append(PointObj(xs[1], y: ys[2])) // p2
            newPS.append(PointObj(xs[0], y: ys[1])) // p3
            
            newPS.append(PointObj(xs[0], y: ys[1])) // p4
            newPS.append(PointObj(xs[1], y: ys[2])) // p5
            newPS.append(PointObj(xs[1], y: ys[4])) // p6
            newPS.append(PointObj(xs[0], y: ys[3])) // p7
            
            newPS.append(PointObj(xs[0], y: ys[3])) // p8
            newPS.append(PointObj(xs[1], y: ys[4])) // p9
            newPS.append(PointObj(xs[1], y: ys[5])) // p10
            newPS.append(PointObj(xs[0], y: ys[5])) // p11
            
            return newPS
        }
        let polygons:LayoutPolygons = { (ps) -> [UnitPolygon] in
            var newPolygons: [UnitPolygon] = []
            
            // p0 -> p1 -> p2 -> p3 -> p0
            newPolygons.append([ps[0], ps[1], ps[2], ps[3], ps[0]])
            // p5 -> p6 -> p7 -> p8 -> p5
            newPolygons.append([ps[4], ps[5], ps[6], ps[7], ps[4]])
            // p8 -> p9 -> p10 -> p11 -> p8
            newPolygons.append([ps[8], ps[9], ps[10], ps[11], ps[8]])
            
            return newPolygons
        }
//
        let normalLayout = NormalLayout(xs: xs, ys: ys, cellCount: cellCount, gs: gs, grapPointsChangeHandlers: grapPointsChangeHandlers, ps: ps, polygons: polygons)
        return normalLayout
    }
    
    private func axisLayout() -> NormalLayout {
        let xs: [CGFloat] = [0, 0.2, 0.4, 0.6, 0.8, 1]
        let ys: [CGFloat] = [0, 0.2, 0.4, 0.6, 0.8, 1]
        let cellCount = 9
        
        let gs:LayoutGrapPoints = { (xs, ys) -> [NSValue] in
            var newGS:[NSValue] = []
            newGS.append(PointObj((xs[0] + xs[1]) / 2, y: (ys[1] + ys[2]) / 2))
            newGS.append(PointObj((xs[0] + xs[1]) / 2, y: (ys[3] + ys[4]) / 2))
            return newGS
        }
        
        
        let grapPointsChangeHandlers:LayoutGrapPointsChangeHandlers = [
            // g0 changed
            // LayoutGrapPointsChangeHandler
            { (newUnitGrapPoint:CGPoint, xs: [CGFloat], ys: [CGFloat]) -> (xs: [CGFloat], ys: [CGFloat]) in
                var newYS = Array(ys)
                let gs:[NSValue] = gs(xs: xs, ys: ys)
                
                // 0 < newUnitGrapPoint.y < gs[1].CGPointValue().y
                let newUnitGrapPointY = min(max(newUnitGrapPoint.y, 0), gs[1].CGPointValue().y)
                
                newYS[1] = newUnitGrapPointY - 0.1
                newYS[2] = newUnitGrapPointY + 0.1
                
                return (xs:xs, ys:newYS)
            },
            // g1 changed
            { (newUnitGrapPoint:CGPoint, xs: [CGFloat], ys: [CGFloat]) -> (xs: [CGFloat], ys: [CGFloat]) in
                var newYS: [CGFloat] = Array(ys)
                let gs:[NSValue] = gs(xs: xs, ys: ys)
                
                // gs[0].CGPointValue().y < newUnitGrapPoint.y < 1
                let newUnitGrapPointY = min(max(newUnitGrapPoint.y, gs[0].CGPointValue().y), 1)
                
                newYS[3] = newUnitGrapPointY - 0.1
                newYS[4] = newUnitGrapPointY + 0.1
                
                return (xs:xs, ys:newYS)
            }
        ]
        let ps:LayoutPoints = { (xs, ys) -> [NSValue] in
            var newPS:[NSValue] = []
            newPS.append(PointObj(xs[0], y: ys[0])) // p0
            newPS.append(PointObj(xs[1], y: ys[0])) // p1
            newPS.append(PointObj(xs[1], y: ys[2])) // p2
            newPS.append(PointObj(xs[0], y: ys[1])) // p3
            
            newPS.append(PointObj(xs[0], y: ys[1])) // p4
            newPS.append(PointObj(xs[1], y: ys[2])) // p5
            newPS.append(PointObj(xs[1], y: ys[4])) // p6
            newPS.append(PointObj(xs[0], y: ys[3])) // p7
            
            newPS.append(PointObj(xs[0], y: ys[3])) // p8
            newPS.append(PointObj(xs[1], y: ys[4])) // p9
            newPS.append(PointObj(xs[1], y: ys[5])) // p10
            newPS.append(PointObj(xs[0], y: ys[5])) // p11
            
            return newPS
        }
        let polygons:LayoutPolygons = { (ps) -> [UnitPolygon] in
            var newPolygons: [UnitPolygon] = []
            
            // p0 -> p1 -> p2 -> p3 -> p0
            newPolygons.append([ps[0], ps[1], ps[2], ps[3], ps[0]])
            // p5 -> p6 -> p7 -> p8 -> p5
            newPolygons.append([ps[4], ps[5], ps[6], ps[7], ps[4]])
            // p8 -> p9 -> p10 -> p11 -> p8
            newPolygons.append([ps[8], ps[9], ps[10], ps[11], ps[8]])
            
            return newPolygons
        }
        //
        let normalLayout = NormalLayout(xs: xs, ys: ys, cellCount: cellCount, gs: gs, grapPointsChangeHandlers: grapPointsChangeHandlers, ps: ps, polygons: polygons)
        return normalLayout
    }
    
    func numberOfLayouts() -> Int {
        return 0;
    }
    
    func getLayout(index:Int, limit: Int) -> [Layout]? {
        if let result:ArraySlice<Layout> = layouts[index..<limit] {
            return Array(result)
        }
        return nil
    }
}

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
        
//        layoutArray.append(axisLayout())
        
        layoutArray.append(normalLayout())
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
            // p9 -> p10 -> p11 -> p12 -> p9
            newPolygons.append([ps[8], ps[9], ps[10], ps[11], ps[8]])
            
            return newPolygons
        }
//
        let normalLayout = NormalLayout(xs: xs, ys: ys, cellCount: cellCount, gs: gs, grapPointsChangeHandlers: grapPointsChangeHandlers, ps: ps, polygons: polygons)
        return normalLayout
    }
    
//    private func axisLayout() -> AxisLayout {
//        let vs:[CGFloat] = [1/3.0, 2/3.0, 1/3.0, 2/3.0,
//                            2/3.0, 1/3.0, 2/3.0, 1/3.0]
//        
//        let axisLayout = AxisLayout(cellCount: 9
//            , vs: vs
//            , originalVS: vs
//            , grapPoints: { (vs:[CGFloat]) -> [NSValue] in
//                return [
//                    PointObj(vs[0], y:vs[7]*0.5),
//                    PointObj(vs[1], y:vs[3]*0.75),
//                    
//                    PointObj(0.5 * (1 + vs[1]), y:vs[2]),
//                    PointObj(0.25 * (1 + 3 * vs[5]), y:vs[3]),
//                    
//                    PointObj(vs[4], y:(1 + vs[3]) / 2),
//                    PointObj(vs[5], y:(1 + 3 * vs[7]) * 0.25),
//                    
//                    PointObj(0.5 * vs[5], y:vs[6]),
//                    PointObj(3/4*vs[1], y:vs[7])
//                ]
//            }
//            , grapPointsChangeHandlers: [
//                // g0
//                { (point, vs) in var newVS = Array.init(vs)
//                    newVS[0] = max(min(point.x, vs[1]), 0)
//                    return newVS
//                },
//                // g1
//                { (point, vs) in var newVS = Array.init(vs)
//                    newVS[1] = max(min(point.x, 1), max(vs[0], vs[5]))
//                    return newVS
//                },
//                // g2
//                { (point, vs) in var newVS = Array.init(vs)
//                    newVS[2] = max(min(point.y, vs[3]), 0)
//                    return newVS
//                },
//                // g3
//                { (point, vs) in var newVS = Array.init(vs)
//                    newVS[3] = max(min(point.y, 1), max(vs[7], vs[2]))
//                    return newVS
//                },
//                // g4
//                { (point, vs) in var newVS = Array.init(vs)
//                    newVS[4] = max(min(point.x, 1), vs[5])
//                    return newVS
//                },
//                // g5
//                { (point, vs) in var newVS = Array.init(vs)
//                    newVS[5] = min(max(point.x, 0), min(vs[1], vs[4]))
//                    return newVS
//                },
//                // g6
//                { (point, vs) in var newVS = Array.init(vs)
//                    newVS[6] = max(min(point.y, 1), vs[7])
//                    return newVS
//                },
//                // g7
//                { (point, vs) in var newVS = Array.init(vs)
//                    newVS[7] = min(max(point.y, 0), min(vs[6], vs[3]))
//                    return newVS
//                },
//            ]
//            , points: { (vs:[CGFloat]) -> [UnitPolygon] in
//                return [
//                    [PointObj(0, y:0), PointObj(vs[0], y:0), PointObj(vs[0], y:vs[7]), PointObj(0, y:vs[7]), PointObj(0, y:0)], // 0
//                    [PointObj(vs[0], y:0), PointObj(vs[1], y:0), PointObj(vs[1], y:vs[7]), PointObj(vs[0], y:vs[7]), PointObj(vs[0], y:0)], // 1
//                    [PointObj(vs[1], y:0), PointObj(1, y:0), PointObj(1, y:vs[2]), PointObj(vs[1], y:vs[2]), PointObj(vs[1], y:0)], // 2
//                    [PointObj(vs[1], y:vs[2]), PointObj(1, y:vs[2]), PointObj(1, y:vs[3]), PointObj(vs[1], y:vs[3]), PointObj(vs[1], y:vs[2])], // 3
//                    
//                    [PointObj(vs[4], y:vs[3]), PointObj(1, y:vs[3]), PointObj(1, y:1), PointObj(vs[4], y:1), PointObj(vs[4], y:vs[3])], // 4
//                    [PointObj(vs[5], y:vs[3]), PointObj(vs[4], y:vs[3]), PointObj(vs[4], y:1), PointObj(vs[5], y:1), PointObj(vs[5], y:vs[3])], // 5
//                    [PointObj(0, y:vs[6]), PointObj(vs[5], y:vs[6]), PointObj(vs[5], y:1), PointObj(0, y:1), PointObj(0, y:vs[6])], // 6
//                    
//                    [PointObj(0, y:vs[7]), PointObj(vs[5], y:vs[7]), PointObj(vs[5], y:vs[6]), PointObj(0, y:vs[6]), PointObj(0, y:vs[7])], // 7
//                    
//                    [PointObj(vs[5], y:vs[7]), PointObj(vs[1], y:vs[7]), PointObj(vs[1], y:vs[3]), PointObj(vs[5], y:vs[3]), PointObj(vs[5], y:vs[7])], // 8
//                ]
//        })
//        return axisLayout
//    }
    
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

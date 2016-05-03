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
        
        layoutArray.append(twoCell_1())
        
        self.layouts = layoutArray
    }
    
    private func twoCell_1() -> Layout {
        let xs: [CGFloat] = [0.0, 0.5, 1.0]
        let ys: [CGFloat] = [0.0, 1.0]
        
        let generatePS = { (xs: [CGFloat], ys : [CGFloat], border: CGFloat, size: CGSize) -> [CGPoint] in
            let w = size.width
            let h = size.height
            let b = border
            let hb = border * 0.5
            
            let p0 = CGPoint(x:xs[0] * w + b, y:ys[0] * h + b)
            var p1 = CGPoint(x:xs[1] * w - hb, y:ys[0] * h + b)
            var p2 = CGPoint(x:xs[1] * w - hb, y:ys[1] * h - b)
            let p3 = CGPoint(x:xs[0] * w + b, y:ys[1] * h - b)
            
            var p4 = CGPoint(x:xs[1] * w + hb, y:ys[0] * h + b)
            let p5 = CGPoint(x:xs[2] * w - b, y:ys[0] * h + b)
            let p6 = CGPoint(x:xs[2] * w - b, y:ys[1] * h - b)
            var p7 = CGPoint(x:xs[1] * w + hb, y:ys[1] * h - b)
            
            
            p1.x = min(max(p0.x, p1.x), p5.x)
            p2.x = min(max(p3.x, p2.x), p6.x)
            
            p4.x = max(min(p4.x, p5.x), p0.x)
            p7.x = max(min(p7.x, p6.x), p3.x)
            
            return [
                p0, p1, p2, p3, p4, p5, p6, p7
            ]
        }
        
        let generatePolygons = { (ps: [CGPoint]) -> [Polygon] in
            
            let polygon1 = LayoutFactory.generatePolygon([ps[0], ps[1], ps[2], ps[3]])
            let polygon2 = LayoutFactory.generatePolygon([ps[4], ps[5], ps[6], ps[7]])
            
            let polygons: [Polygon] = [
                polygon1, polygon2
            ]
            return polygons
        }
        
        let generateGS = { (xs: [CGFloat], ys: [CGFloat], size: CGSize) -> [CGPoint] in
            return [
                CGPoint(x: size.width * xs[1], y: 0.5 * size.height) // g0
            ]
        }
        
        let border: CGFloat = 0
        let gsPointChangeHandlers: [GrapPointChangeHandler] = [
            { (newUnitGrapPoint: CGPoint, xs: [CGFloat], ys: [CGFloat]) -> ([CGFloat], [CGFloat]) in
                var newXS: [CGFloat] = Array(xs)
                newXS[1] = min(max(newUnitGrapPoint.x, xs[0]), xs[2])
                return (newXS, ys)
            }
        ]
        let layout = Layout(size: CGSize(width: 0, height: 0),
                            curvature:0,
                            border: border,
                            xs: xs, ys: ys, generatePS: generatePS,
                            cellCount: 2,
                            generatePolygons: generatePolygons,
                            generateGS: generateGS,
                            gsChangeHandlers: gsPointChangeHandlers)
        
        return layout
    }

    func numberOfLayouts() -> Int {
        return 0;
    }
    
    static func generatePolygon(points: [CGPoint]) -> Polygon {
        var mutablePoints = Array(points)
        var minX = CGFloat.max
        var minY = CGFloat.max
        
        points.forEach({ (p) in
            minX = min(p.x, minX)
            minY = min(p.y, minY)
        })
        for (index, _) in mutablePoints.enumerate() {
            mutablePoints[index].x -= minX
            mutablePoints[index].y -= minY
        }
        return Polygon(origin: CGPoint(x:minX, y:minY), points: mutablePoints)
    }
    
    func getLayout(index:Int, limit: Int) -> [Layout]? {
        if let result:ArraySlice<Layout> = layouts[index..<limit] {
            var copyResult: [Layout] = []
            result.forEach({ (layout) in
                copyResult.append(layout.copy() as! Layout)
            })
            return Array(copyResult)
        }
        return nil
    }
}

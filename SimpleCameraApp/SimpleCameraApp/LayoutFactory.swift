//
//  LayoutFactory.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 20..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit


extension CGPoint {
    func midOfPoint(other: CGPoint) -> CGPoint{
        return CGPoint(x: 0.5 * (x + other.x), y: 0.5 * (y + other.y))
    }
}
func applyBoder(p: CGPoint, midPoint: CGPoint, border: CGFloat) -> CGPoint {
    var newP:CGPoint = CGPoint(x: 0, y: 0)
    
    if p.x < midPoint.x {
        let dx = max(midPoint.x - p.x - border, 0)
        newP.x = midPoint.x - dx
    } else {
        let dx = max(p.x - midPoint.x - border, 0)
        newP.x = midPoint.x + dx
    }
    
    if (p.y < midPoint.y) {
        let dy = max(midPoint.y - p.y - border, 0)
        newP.y = midPoint.y - dy
    } else {
        let dy = max(p.y - midPoint.y - border, 0)
        newP.y = midPoint.y + dy
    }
    
    return newP

}
class LayoutFactory: NSObject {
    static let sharedInstance = LayoutFactory()
    
    private var layouts:[Layout]!
    
    override init() {
        super.init()
        var layoutArray: [Layout] = []
        
        layoutArray.append(normalLayout())
        
        self.layouts = layoutArray
    }
    
    private func normalLayout() -> Layout {
        
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
            let polygons: [Polygon] = [
                [ps[0], ps[1], ps[2], ps[3], ps[0]],
                [ps[4], ps[5], ps[6], ps[7], ps[4]]
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
        let layout = Layout(size: CGSize(width: 0, height: 0), border: border, xs: xs, ys: ys, generatePS: generatePS, cellCount: 2, generatePolygons: generatePolygons, generateGS: generateGS, gsChangeHandlers: gsPointChangeHandlers)
        
        return layout
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

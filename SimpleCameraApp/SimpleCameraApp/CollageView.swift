//
//  CollageView.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 14..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

/**
 View Collage (꼴라주)
 */
class CollageView: UIView {
    private var collageCells: Array<CollageCell>?
    private var cellGrapButtons: Array<LayoutGripView>?
    
    override func awakeFromNib() {
        // define input parameter
        // very simple axis Layout Example
//        var axisLayout = AxisLayout(cellCount: 2, vs: [0.5], originalVS: [0.5]
//            , grapPoints: { (vs:[CGFloat]) -> [NSValue] in
//                return [PointObj(vs[0],y:0.5)]
//        }) { (vs:[CGFloat]) -> [UnitPolygon] in
//                return [
//                    [PointObj(0,y:0), PointObj(vs[0],y:0), PointObj(vs[0],y:1), PointObj(0,y:1), PointObj(0,y:0)],
//                    [PointObj(vs[0],y:0), PointObj(1,y:0), PointObj(1,y:1), PointObj(vs[0],y:1), PointObj(vs[0],y:0)]
//                ]
//        }
        
        // Complex axis layout Example
        let vs:[CGFloat] = [1/3.0, 2/3.0, 1/3.0, 2/3.0,
                  2/3.0, 1/3.0, 2/3.0, 1/3.0]
        
        var axisLayout = AxisLayout(cellCount: 9
            , vs: vs
            , originalVS: vs
            , grapPoints: { (vs:[CGFloat]) -> [NSValue] in
                return [
                    PointObj(vs[0], y:vs[7]*0.5),
                    PointObj(vs[1], y:vs[3]*0.75),
                    
                    PointObj(0.5 * (1 + vs[1]), y:vs[2]),
                    PointObj(0.25 * (1 + 3 * vs[5]), y:vs[3]),
                    
                    PointObj(vs[4], y:(1 + vs[3]) / 2),
                    PointObj(vs[5], y:(1 + 3 * vs[7]) * 0.25),
                    
                    PointObj(0.5 * vs[5], y:vs[6]),
                    PointObj(3/4*vs[1], y:vs[7])
                ]
            }
            , grapPointsChangeHandlers: [
                // g0
                { (point, vs) in var newVS = Array.init(vs)
                    newVS[0] = max(min(point.x, vs[1]), 0)
                    return newVS
                },
                // g1
                { (point, vs) in var newVS = Array.init(vs)
                    newVS[1] = max(min(point.x, 1), max(vs[0], vs[5]))
                    return newVS
                },
                // g2
                { (point, vs) in var newVS = Array.init(vs)
                    newVS[2] = max(min(point.y, vs[3]), 0)
                    return newVS
                },
                // g3
                { (point, vs) in var newVS = Array.init(vs)
                    newVS[3] = max(min(point.y, 1), max(vs[7], vs[2]))
                    return newVS
                },
                // g4
                { (point, vs) in var newVS = Array.init(vs)
                    newVS[4] = max(min(point.x, 1), vs[5])
                    return newVS
                },
                // g5
                { (point, vs) in var newVS = Array.init(vs)
                    newVS[5] = min(max(point.x, 0), min(vs[1], vs[4]))
                    return newVS
                },
                // g6
                { (point, vs) in var newVS = Array.init(vs)
                    newVS[6] = max(min(point.y, 1), vs[7])
                    return newVS
                },
                // g7
                { (point, vs) in var newVS = Array.init(vs)
                    newVS[7] = min(max(point.y, 0), min(vs[6], vs[3]))
                    return newVS
                },
            ]
            , points: { (vs:[CGFloat]) -> [UnitPolygon] in
                return [
                    [PointObj(0, y:0), PointObj(vs[0], y:0), PointObj(vs[0], y:vs[7]), PointObj(0, y:vs[7]), PointObj(0, y:0)], // 0
                    [PointObj(vs[0], y:0), PointObj(vs[1], y:0), PointObj(vs[1], y:vs[7]), PointObj(vs[0], y:vs[7]), PointObj(vs[0], y:0)], // 1
                    [PointObj(vs[1], y:0), PointObj(1, y:0), PointObj(1, y:vs[2]), PointObj(vs[1], y:vs[2]), PointObj(vs[1], y:0)], // 2
                    [PointObj(vs[1], y:vs[2]), PointObj(1, y:vs[2]), PointObj(1, y:vs[3]), PointObj(vs[1], y:vs[3]), PointObj(vs[1], y:vs[2])], // 3
                    
                    [PointObj(vs[4], y:vs[3]), PointObj(1, y:vs[3]), PointObj(1, y:1), PointObj(vs[4], y:1), PointObj(vs[4], y:vs[3])], // 4
                    [PointObj(vs[5], y:vs[3]), PointObj(vs[4], y:vs[3]), PointObj(vs[4], y:1), PointObj(vs[5], y:1), PointObj(vs[5], y:vs[3])], // 5
                    [PointObj(0, y:vs[6]), PointObj(vs[5], y:vs[6]), PointObj(vs[5], y:1), PointObj(0, y:1), PointObj(0, y:vs[6])], // 6
                    
                    [PointObj(0, y:vs[7]), PointObj(vs[5], y:vs[7]), PointObj(vs[5], y:vs[6]), PointObj(0, y:vs[6]), PointObj(0, y:vs[7])], // 7
                    
                    [PointObj(vs[5], y:vs[7]), PointObj(vs[1], y:vs[7]), PointObj(vs[1], y:vs[3]), PointObj(vs[5], y:vs[3]), PointObj(vs[5], y:vs[7])], // 8
                ]
        })
        

        self.collageCells = createCollageCells(axisLayout.numberOfCells())
        
        // add cells
        for collageCell in self.collageCells! {
            self.addSubview(collageCell)
        }
        
        let grapPoints = axisLayout.getGrapPoints()
        
        var cellGrapButtons:[LayoutGripView] = []
        
        weak var weakSelf = self
        for (index, grapPoint) in grapPoints.enumerate() {
            let button: LayoutGripView = LayoutGripView.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 40, height: 40)))
            button.center = CollageView.scalePoint(grapPoint.CGPointValue(), frame:self.bounds)
            button.backgroundColor = UIColor.orangeColor()
            button.onChangeLocation = {(view:LayoutGripView, origin: CGPoint) -> (Void) in
                axisLayout.vs = axisLayout.changeGrapPoints(index, point: CGPointMake(origin.x / self.frame.size.width, origin.y / self.frame.size.height))
                weakSelf?.applyCellPath(axisLayout)
            }
            cellGrapButtons.append(button)
            self.addSubview(button)
        }
        self.cellGrapButtons = cellGrapButtons
        
        applyCellPath(axisLayout)
    }
    
    private func applyCellPath(layout:Layout) {
        let collageCellPaths = CollageView.generateCollageCellPath(layout, view: self)
        let grapButtonPoints = layout.getGrapPoints()
        
        // add cells
        for (index, collageCell) in self.collageCells!.enumerate() {
            collageCell.shapeLayerPath = collageCellPaths[index]
        }
        
        for (index, grapButton) in self.cellGrapButtons!.enumerate() {
            grapButton.center = CollageView.scalePoint(grapButtonPoints[index].CGPointValue(), frame:self.bounds)
        }
    }
    
    private func createCollageCells(numberOfCells:Int) -> Array<CollageCell> {
        var collageCells: Array<CollageCell> = []
        var count = 0
        while (count < numberOfCells) {
            let cell:CollageCell = CollageCell.init(frame: self.bounds)
            collageCells.append(cell)
            count += 1
        }
        return collageCells
    }
    
    // MARK: Static
    static func generateCollageCellPath(layout: Layout, view:UIView) -> Array<UIBezierPath> {
        var collageCellPaths: Array<UIBezierPath> = []
        for polygon in layout.layout() {
            let path: UIBezierPath = UIBezierPath.init()
            
            for (index, value) in polygon.enumerate() {
                let newPoint = CollageView.scalePoint(value.CGPointValue(), frame:view.bounds)
                
                if (index == 0) {
                    path.moveToPoint(newPoint)
                } else {
                    path.addLineToPoint(newPoint)
                }
            }
            
            collageCellPaths.append(path)
        }
        
        return collageCellPaths
    }
    
    static func scalePoint(point: CGPoint, frame:CGRect) -> CGPoint {
        return CGPointMake(point.x * frame.size.width, point.y * frame.size.height)
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    
    //    let controlPoint = centerOfPoints(scalePoint(pointArray[index-1].CGPointValue()), point2: newPoint)
    //    path.addQuadCurveToPoint(newPoint, controlPoint: controlPoint)
//    func centerOfPoints(point1: CGPoint, point2: CGPoint) -> CGPoint {
//        return CGPoint(x:(point1.x + point2.x) / 2, y:(point1.y + point2.y))
//    }
    
}

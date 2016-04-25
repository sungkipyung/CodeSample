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
    var collageCells: [CollageCell]!
    var cellGrapButtons: [LayoutGripView]!
    
    // layout
    var layout: Layout! {
        didSet(newLayout) {
            let layout: Layout = self.layout!
            layout.size = self.bounds.size
            let collageCells = createCollageCells(layout.cellCount)
            
            // add cells
            for collageCell in collageCells {
                self.addSubview(collageCell)
            }
            self.collageCells = collageCells
            
            let grapPoints = layout.grapPoints()
            
            var cellGrapButtons:[LayoutGripView] = []
            
            weak var weakSelf = self
            
            for (index, grapPoint) in grapPoints.enumerate() {
                let button: LayoutGripView = LayoutGripView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 20, height: 20)))
                button.center = grapPoint
                button.backgroundColor = UIColor.orangeColor()
                
                button.onChangeLocation = {(view:LayoutGripView, originalPosition: CGPoint, incX: CGFloat, incY: CGFloat) -> (Void) in
                    if let s_self = weakSelf {
                        let unitX = (originalPosition.x + incX) / self.frame.size.width
                        let unitY = (originalPosition.y + incY) / self.frame.size.height
                        
                        let xyArrayTubple: ([CGFloat], [CGFloat]) = layout.changeGrapPoints(index, unitPoint: CGPoint(x: unitX, y: unitY))
                        layout.xs = xyArrayTubple.0
                        layout.ys = xyArrayTubple.1
                        s_self.applyCellPath()
                    }
                }
                
                cellGrapButtons.append(button)
                self.addSubview(button)
            }
            self.cellGrapButtons = cellGrapButtons
            
            applyCellPath()
        }
    }
    // selected images
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        
    }
    
    func redraw() {
        applyCellPath()
    }
    
    private func applyCellPath() {
        let layout = self.layout!
        let collageCells = self.collageCells
        let cellGrapButtons = self.cellGrapButtons
        
        let polygons: [Polygon] = layout.layout()
        let collageCellPaths = CollageView.generateCollageCellPath(polygons)
        let grapButtonPoints = layout.grapPoints()
//
        // add cells
        for (index, collageCell) in collageCells.enumerate() {
            collageCell.shapeLayerPath = collageCellPaths[index]
        }
        
        for (index, grapButton) in cellGrapButtons.enumerate() {
            grapButton.center = grapButtonPoints[index]
        }
    }
    
    private func createCollageCells(numberOfCells:Int) -> [CollageCell] {
        var collageCells: [CollageCell] = []
        var count = 0
        while (count < numberOfCells) {
            if let cell = UINib(nibName: "CollageCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? CollageCell {
                cell.frame = self.bounds
                
                let image = UIImage(named: "c2.jpg")!
                cell.imageScrollView.contentSize = image.size
                cell.imageScrollView.frame = cell.bounds
                cell.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
                cell.imageView.image = image
                collageCells.append(cell)
            }
            count += 1
        }
        return collageCells
    }
    
    // MARK: Static
    private static func generateCollageCellPath(polygons: [Polygon]) -> Array<UIBezierPath> {
        var collageCellPaths: Array<UIBezierPath> = []
        for polygon in polygons {
            let path: UIBezierPath = UIBezierPath.init()
            
            for (index, value) in polygon.enumerate() {
                let newPoint = value
                
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
    
    private static func scalePoint(point: CGPoint, frame:CGRect) -> CGPoint {
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

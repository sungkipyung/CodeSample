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
    // layout
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
        
        // Complex axis layout Example
        let layout = LayoutFactory.sharedInstance.getLayout(0, limit: 1)![0]
        
        let collageCells = createCollageCells(layout.numberOfCells())
        
        // add cells
        for collageCell in collageCells {
            self.addSubview(collageCell)
        }
        
        let grapPoints = layout.getGrapPoints()
        
        var cellGrapButtons:[LayoutGripView] = []
        
        weak var weakSelf = self
        
        if var normalLayout = layout as? NormalLayout {
            for (index, grapPoint) in grapPoints.enumerate() {
                let button: LayoutGripView = LayoutGripView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 20, height: 20)))

                button.center = CollageView.scalePoint(grapPoint.CGPointValue(), frame:self.bounds)
                button.backgroundColor = UIColor.orangeColor()

                button.onChangeLocation = {(view:LayoutGripView, originalPosition: CGPoint, incX: CGFloat, incY: CGFloat) -> (Void) in
                    let unitX = (originalPosition.x + incX) / self.frame.size.width
                    let unitY = (originalPosition.y + incY) / self.frame.size.height
                    
                    let xyArrayTubple: ([CGFloat], [CGFloat]) = normalLayout.changeGrapPoints(index, unitPoint: CGPoint(x: unitX, y: unitY))
                    normalLayout.xs = xyArrayTubple.0
                    normalLayout.ys = xyArrayTubple.1
//                    axisLayout.vs = normalLayout.changeGrapPoints(index, unitPoint: CGPointMake(origin.x / self.frame.size.width, origin.y / self.frame.size.height))
                    weakSelf?.applyCellPath(normalLayout, collageCells:collageCells, cellGrapButtons: cellGrapButtons)
                }
                
                cellGrapButtons.append(button)
                self.addSubview(button)
            }
        }
//        if var axisLayout = layout as? AxisLayout {
//            for (index, grapPoint) in grapPoints.enumerate() {
//                let button: LayoutGripView = LayoutGripView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 20, height: 20)))
//                
//                button.center = CollageView.scalePoint(grapPoint.CGPointValue(), frame:self.bounds)
//                button.backgroundColor = UIColor.orangeColor()
//                
//                button.onChangeLocation = {(view:LayoutGripView, origin: CGPoint) -> (Void) in
//                    axisLayout.vs = axisLayout.changeGrapPoints(index, unitPoint: CGPointMake(origin.x / self.frame.size.width, origin.y / self.frame.size.height))
//                    weakSelf?.applyCellPath(axisLayout, collageCells:collageCells, cellGrapButtons: cellGrapButtons)
//                }
//                
//                cellGrapButtons.append(button)
//                self.addSubview(button)
//            }
//        }
        
        applyCellPath(layout, collageCells:collageCells, cellGrapButtons: cellGrapButtons)
    }
    
    private func applyCellPath(layout:Layout, collageCells:[CollageCell], cellGrapButtons:[LayoutGripView]) {
        let polygons: [UnitPolygon] = layout.layout()
        let collageCellPaths = CollageView.generateCollageCellPath(polygons, view: self)
        let grapButtonPoints = layout.getGrapPoints()
//
        // add cells
        for (index, collageCell) in collageCells.enumerate() {
            collageCell.shapeLayerPath = collageCellPaths[index]
        }
        
        for (index, grapButton) in cellGrapButtons.enumerate() {
            grapButton.center = CollageView.scalePoint(grapButtonPoints[index].CGPointValue(), frame:self.bounds)
        }
    }
    
    private func createCollageCells(numberOfCells:Int) -> [CollageCell] {
        var collageCells: [CollageCell] = []
        var count = 0
        while (count < numberOfCells) {
            if let cell = UINib(nibName: "CollageCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? CollageCell {
                cell.frame = self.bounds
                
                let image = UIImage(named: "\(count % 5 + 1).jpg")!
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
    private static func generateCollageCellPath(polygons: [UnitPolygon], view:UIView) -> Array<UIBezierPath> {
        var collageCellPaths: Array<UIBezierPath> = []
        for polygon in polygons {
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
    
    private static func frameFromUnitPolygon(frame:CGRect, unitPolygon:UnitPolygon) -> CGRect {
        var minX = CGFloat.max
        var minY = CGFloat.max
        var maxX = CGFloat.min
        var maxY = CGFloat.min
        
        unitPolygon.forEach { (value) in
            let point = value.CGPointValue()
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }
        
        let width = frame.size.width
        let height = frame.size.height
        
        return CGRect(x: minX * width, y: minY * height, width: (maxX - minX) * width, height: (maxY - minY) * height)
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

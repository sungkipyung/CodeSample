//
//  CollageView.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 14..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit
import Darwin

/**
 View Collage (꼴라주)
 */
struct CornerPoint {
    let centerPoint: CGPoint!
    let startAngle: CGFloat!
    let endAngle: CGFloat!
}

class CollageView: UIView {
    var collageCells: [CollageCell]!
    var cellGrapButtons: [LayoutGripView]!
    
    var drawGrapButtons: Bool! = false {
        didSet {
            cellGrapButtons.forEach { (gripView) in
                gripView.hidden = !drawGrapButtons
            }
        }
    }
    
    // layout
    var layout: Layout! {
        didSet(newLayout) {
            self.subviews.forEach { (subView) in
                subView.removeFromSuperview()
            }
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
                button.hidden = true
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
    }
    
    func redraw() {
        applyCellPath()
    }
    
    private func applyCellPath() {
        let layout = self.layout!
        let collageCells = self.collageCells
        let cellGrapButtons = self.cellGrapButtons
        
        let polygons: [Polygon] = layout.layout()
        let collageCellPaths = CollageView.generateCollageCellPath(polygons, radius:layout.cornerRadius)
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
    private static func generateCollageCellPath(polygons: [Polygon], radius: CGFloat) -> Array<UIBezierPath> {
        var collageCellPaths: Array<UIBezierPath> = []
        for polygon in polygons {
            let path: UIBezierPath = UIBezierPath.init()
            
            for (index, value) in polygon.enumerate() {
                let newPoint = value
                
                if (index == 0) {
                    path.moveToPoint(newPoint)
                }
                
                if (radius == 0) {
                    if (index != 0) {
                        path.addLineToPoint(newPoint)
                    }
                }
                 else {
                    let from = polygon[index - 1 < 0 ? polygon.count - 1 : index - 1]
                    let via = value
                    let to = polygon[(index + 1) % polygon.count]
                    let cornerPoint:CornerPoint = CollageView.roundedCorner(from, via: via, to: to, radius: radius)
                    path.addArcWithCenter(cornerPoint.centerPoint, radius: radius, startAngle: cornerPoint.startAngle, endAngle: cornerPoint.endAngle, clockwise: true)
                }
            }
            path.closePath()
            
            collageCellPaths.append(path)
        }
        
        return collageCellPaths
    }
    
    private static func roundedCorner(from: CGPoint, via: CGPoint, to: CGPoint, radius: CGFloat) -> CornerPoint {
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

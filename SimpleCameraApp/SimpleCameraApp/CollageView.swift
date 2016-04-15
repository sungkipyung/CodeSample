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
class CollageView: UIView, LayoutGripViewDelegate {
    var layout: Layout?
    private var collageCells: Array<CollageCell>?
    
    override func awakeFromNib() {
        // define input parameter
        self.layout = Layout(numberOfCells: 2, alpha: 0.5, point: CGPoint(x: 0.5, y: 0.5))
        
        self.collageCells = createCollageCells(layout!.numberOfCells)
        
        // add cells
        for collageCell in self.collageCells! {
            self.addSubview(collageCell)
        }
        
        applyCellPath()
        
        let button: LayoutGripView = LayoutGripView.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 40, height: 40)))
        button.delegate = self
        button.center = CollageView.scalePoint(self.layout!.point, frame:self.bounds)
        button.backgroundColor = UIColor.orangeColor()
        self.addSubview(button)
    }
    
    private func applyCellPath() {
        let collageCellPaths = CollageView.generateCollageCellPath(self.layout!, view: self)
        
        // add cells
        for (index, collageCell) in self.collageCells!.enumerate() {
            collageCell.shapeLayerPath = collageCellPaths[index]
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
    
    // MARK: LayoutGripViewDelegate
    func layoutGripViewDidChangeLocation(view: LayoutGripView, origin: CGPoint) {
        view.center.x = origin.x
        self.layout?.alpha = origin.x / self.frame.size.width
        // alpha has changed then redraw path
        applyCellPath()
    }
    
    // MARK: Static
    static func generateCollageCellPath(layout: Layout, view:UIView) -> Array<UIBezierPath> {
        var collageCellPaths: Array<UIBezierPath> = []
        for polygon in layout.polygons() {
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

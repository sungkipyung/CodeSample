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
extension CollageCell {
    func showShadow() {
        self.layer.shadowOffset = CGSizeMake(-15, 20)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
    }
    
    func hideShadow() {
        self.layer.shadowOffset = CGSizeMake(0, 0)
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 0
    }
    
}

class CollageView: UIView {
    var collageCells: [CollageCell]!
    var cellGrapButtons: [LayoutGripView]!
    var swappable: Bool = true
    
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
            let collageCells = createCollageCells(layout)
            
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
        
        let polygons: [Polygon] = layout.polygons()
        let grapButtonPoints = layout.grapPoints()
//
        // add cells
        for (index, collageCell) in collageCells.enumerate() {
            collageCell.polygon = polygons[index]
//            collageCell.frame = CGRect(origin: polygons[index].origin, size: collageCellPaths[index].bounds.size)
        }
        
        for (index, grapButton) in cellGrapButtons.enumerate() {
            grapButton.center = grapButtonPoints[index]
        }
    }
    
    private func createCollageCells(layout:Layout) -> [CollageCell] {
        var collageCells: [CollageCell] = []
        var index = 0
        let polygons = layout.polygons()
        
        while (index < layout.cellCount) {
            if let cell = UINib(nibName: "CollageCell", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as? CollageCell {
                cell.frame = self.bounds
                
                cell.polygon = polygons[index]
                
                let image = UIImage(named: "c\(index % 2 + 1).jpg")!
//                cell.imageScrollView.contentSize = image.size
                cell.imageScrollView.contentSize = self.bounds.size
                
//                cell.imageScrollView.frame = cell.bounds
                cell.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.bounds.size)
                cell.imageView.image = image
                
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(collageCellLongPressed))
                cell.addGestureRecognizer(longPressGesture)
                collageCells.append(cell)
            }
            index += 1
        }
        return collageCells
    }
    
    var selectedCollageCell: CollageCell!
    var offset: CGPoint!
    var targetViewForSwap: CollageCell?
    
    // MARK: Objc
    @objc private func collageCellLongPressed(sender: UILongPressGestureRecognizer) {
        if (self.swappable == false) {
            return
        }
        
        switch sender.state {
        case .Began:
            self.offset = sender.locationInView(self)
            self.selectedCollageCell = sender.view as! CollageCell
            self.selectedCollageCell.superview?.bringSubviewToFront(self.selectedCollageCell)
            
            self.targetViewForSwap = nil
            
            UIView.animateWithDuration(0.2, animations: {
                self.selectedCollageCell.transform = CGAffineTransformMakeScale(0.9, 0.9)
                self.selectedCollageCell.showShadow()
            })
            break
        case .Changed:
            let cursor = sender.locationInView(self)
            let db = cursor - offset
            
            self.selectedCollageCell.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeTranslation(db.x, db.y))
            
            
            self.targetViewForSwap = nil
            self.collageCells.forEach({ (cell) in
                if cell == self.selectedCollageCell {
                    return
                }
                if cell.pointInside(self.convertPoint(cursor, toView: cell)) {
                    cell.alpha = 0.5
                    self.targetViewForSwap = cell
                } else {
                    cell.alpha = 1
                }
            })
            break
        case .Ended, .Cancelled, .Failed:
            
            UIView.animateWithDuration(0.5, animations: {
                //Swap Operation
                if let target = self.targetViewForSwap {
                    let indexA = self.collageCells.indexOf(target)!
                    let indexB = self.collageCells.indexOf(self.selectedCollageCell)!
                    self.selectedCollageCell.transform = CGAffineTransformIdentity
                    swap(&self.collageCells[indexA], &self.collageCells[indexB]);
                    
                    self.applyCellPath()
                } else {
                    // Rollback Position
                    self.selectedCollageCell.transform = CGAffineTransformIdentity
                }
                }, completion: { (complete) in
                    self.selectedCollageCell.hideShadow()
                    self.collageCells.forEach({ (view) in
                        view.alpha = 1
                    })
            })
            break
        default:
            NSLog("default operation")
        }
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
}

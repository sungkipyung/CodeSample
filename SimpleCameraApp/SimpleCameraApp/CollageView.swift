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
        self.layer.shadowOffset = CGSize(width: -15, height: 20)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.5
    }
    
    func hideShadow() {
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 0
    }
}

protocol CollageViewDelegate {
    func collageCellSelected(_ collageView:CollageView, selectedCell:CollageCell)
}

class CollageView: UIView, CollageCellDelegate {
    var delegate: CollageViewDelegate?
    var collageCells: [CollageCell]!
    var cellGrapButtons: [LayoutGripView]!
    var swappable: Bool = true
    
    var drawGrapButtons: Bool! = false {
        didSet {
            cellGrapButtons.forEach { (gripView) in
                gripView.isHidden = !drawGrapButtons
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
            
            for (index, grapPoint) in grapPoints.enumerated() {
                let button: LayoutGripView = LayoutGripView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 20, height: 20)))
                button.center = grapPoint
                button.backgroundColor = UIColor.orange
                
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
                button.isHidden = true
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
    
    fileprivate func applyCellPath() {
        let layout = self.layout!
        let collageCells = self.collageCells
        let cellGrapButtons = self.cellGrapButtons
        
        let polygons: [Polygon] = layout.polygons()
        let grapButtonPoints = layout.grapPoints()
//
        // add cells
        for (index, collageCell) in (collageCells?.enumerated())! {
            collageCell.polygon = polygons[index]
//            collageCell.frame = CGRect(origin: polygons[index].origin, size: collageCellPaths[index].bounds.size)
        }
        
        for (index, grapButton) in (cellGrapButtons?.enumerated())! {
            grapButton.center = grapButtonPoints[index]
        }
    }
    
    fileprivate func createCollageCells(_ layout:Layout) -> [CollageCell] {
        var collageCells: [CollageCell] = []
        var index = 0
        let polygons = layout.polygons()
        
        while (index < layout.cellCount) {
            if let cell = UINib(nibName: "CollageCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? CollageCell {
                cell.frame = self.bounds
                
                cell.polygon = polygons[index]
                
                let image = UIImage(named: "c\(index % 2 + 1).jpg")!
                cell.imageView.image = image
                cell.imageView.sizeToFit()
                cell.imageScrollView.frame = cell.bounds
                cell.imageView.sizeThatFit(cell.imageScrollView)
                
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(collageCellLongPressed))
                cell.addGestureRecognizer(longPressGesture)
                cell.delegate = self
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
    @objc fileprivate func collageCellLongPressed(_ sender: UILongPressGestureRecognizer) {
        if (self.swappable == false) {
            return
        }
        
        switch sender.state {
        case .began:
            self.offset = sender.location(in: self)
            self.selectedCollageCell = sender.view as! CollageCell
            self.selectedCollageCell.superview?.bringSubview(toFront: self.selectedCollageCell)
            
            self.targetViewForSwap = nil
            
            UIView.animate(withDuration: 0.2, animations: {
                self.selectedCollageCell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.selectedCollageCell.showShadow()
            })
            break
        case .changed:
            let cursor = sender.location(in: self)
            let db = cursor - offset
            
            self.selectedCollageCell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).concatenating(CGAffineTransform(translationX: db.x, y: db.y))
            
            
            self.targetViewForSwap = nil
            self.collageCells.forEach({ (cell) in
                if cell == self.selectedCollageCell {
                    return
                }
                if cell.pointInside(self.convert(cursor, to: cell)) {
                    cell.alpha = 0.5
                    self.targetViewForSwap = cell
                } else {
                    cell.alpha = 1
                }
            })
            break
        case .ended, .cancelled, .failed:
            
            UIView.animate(withDuration: 0.5, animations: {
                //Swap Operation
                if let target = self.targetViewForSwap {
                    let indexA = self.collageCells.index(of: target)!
                    let indexB = self.collageCells.index(of: self.selectedCollageCell)!
                    self.selectedCollageCell.transform = CGAffineTransform.identity
                    swap(&self.collageCells[indexA], &self.collageCells[indexB]);
                    
                    self.applyCellPath()
                } else {
                    // Rollback Position
                    self.selectedCollageCell.transform = CGAffineTransform.identity
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
    // MARK: - CollageCellDelegate
    func collageCellDidSelect(_ cell: CollageCell) {
        // TODO: highlight selected cell
        delegate?.collageCellSelected(self, selectedCell: cell)
    }
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
}

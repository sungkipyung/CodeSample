//
//  CollageCell.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 14..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

protocol CollageCellDelegate {
    func collageCellDidSelect(_ cell: CollageCell)
}

class CollageCell: UIView, UIScrollViewDelegate {

    @IBOutlet weak var cameraPreview: CameraPreview!
    @IBOutlet weak var imageScrollView: UIScrollView!

    weak var imageView: UIImageView!
    var delegate: CollageCellDelegate?
    var enableMask: Bool? = true
    
    @IBOutlet weak var lineView: UIView!
    fileprivate static let BORDER_WIDTH:CGFloat = 0
    
    var polygon: Polygon! {
        didSet {
            if let p = polygon  {
                let path = p.path()
                self.frame = CGRect(origin: p.origin, size: path.bounds.size)
                self.imageScrollView.frame = self.bounds
//                self.imageView.sizeThatFit(self.imageScrollView)
                self.cameraPreview.frame = self.bounds
                self.shapeLayerPath = path
            }
        }
    }
    
    internal fileprivate(set) var shapeLayerPath : UIBezierPath? {
        didSet (newLayer) {
            let shapeLayerPath = self.shapeLayerPath!
            
            let path = shapeLayerPath.cgPath
            
            if self.enableMask! {
                let mask: CAShapeLayer = CAShapeLayer()
                mask.path = path
                self.layer.mask = mask
            }
            
            self.lineView.layer.sublayers?.forEach({ (sublayer) in
                sublayer.removeFromSuperlayer()
            })
            if (self.imageView.image == nil) {
                let line = CAShapeLayer.init()
                line.path = path
                line.lineDashPattern = [8, 8]
                line.lineWidth = 2
                line.fillColor = UIColor.clear.cgColor
                line.strokeColor = UIColor.white.cgColor
                self.lineView.layer.addSublayer(line)
            }
        }
    }
    
    func pointInside(_ point: CGPoint) -> Bool {
        if let path:UIBezierPath =  self.shapeLayerPath {
            return path.contains(point)
        }
        return false
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let path:UIBezierPath =  self.shapeLayerPath {
            return path.contains(point)
        } else {
            return super.point(inside: point, with: event)
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        self.imageScrollView.delegate = self
        let imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = UIViewContentMode.scaleToFill
        self.imageScrollView.addSubview(imageView)
        self.imageView = imageView
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
//        self.superview?.bringSubviewToFront(self)
    }
    
    @IBAction func imageScrollViewTapped(_ sender: AnyObject) {
        delegate?.collageCellDidSelect(self)
    }
}

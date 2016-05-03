//
//  BubbleView.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 3..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

@IBDesignable
class BubbleView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bubbleImage: UIImageView!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init")
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("initWithCoder")
        load()
    }
    override func awakeFromNib() {
        print("awakeFromNib")
//        bubbleImage.image = UIImage(named: "bubble.png")
        let image = UIImage(named: "bubble2.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        bubbleImage.image = image.resizableImageWithCapInsets(UIEdgeInsetsMake(35, 22, 10, 10), resizingMode: UIImageResizingMode.Stretch)
        bubbleImage.tintColor = UIColor.yellowColor()
        bubbleImage.clearsContextBeforeDrawing = true
        bubbleImage.clipsToBounds = true
        bubbleImage.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
    func load() {
        let bubbleView = NSBundle(forClass: self.dynamicType).loadNibNamed("BubbleView", owner: self, options: nil).first as! UIView
        self.addSubview(bubbleView)
    }
}

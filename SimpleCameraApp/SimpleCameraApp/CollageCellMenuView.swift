//
//  CollageCellMenuView.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 25..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class CollageCellMenuView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        let image = UIImage(named: "bubble.png")
        image?.resizableImageWithCapInsets(UIEdgeInsetsMake(35, 10, 10, 22), resizingMode: UIImageResizingMode.Stretch)
    }
}

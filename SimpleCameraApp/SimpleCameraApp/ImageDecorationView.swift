//
//  ImageDecorationView.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 8..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

class ImageDecorationView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NSLog("touchsBegan")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        NSLog("touchsBegan")
    }
}

//
//  ViewController.swift
//  Chapter1
//
//  Created by 성기평 on 2015. 8. 6..
//  Copyright © 2015년 hothead. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let v1 = UIView(frame: CGRectMake(113, 111, 132, 194))
        v1.backgroundColor = UIColor(red: 1, green: 0.4, blue: 1, alpha: 1)
        
        let v2 = UIView(frame: v1.bounds.rectByInsetting(dx: 10, dy: 10))
        v2.backgroundColor = UIColor(red: 0.5, green: 1, blue: 0, alpha: 1)
        
        self.view.addSubview(v1)
        v1.addSubview(v2)
        
//        v2.bounds.size.height += 10
//        v2.bounds.size.width += 10
        
        
        v1.bounds.origin.x += 10
        v1.bounds.origin.y += 10
        
        v2.center = v1.convertPoint(v1.center, fromView: v1.superview)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


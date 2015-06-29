//
//  ViewController.swift
//  NSCacheExample
//
//  Created by 성기평 on 2015. 6. 25..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var cache: NSCache?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cache = NSCache()
        
        cache?.setObject(1, forKey: "1")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


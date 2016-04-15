//
//  UnitPoint.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 4. 14..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

struct UnitPoint {
    // unsigned float
    var x: CGFloat {
        set (newX) {
            self.x = min(abs(newX), 1.0)
        }
        get {
            return self.x
        }
    }
    var y: CGFloat {
        set (newY) {
            self.y = min(abs(newY), 1.0)
        }
        get {
            return self.y
        }
    }
}
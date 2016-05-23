//
//  CGSize+Extensions.swift
//  SimpleCameraApp
//
//  Created by 성기평 on 2016. 5. 23..
//  Copyright © 2016년 hothead. All rights reserved.
//

import UIKit

extension CGSize {
}

/**
 * Multiplies a CGPoint with a CGVector and returns the result as a new CGPoint.
 */
public func * (left: CGFloat, right: CGSize) -> CGSize {
    return CGSizeMake(left * right.width, left * right.height)
}

/**
 * Multiplies a CGPoint with a CGVector and returns the result as a new CGPoint.
 */
public func * (left: CGSize, right: CGFloat) -> CGSize {
    return CGSizeMake(right * left.width, right * left.height)
}

public func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSizeMake(left.width - right.width, left.height - right.height)
}
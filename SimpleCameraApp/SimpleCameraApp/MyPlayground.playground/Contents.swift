//: Playground - noun: a place where people can play

import UIKit


let rect = CGRectMake(100, 100, 100, 50)
let p0 = rect.origin
let p1 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)
let p2 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)
let p3 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)

let degree: CGFloat = 90
let center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))


let t1 = CGAffineTransformMakeTranslation(-center.x, -center.y)
let t2 = CGAffineTransformMakeRotation(degree / 180.0 * CGFloat(M_PI))
let t3 = CGAffineTransformMakeTranslation(center.x, center.y)

var t = CGAffineTransformIdentity
t = CGAffineTransformConcat(t, t1)
t = CGAffineTransformConcat(t, t2)
t = CGAffineTransformConcat(t, t3)

let newP0 = CGPointApplyAffineTransform(p0, t)
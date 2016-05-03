//: Playground - noun: a place where people can play

import UIKit


typealias Polygon = [CGPoint]

func ??<T>(optional: T?, defaultValue: () -> T) -> T {
    if let x = optional {
        return x
    }
    
    return defaultValue()
}

let cities = ["Paries":2243, "Madrid": 3216, "Amsterdam": 881, "Berlin": 3397]



let madridPopulation = cities["Madrid"] ?? { 10 } // lazy loading을 하고 싶은거지...
print(madridPopulation)

//infix operator ??



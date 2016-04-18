//: Playground - noun: a place where people can play

import UIKit


typealias UnitPolygon = [NSValue]

protocol Layout {
    func layout() -> [UnitPolygon]
}
// input : variable vector
// output : unit polygon points reference variable vector


// MARK: Define AxisLayout Type
typealias AxisLayoutPolygons = [CGFloat] -> [UnitPolygon]

struct AxisLayout {
    let cellCount: Int
    let originalGrapPoints: UnitPolygon
    
    var grapPoints: UnitPolygon
    var vs: [CGFloat]
    
    let points:AxisLayoutPolygons
}

extension AxisLayout : Layout {
    func layout() -> [UnitPolygon] {
        return self.points(self.vs)
    }
}
// MARK: End define AxisLayout Type


// MARK: Utilities
func PointObj(x:CGFloat, y:CGFloat) -> NSValue {
    return NSValue(CGPoint: CGPoint(x: x, y: y))
}

var axisLayout = AxisLayout(cellCount: 2,
           originalGrapPoints: [NSValue(CGPoint: CGPoint(x: 0.5, y: 0.5))],
           grapPoints: [NSValue(CGPoint: CGPoint(x: 0.5, y: 0.5))],
           vs: [0.5], points: { (vs:[CGFloat]) in
            return [
                [PointObj(0,y:0), PointObj(vs[0],y:0), PointObj(vs[0],y:1), PointObj(0,y:1), PointObj(0,y:0)],
                [PointObj(vs[0],y:0), PointObj(1,y:0), PointObj(1,y:1), PointObj(vs[0],y:1), PointObj(vs[0],y:0)]
            ]
})

//func jsonStringToDictionary(json: String) -> [String : AnyObject]? {
//    if let data = json.dataUsingEncoding(NSUTF8StringEncoding) {
//        do {
//            let json:AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
//            switch json {
//            case let jsonDic as Dictionary <String, NSValue>:
//                return jsonDic
//            default:
//                return nil
//            }
//        } catch  {
//            return nil
//        }
//    }
//    return nil
//}
//

//extension Dictionary {
//    
//}
//
//extension AxisLayout {
//    static func parseJson(json:String) -> AxisLayout? {
//        if let dictionary = jsonStringToDictionary(json) {
//            let type = dictionary["type"] as? String
//            
//            if (type == nil || type != "axis") {
//                return nil
//            }
//            let cellCount: Int = dictionary["cellCount"] as? Int ?? 0
//            let originalGrapPoints: [String] = dictionary["originalGrapPoints"] as? String
//            
//            let cellCount: UnitPolygon = ?.integerValue
//            
//            dictionary["originalGrapPoints"]
//            dictionary["grapPoints"]
//            dictionary["vs"]
//            dictionary["points"]
//            
//        } else {
//            return nil
//        }
//    }
//}
//
//// parse Axis Expression
//typealias parseAxisExpression = (String) -> (AxisLayout)
//
//do {
//    let dic = [
//        "type":"axis",
//        "cellCount":2,
//        "originalGrapPoints":["0.5_0.5"],
//        "grapPoints":["0.5_0.5"],
//        "vs":[0.5],
//        "points":[
//            ["0_0", "vs[0]_0", "vs[0]_1", "0_1", "0_0"],
//            ["vs[0]_0", "1_0", "1_1", "vs[0]_1", "vs[0]_0"]
//        ]
//    ]
//    
//    let jsonData = try NSJSONSerialization.dataWithJSONObject(dic, options: [])
//    let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
//    AxisLayout.parseJson(jsonString)
////    let decoded = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? [String:AnyObject]
//    // here "decoded" is the dictionary decoded from JSON data
//} catch {
//    
//}
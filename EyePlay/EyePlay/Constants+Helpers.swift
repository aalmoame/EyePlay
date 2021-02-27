
//
//  Constants_Helpers.swift
//  EyePlay
//
//  Created by Amen Al-Moamen on 2/20/21.
//
import Foundation
import UIKit
import SceneKit


//constants and helper functions

//simple helper functions for CGPoints

var cursorSize = CGSize(width: 50.0, height: 50.0);


extension CGPoint {
    func add(point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + point.x, y: self.y + point.y)
    }

    func divide(by: Int) -> CGPoint {
        let denominator = CGFloat(by)
        return CGPoint(x: self.x / denominator, y: self.y / denominator)
    }
    
}

//gets the average of an array (Collection)
extension Collection where Element == CGPoint {
    func average() -> CGPoint {
        let point = self.reduce(CGPoint(x: 0, y: 0)) { (result, point) -> CGPoint in
            result.add(point: point)
        }
        return point.divide(by: self.count)
    }
}


//sets boundaries for points
extension CGFloat {

    func clamped(to: ClosedRange<CGFloat>) -> CGFloat {
        return to.lowerBound > self ? to.lowerBound
            : to.upperBound < self ? to.upperBound
            : self
    }

}

//constants for given device size and screen size
struct Constants {

    struct Device {
        static let screenSize = CGSize(width: 0.06, height: 0.16)
        static let frameSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }

    
    struct Ranges {
        static let widthRange: ClosedRange<CGFloat> = (0...Device.frameSize.width)
        static let heightRange: ClosedRange<CGFloat> = (0...Device.frameSize.height)
    }

}

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}

func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}

extension Collection where Element == CGFloat, Index == Int {
    /// Return the mean of a list of CGFloat. Used with `recentVirtualObjectDistances`.
    var averages: CGFloat? {
        guard !isEmpty else {
            return nil
        }
        
        let sum = reduce(CGFloat(0)) { current, next -> CGFloat in
            return current + next
        }
        
        return sum / CGFloat(count)
    }
}

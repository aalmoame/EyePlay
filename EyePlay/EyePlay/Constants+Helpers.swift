//
//  Constants_Helpers.swift
//  EyePlay
//
//  Created by Amen Al-Moamen on 2/20/21.
//

import Foundation
import UIKit


//constants and helper functions


//simple helper functions for CGPoints
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
        static let screenSize = CGSize(width: 0.061, height: 0.16)
        static let frameSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }

    
    struct Ranges {
        static let widthRange: ClosedRange<CGFloat> = (0...Device.frameSize.width)
        static let heightRange: ClosedRange<CGFloat> = (0...Device.frameSize.height)
    }

}

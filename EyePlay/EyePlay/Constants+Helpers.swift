
//
//  Constants_Helpers.swift
//  EyePlay
//
//  Created by Amen Al-Moamen on 2/20/21.
//
import Foundation
import UIKit
import SceneKit
import AVKit

//constants and helper functions

//simple helper functions for CGPoints

var cursorSize = CGSize(width: 50.0, height: 50.0);
var cursorColor = UIColor.blue
var selectionTime = 2


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

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size

    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height

    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }

    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
}


func animate(button: UIButton){
    UIView.animate(withDuration: 2.5) {
        button.layer.backgroundColor = UIColor.systemBlue.withAlphaComponent(1.0).cgColor
    }
}



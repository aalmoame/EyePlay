//
//  Nodes.swift
//  EyePlay
//
//  Created by Amen Al-Moamen on 2/20/21.
//
import Foundation
import UIKit
import ARKit

//returns a SCNNode corresponding to the left eye

class nodes{

    
    var leftEyeNode: SCNNode = {
            let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.1)
            geometry.radialSegmentCount = 3
            geometry.firstMaterial?.diffuse.contents = UIColor.clear
            let node = SCNNode()
            node.geometry = geometry
            node.eulerAngles.x = -.pi / 2
            node.position.z = 0.1
            let parentNode = SCNNode()
            parentNode.addChildNode(node)
            return parentNode
        }()

    var rightEyeNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.1)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.clear
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()

    var endPointLeftEye: SCNNode = {
        let node = SCNNode()
        node.position.z = 2
        return node
    }()

    var endPointRightEye: SCNNode = {
        let node = SCNNode()
        node.position.z = 2
        return node
    }()
    
    var nodeInFrontOfScreen: SCNNode = {

            let screenGeometry = SCNPlane(width: 1, height: 1)
            screenGeometry.firstMaterial?.isDoubleSided = true
            screenGeometry.firstMaterial?.fillMode = .fill
            screenGeometry.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(0.5)

            let node = SCNNode()
            node.geometry = screenGeometry
            return node
        }()
    
    
    
    var points: [CGPoint] = []
    
    
    //maps the left and right eye gaze positions from a 3-D planes (SCNNodes) to 2-D CGPoints
    func hitTest(withFaceAnchor anchor: ARFaceAnchor, cursor: UIImageView){
        
        rightEyeNode.simdTransform = anchor.rightEyeTransform
        leftEyeNode.simdTransform = anchor.leftEyeTransform

            var leftEyeLocation = CGPoint()
            var rightEyeLocation = CGPoint()

            //segment from where the actual eye is to where the end of its geometry is located (end of the cone)
            let leftEyeResult = nodeInFrontOfScreen.hitTestWithSegment(from: endPointLeftEye.worldPosition,
                                                              to: leftEyeNode.worldPosition,
                                                              options: nil)

            let rightEyeResult = nodeInFrontOfScreen.hitTestWithSegment(from: endPointRightEye.worldPosition,
                                                              to: rightEyeNode.worldPosition,
                                                              options: nil)

            //checks if the eyes are detected and gazing somewhere on the screen
            if leftEyeResult.count > 0 || rightEyeResult.count > 0 {

                guard let leftResult = leftEyeResult.first, let rightResult = rightEyeResult.first else {
                    return
                }

                //mapping the position to a 2-D plane
                leftEyeLocation.x = CGFloat(leftResult.localCoordinates.x) / (Constants.Device.screenSize.width / 2) *
                    Constants.Device.frameSize.width
                leftEyeLocation.y = CGFloat(leftResult.localCoordinates.y) / (Constants.Device.screenSize.height / 2) *
                    Constants.Device.frameSize.height

                rightEyeLocation.x = CGFloat(rightResult.localCoordinates.x) / (Constants.Device.screenSize.width / 2) *
                    Constants.Device.frameSize.width
                rightEyeLocation.y = CGFloat(rightResult.localCoordinates.y) / (Constants.Device.screenSize.height / 2) *
                    Constants.Device.frameSize.height

                //converging the two values to one single point
                let point: CGPoint = {
                    var point = CGPoint()
                    let pointX = ((leftEyeLocation.x + rightEyeLocation.x) / 2)
                    let pointY = -(leftEyeLocation.y + rightEyeLocation.y) / 2

                    point.x = pointX.clamped(to: Constants.Ranges.widthRange)
                    point.y = pointY.clamped(to: Constants.Ranges.heightRange)
                    return point
                }()

                points.append(point)
                points = points.suffix(30).map {$0}

                //placing the cursor at the center of that point
                cursor.center = points.average()
            }
    
        }
    
    func getLookAtPoint() -> CGPoint {
        return points.average()
    }
    
}

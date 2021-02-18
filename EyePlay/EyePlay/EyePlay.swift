//
//  ViewController.swift
//  Emoji Bling
//
//  Created by Amen Al-Moamen on 2/15/21.
//

import UIKit
import ARKit
import VisionKit



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


//main view class
class EyePlay: UIViewController{
    
    //Elements connected to the storyboard
    @IBOutlet var mainView: ARSCNView!
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var ballGameButton: UIButton!


    //returns a SCNNode corresponding to the left eye
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

    //returns a SCNNode corresponding to the left eye
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

    //boundaries for the the left eye
    var endPointLeftEye: SCNNode = {
        let node = SCNNode()
        node.position.z = 2
        return node
    }()

    //boundaries for the the left eye
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
    
    //sets the view up
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      let configuration = ARFaceTrackingConfiguration()
      mainView.session.run(configuration)
    }
    
    
    // pauses the view
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      mainView.session.pause()
    }
    
    //configures the screen once its loaded up
    override func viewDidLoad() {
        super.viewDidLoad()

        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        mainView.pointOfView?.addChildNode(nodeInFrontOfScreen)
        mainView.delegate = self

    }
    
    //holds the recorded points of left and right eye nodes
    var points: [CGPoint] = []
    
    
    //maps the left and right eye gaze positions from a 3-D planes (SCNNodes) to 2-D CGPoints
    func hitTest() {

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
                points = points.suffix(50).map {$0}

                //placing the cursor at the center of that point
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.05, animations: {
                        self.cursor.center = self.points.average()
                    })
                }
            }
        }
    
    
    //checks if the cursor is on top of the game button and if the user blinks
    func collision(faceAnchor: ARFaceAnchor){
        
        
        let eyeBlinkValue = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0

        
        if cursor.frame.intersects(ballGameButton.frame) &&
            eyeBlinkValue > 0.5 {
            
            //go to game screen when user blinks over button
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "BallGameSegue", sender: self)
            }
        }
    }
    
}

extension EyePlay: ARSCNViewDelegate {
    
    //a scene renderer that returns a scene node given a face anchor, runs once
    
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = mainView.device else {
          return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.clear

        node.addChildNode(leftEyeNode)
        leftEyeNode.addChildNode(endPointLeftEye)
        node.addChildNode(rightEyeNode)
        rightEyeNode.addChildNode(endPointRightEye)

        return node
      }
    
    /*this renderer takes as input the previous renderer's scene node, and runs continuously
     with that node given the value has changed, if yes, then it uses that new node */
    
    func renderer(
      _ renderer: SCNSceneRenderer,
      didUpdate node: SCNNode,
      for anchor: ARAnchor) {
       
      guard let faceAnchor = anchor as? ARFaceAnchor,
        let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
          return
      }
        
        leftEyeNode.simdTransform = faceAnchor.leftEyeTransform
        rightEyeNode.simdTransform = faceAnchor.rightEyeTransform

        faceGeometry.update(from: faceAnchor.geometry)
        hitTest()
        collision(faceAnchor: faceAnchor)
        
    }
    
}


//
//  ViewController.swift
//  Emoji Bling
//
//  Created by Amen Al-Moamen on 2/15/21.
//

import UIKit
import ARKit


class ballGame: UIViewController{
    
    @IBOutlet var ballGameView: ARSCNView!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var ball: UIImageView!
    @IBOutlet weak var scoreValue: UILabel!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      // 1
      let configuration = ARFaceTrackingConfiguration()
            
      // 2
      ballGameView.session.run(configuration)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
            
      // 1
      ballGameView.session.pause()
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()

            guard ARFaceTrackingConfiguration.isSupported else {
                fatalError("Face tracking is not supported on this device")
            }
        ballGameView.pointOfView?.addChildNode(nodeInFrontOfScreen)
        ballGameView.delegate = self
    }
    
    var points: [CGPoint] = []
    
    
    func hitTest() {

            var leftEyeLocation = CGPoint()
            var rightEyeLocation = CGPoint()

            let leftEyeResult = nodeInFrontOfScreen.hitTestWithSegment(from: endPointLeftEye.worldPosition,
                                                              to: leftEyeNode.worldPosition,
                                                              options: nil)

            let rightEyeResult = nodeInFrontOfScreen.hitTestWithSegment(from: endPointRightEye.worldPosition,
                                                              to: rightEyeNode.worldPosition,
                                                              options: nil)

            if leftEyeResult.count > 0 || rightEyeResult.count > 0 {

                guard let leftResult = leftEyeResult.first, let rightResult = rightEyeResult.first else {
                    return
                }

                leftEyeLocation.x = CGFloat(leftResult.localCoordinates.x) / (Constants.Device.screenSize.width / 2) *
                    Constants.Device.frameSize.width
                leftEyeLocation.y = CGFloat(leftResult.localCoordinates.y) / (Constants.Device.screenSize.height / 2) *
                    Constants.Device.frameSize.height

                rightEyeLocation.x = CGFloat(rightResult.localCoordinates.x) / (Constants.Device.screenSize.width / 2) *
                    Constants.Device.frameSize.width
                rightEyeLocation.y = CGFloat(rightResult.localCoordinates.y) / (Constants.Device.screenSize.height / 2) *
                    Constants.Device.frameSize.height

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

                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.05, animations: {
                        self.cursor.center = self.points.average()
                    })
                }
                
            }
        }
    
    func collision(faceAnchor: ARFaceAnchor){
        
        if cursor.frame.intersects(ball.frame){

            let val = Int(scoreValue.text!)
            
            scoreValue.text = String(val! + 1)

            let xwidth = ball.superview!.bounds.width - ball.frame.width
            let yheight = ball.superview!.bounds.height - ball.frame.height

            let xoffset = CGFloat(arc4random_uniform(UInt32(xwidth)))
            let yoffset = CGFloat(arc4random_uniform(UInt32(yheight)))

            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1, animations: {
                    self.ball.center.x = xoffset + self.ball.frame.width / 2
                    self.ball.center.y = yoffset + self.ball.frame.height / 2
                })
            }
            
        }
        
        let eyeBlinkValue = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0

        
        if cursor.frame.intersects(menuButton.frame) &&
            eyeBlinkValue > 0.5{
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "MainScreenSegue", sender: self)

            }
            
        }
        
    }
    
    
}

// 1
extension ballGame: ARSCNViewDelegate {
  // 2
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        // 3
        guard let device = ballGameView.device else {
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
    
    func renderer(
      _ renderer: SCNSceneRenderer,
      didUpdate node: SCNNode,
      for anchor: ARAnchor) {
       
      // 2
      guard let faceAnchor = anchor as? ARFaceAnchor,
        let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
          return
      }
        
      // 3
        leftEyeNode.simdTransform = faceAnchor.leftEyeTransform
        rightEyeNode.simdTransform = faceAnchor.rightEyeTransform

        faceGeometry.update(from: faceAnchor.geometry)
        hitTest()
        collision(faceAnchor: faceAnchor)
        
        
    }
    
}

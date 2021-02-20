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
    
    let sceneNodes = nodes()
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      let configuration = ARFaceTrackingConfiguration()
            
      ballGameView.session.run(configuration)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
            
      ballGameView.session.pause()
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()

            guard ARFaceTrackingConfiguration.isSupported else {
                fatalError("Face tracking is not supported on this device")
            }
        ballGameView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        ballGameView.delegate = self
    }
    
    var points: [CGPoint] = []
    
    
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

        node.addChildNode(sceneNodes.leftEyeNode)
        sceneNodes.leftEyeNode.addChildNode(sceneNodes.endPointLeftEye)
        node.addChildNode(sceneNodes.rightEyeNode)
        sceneNodes.rightEyeNode.addChildNode(sceneNodes.endPointRightEye)

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
        sceneNodes.leftEyeNode.simdTransform = faceAnchor.leftEyeTransform
        sceneNodes.rightEyeNode.simdTransform = faceAnchor.rightEyeTransform

        faceGeometry.update(from: faceAnchor.geometry)

        let lookPoint = self.sceneNodes.hitTest(leftEyeNode: sceneNodes.leftEyeNode, endPointLeftEye: sceneNodes.endPointLeftEye, rightEyeNode: sceneNodes.rightEyeNode, endPointRightEye: sceneNodes.endPointRightEye, nodeInFrontOfScreen: sceneNodes.nodeInFrontOfScreen)
        self.cursor.center = lookPoint
        collision(faceAnchor: faceAnchor)
        
        
    }
    
}

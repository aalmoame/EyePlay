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
    let mainThread = DispatchQueue.main
    
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
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
        
        cursor.frame.size = CGSize(width: cursorSize.width, height: cursorSize.height);
        cursor.tintColor = cursorColor;
        cursor.layer.zPosition = 1
        menuButton.layer.cornerRadius = 10;
        menuButton.layer.borderWidth = 10.0;
        
        ballGameView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen);
        ballGameView.scene.background.contents = UIColor.black;
        ballGameView.delegate = self;
    }
        
    func collisionBall(){
    
        let val = Int(scoreValue.text!)
        
        scoreValue.text = String(val! + 1)

        let xwidth = ball.superview!.bounds.width - ball.frame.width
        let yheight = ball.superview!.bounds.height - ball.frame.height

        let xoffset = CGFloat(arc4random_uniform(UInt32(xwidth)))
        let yoffset = CGFloat(arc4random_uniform(UInt32(yheight)))

        
        mainThread.async {
            UIView.animate(withDuration: 0.1, animations: {
                self.ball.center.x = xoffset + self.ball.frame.width / 2
                self.ball.center.y = yoffset + self.ball.frame.height / 2
            })
        }
            
        
    }
        
    func collisionMenuButton(){
        
        mainThread.async {
            self.performSegue(withIdentifier: "MainScreenSegue", sender: self)
        
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
       
      guard let faceAnchor = anchor as? ARFaceAnchor,
        let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
          return
      }
        

        sceneNodes.leftEyeNode.simdTransform = faceAnchor.leftEyeTransform
        sceneNodes.rightEyeNode.simdTransform = faceAnchor.rightEyeTransform

        faceGeometry.update(from: faceAnchor.geometry)
                
        self.sceneNodes.hitTest(withFaceAnchor: faceAnchor, cursor: cursor)
        
        let eyeBlinkValue = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
        
        mainThread.async {
            if self.cursor.frame.intersects(self.ball.frame){
                self.collisionBall()
                self.menuButton.layer.borderColor = UIColor.clear.cgColor

            }
            
            else if self.cursor.frame.intersects(self.menuButton.frame){
                
                self.menuButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5{
                    self.collisionMenuButton()
                }
                
            }
            else{
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
            }
        }
        
    }
    
}

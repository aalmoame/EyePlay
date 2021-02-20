//
//  ViewController.swift
//  Emoji Bling
//
//  Created by Amen Al-Moamen on 2/15/21.
//

import UIKit
import ARKit
import VisionKit




//main view class
class EyePlay: UIViewController{
    
    //Elements connected to the storyboard
    @IBOutlet var mainView: ARSCNView!
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var ballGameButton: UIButton!
    
    let sceneNodes = nodes()


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

        mainView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        mainView.delegate = self


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

        node.addChildNode(sceneNodes.leftEyeNode)
        sceneNodes.leftEyeNode.addChildNode(sceneNodes.endPointLeftEye)
        node.addChildNode(sceneNodes.rightEyeNode)
        sceneNodes.rightEyeNode.addChildNode(sceneNodes.endPointRightEye)

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
        
        sceneNodes.leftEyeNode.simdTransform = faceAnchor.leftEyeTransform
        sceneNodes.rightEyeNode.simdTransform = faceAnchor.rightEyeTransform

        faceGeometry.update(from: faceAnchor.geometry)
        
        let lookPoint = self.sceneNodes.hitTest(leftEyeNode: sceneNodes.leftEyeNode, endPointLeftEye: sceneNodes.endPointLeftEye, rightEyeNode: sceneNodes.rightEyeNode, endPointRightEye: sceneNodes.endPointRightEye, nodeInFrontOfScreen: sceneNodes.nodeInFrontOfScreen)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.005, animations: {
                self.cursor.center = lookPoint
            })
        }
        
        collision(faceAnchor: faceAnchor)
        
    }
    
}


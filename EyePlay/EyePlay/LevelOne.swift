//
//  LevelOne.swift
//  EyePlay
//
//  Created by Abdullah Ramzan on 3/5/21.
//

import UIKit
import ARKit
import VisionKit

class LevelOne: UIViewController, ARSessionDelegate {
        
    @IBOutlet var levelOneView: ARSCNView!

    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var goalBlock: UIButton!
    
    let sceneNodes = nodes()
    let mainThread = DispatchQueue.main

    //sets the view up
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      let configuration = ARFaceTrackingConfiguration()
      levelOneView.session.run(configuration)
    }
    
    
    // pauses the view
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      levelOneView.session.pause()
    }
    
    //configures the screen once its loaded up
    override func viewDidLoad() {
        super.viewDidLoad()

        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }

        cursor.frame.size = CGSize(width: cursorSize.width, height: cursorSize.height);
        cursor.tintColor = cursorColor
        cursor.layer.zPosition = 1;
        
        menuButton.layer.cornerRadius = 10;
        menuButton.layer.borderWidth = 10;
        goalBlock.layer.cornerRadius = 10;
        goalBlock.layer.borderWidth = 10;
        
        levelOneView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        levelOneView.scene.background.contents = UIColor.black
        levelOneView.delegate = self

    }
    
    func collisionMenuButton(){

            mainThread.async {
                self.performSegue(withIdentifier: "MainScreenSegue", sender: self)
            }
    }
    
    func collisionGoalBlock(){
            mainThread.async {
                self.performSegue(withIdentifier: "LevelTwoSegue", sender: self)
            }
    }
    
}


extension LevelOne: ARSCNViewDelegate {
    
    //a scene renderer that returns a scene node given a face anchor, runs once
    
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = levelOneView.device else {
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
                
        self.sceneNodes.hitTest(withFaceAnchor: faceAnchor, cursor: cursor)
            
        
        let eyeBlinkValue = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
        
        mainThread.async {
            if self.cursor.frame.intersects(self.menuButton.frame){
                self.menuButton.layer.borderColor = UIColor.red.cgColor
                if eyeBlinkValue > 0.5{
                    self.collisionMenuButton()
                }
            }
            else if self.cursor.frame.intersects(self.goalBlock.frame){
                self.goalBlock.layer.borderColor = UIColor.red.cgColor
                if eyeBlinkValue > 0.5{
                    self.collisionGoalBlock()
                }
            }
            else{
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.goalBlock.layer.borderColor = UIColor.clear.cgColor
            }
        }
        
    }
    
}


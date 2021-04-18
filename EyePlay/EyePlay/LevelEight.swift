//
//  LevelEight.swift
//  EyePlay
//
//  Created by Abdullah Ramzan on 3/26/21.
//

import UIKit
import ARKit
import VisionKit

class LevelEight: UIViewController, ARSessionDelegate {
    
    @IBOutlet var levelEightView: ARSCNView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var goalBlock: UIButton!
    @IBOutlet weak var cursor: UIImageView!
    
    let sceneNodes = nodes()
    let mainThread = DispatchQueue.main
    
    var seconds = selectionTime
    var timer = Timer()
    var isTimerRunning = false
    var hoveringMenu = false
    var hoveringGoal = false
    
    var player: AVAudioPlayer?
    
    func playSelectionSound() {
                
        let path = Bundle.main.path(forResource: "select.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    func runTimer(button: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(LevelEight.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        animate(button: button)
    }
    @objc func updateTimer() {
        seconds -= 1
    }
    func resetTimer(){
        timer.invalidate()
        isTimerRunning = false
        seconds = 2
    }
    func resetColor(button: UIButton){
        button.layer.backgroundColor = UIColor.white.cgColor
    }
    
    //sets the view up
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      let configuration = ARFaceTrackingConfiguration()
      levelEightView.session.run(configuration)
    }
    
    
    // pauses the view
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      levelEightView.session.pause()
    }
    
    //configures the screen once its loaded up
    override func viewDidLoad() {
        super.viewDidLoad()
        playSelectionSound()
        //guard ARFaceTrackingConfiguration.isSupported else {
            //fatalError("Face tracking is not supported on this device")
        //}

        cursor.frame.size = CGSize(width: cursorSize.width, height: cursorSize.height);
        cursor.tintColor = cursorColor
        cursor.layer.zPosition = 1;
        menuButton.layer.cornerRadius = 5;
        menuButton.layer.borderWidth = 10;
        goalBlock.layer.cornerRadius = 5;
        goalBlock.layer.borderWidth = 10;
        levelEightView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        levelEightView.scene.background.contents = UIColor.black
        levelEightView.delegate = self

    }
    
    func collisionMenuButton(){

            mainThread.async {
                self.performSegue(withIdentifier: "MainScreenSegue", sender: self)
            }
    }
    
    func collisionGoalBlock(){

            mainThread.async {
                self.performSegue(withIdentifier: "MainScreenSegue", sender: self)
            }
    }

}

extension LevelEight: ARSCNViewDelegate {
    
    //a scene renderer that returns a scene node given a face anchor, runs once
    
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = levelEightView.device else {
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
            
        

        mainThread.async {
            if self.cursor.frame.intersects(self.menuButton.frame){
                self.menuButton.layer.borderColor = UIColor.systemBlue.cgColor
                if !self.isTimerRunning{
                    self.runTimer(button: self.menuButton)
                }
                
                if self.hoveringMenu && self.seconds <= 0 {
                    self.collisionMenuButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringMenu{
                    self.resetTimer()
                }
                
                self.hoveringMenu = true
                self.hoveringGoal = false
            }
            else if self.cursor.frame.intersects(self.goalBlock.frame){
                self.goalBlock.layer.borderColor = UIColor.systemBlue.cgColor
                if !self.isTimerRunning{
                    self.runTimer(button: self.goalBlock)
                }
                
                if self.hoveringGoal && self.seconds <= 0 {
                    self.collisionGoalBlock()
                    self.resetTimer()
                    
                }
                else if !self.hoveringGoal{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringGoal = true
            }
            else{
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.goalBlock.layer.borderColor = UIColor.clear.cgColor
                
                self.hoveringMenu = false
                self.hoveringGoal = false
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.goalBlock)
                self.resetTimer()
            }
        }
        
    }
    
}


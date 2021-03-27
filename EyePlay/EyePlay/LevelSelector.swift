import UIKit
import ARKit
import VisionKit

//main view class
class LevelSelector: UIViewController{
    
    //Elements connected to the storyboard
    
    @IBOutlet var levelSelectorView: ARSCNView!
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var levelOneButton: UIButton!
    @IBOutlet weak var levelTwoButton: UIButton!
    @IBOutlet weak var levelThreeButton: UIButton!
    @IBOutlet weak var levelFourButton: UIButton!
    @IBOutlet weak var levelFiveButton: UIButton!
    @IBOutlet weak var levelSixButton: UIButton!
    @IBOutlet weak var levelSevenButton: UIButton!
    @IBOutlet weak var levelEightButton: UIButton!
    let sceneNodes = nodes()
    let mainThread = DispatchQueue.main

    //sets the view up
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      let configuration = ARFaceTrackingConfiguration()
      levelSelectorView.session.run(configuration)
    }
    
    // pauses the view
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
        levelSelectorView.session.pause()
    }
    
    //configures the screen once its loaded up
    override func viewDidLoad() {
        super.viewDidLoad()

        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }

        menuButton.layer.borderWidth = CGFloat(10.0)
        levelOneButton.layer.borderWidth = CGFloat(10.0)
        levelTwoButton.layer.borderWidth = CGFloat(10.0)
        levelThreeButton.layer.borderWidth = CGFloat(10.0)
        levelFourButton.layer.borderWidth = CGFloat(10.0)
        levelFiveButton.layer.borderWidth = CGFloat(10.0)
        levelSixButton.layer.borderWidth = CGFloat(10.0)
        levelSevenButton.layer.borderWidth = CGFloat(10.0)
        levelEightButton.layer.borderWidth = CGFloat(10.0)

        cursor.frame.size = CGSize(width: cursorSize.width, height: cursorSize.height);
        cursor.tintColor = cursorColor
        cursor.layer.zPosition = 1;
        menuButton.layer.cornerRadius = 10;
        levelOneButton.layer.cornerRadius = 10;
        levelTwoButton.layer.cornerRadius = 10;
        levelThreeButton.layer.cornerRadius = 10;
        levelFourButton.layer.cornerRadius = 10;
        levelFiveButton.layer.cornerRadius = 10;
        levelSixButton.layer.cornerRadius = 10;
        levelSevenButton.layer.cornerRadius = 10;
        levelEightButton.layer.cornerRadius = 10;

        levelSelectorView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        levelSelectorView.scene.background.contents = UIColor.black
        levelSelectorView.delegate = self


    }
    
    //checks if the cursor is on top of the game button and if the user blinks
    func collisionMenuButton(){

            //go to game screen when user blinks over button
            mainThread.async {
                self.performSegue(withIdentifier: "MainScreenSegue", sender: self)
            }
    }
    
    func collisionOneButton(){

            //go to game screen when user blinks over button
            mainThread.async {
                self.performSegue(withIdentifier: "LevelOneSegue", sender: self)
            }
    }
    
    func collisionTwoButton() {
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelTwoSegue", sender: self)
        }
    }
    
    func collisionThreeButton() {
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelThreeSegue", sender: self)
        }
    }
    
    func collisionFourButton() {
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelFourSegue", sender: self)
        }
    }
    
    func collisionFiveButton() {
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelFiveSegue", sender: self)
        }
    }
    
    func collisionSixButton() {
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelSixSegue", sender: self)
        }
    }
    
    func collisionSevenButton() {
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelSevenSegue", sender: self)
        }
    }
    
    func collisionEightButton() {
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelEightSegue", sender: self)
        }
    }
    
}

extension LevelSelector: ARSCNViewDelegate {
    
    //a scene renderer that returns a scene node given a face anchor, runs once
    
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = levelSelectorView.device else {
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
                
                    self.collisionMenuButton();
                }
            }
            else if self.cursor.frame.intersects(self.levelOneButton.frame){
                
                self.levelOneButton.layer.borderColor = UIColor.red.cgColor

                if eyeBlinkValue > 0.5{
                    self.collisionOneButton();
                }
                
            }
            else if self.cursor.frame.intersects(self.levelTwoButton.frame){
                
                self.levelTwoButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                
                    self.collisionTwoButton();
                }
            }
            else if self.cursor.frame.intersects(self.levelThreeButton.frame){
                
                self.levelThreeButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                
                    self.collisionThreeButton();
                }
            }
            else if self.cursor.frame.intersects(self.levelFourButton.frame){
                
                self.levelFourButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                
                    self.collisionFourButton();
                }
            }
            else if self.cursor.frame.intersects(self.levelFiveButton.frame){
                
                self.levelFiveButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                
                    self.collisionFiveButton();
                }
            }
            else if self.cursor.frame.intersects(self.levelSixButton.frame){
                
                self.levelSixButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                
                    self.collisionSixButton();
                }
            }
            else if self.cursor.frame.intersects(self.levelSevenButton.frame){
                
                self.levelSevenButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                
                    self.collisionSevenButton();
                }
            }
            else if self.cursor.frame.intersects(self.levelEightButton.frame){
                
                self.levelEightButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                
                    self.collisionEightButton();
                }
            }
            else{
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.levelOneButton.layer.borderColor = UIColor.clear.cgColor
                self.levelTwoButton.layer.borderColor = UIColor.clear.cgColor
                self.levelThreeButton.layer.borderColor = UIColor.clear.cgColor
                self.levelFourButton.layer.borderColor = UIColor.clear.cgColor
                self.levelFiveButton.layer.borderColor = UIColor.clear.cgColor
                self.levelSixButton.layer.borderColor = UIColor.clear.cgColor
                self.levelSevenButton.layer.borderColor = UIColor.clear.cgColor
                self.levelEightButton.layer.borderColor = UIColor.clear.cgColor
            }
        }

    }
    
}

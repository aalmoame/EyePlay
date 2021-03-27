import UIKit
import ARKit
import VisionKit

//main view class
class EyePlay: UIViewController{
    
    //Elements connected to the storyboard
    @IBOutlet var mainView: ARSCNView!
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var playNowButton: UIButton!
    @IBOutlet weak var miniGameButton: UIButton!
    @IBOutlet weak var levelButton: UIButton!
    
    let sceneNodes = nodes()
    let mainThread = DispatchQueue.main


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

        miniGameButton.layer.borderWidth = CGFloat(10.0)
        settingsButton.layer.borderWidth = CGFloat(10.0)
        playNowButton.layer.borderWidth = CGFloat(10.0)
        levelButton.layer.borderWidth = CGFloat(10.0)
        
        cursor.frame.size = CGSize(width: cursorSize.width, height: cursorSize.height);
        cursor.tintColor = cursorColor
        cursor.layer.zPosition = 1;
        miniGameButton.layer.cornerRadius = 10;
        settingsButton.layer.cornerRadius = 10;
        playNowButton.layer.cornerRadius = 10;
        levelButton.layer.cornerRadius = 10;
        
        mainView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        mainView.scene.background.contents = UIColor.black
        mainView.delegate = self


    }
    
    
    //checks if the cursor is on top of the game button and if the user blinks
    func collisionMenuButton(){

            //go to game screen when user blinks over button
            mainThread.async {
                self.performSegue(withIdentifier: "MiniGameSegue", sender: self)
            }
    }
    func collisionSettingsButton(){

            //go to game screen when user blinks over button
            mainThread.async {
                self.performSegue(withIdentifier: "SettingsSegue", sender: self)
            }
    }
    
    func collisionPlayNowButton() {
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelOneSegue", sender: self)
        }
    }
    
    func collisionLevelButton() {
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelSelectorSegue", sender: self)
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
        
        self.sceneNodes.hitTest(withFaceAnchor: faceAnchor, cursor: cursor)
            
        
        let eyeBlinkValue = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
        
        mainThread.async {
            if self.cursor.frame.intersects(self.miniGameButton.frame){

                self.miniGameButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5{
                
                    self.collisionMenuButton();
                }
            }
            else if self.cursor.frame.intersects(self.settingsButton.frame){
                
                self.settingsButton.layer.borderColor = UIColor.red.cgColor

                if eyeBlinkValue > 0.5{
                    self.collisionSettingsButton();
                }
                
            }
            else if self.cursor.frame.intersects(self.playNowButton.frame){
                
                self.playNowButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                
                    self.collisionPlayNowButton();
                }
            }
            else if self.cursor.frame.intersects(self.levelButton.frame){
                
                self.levelButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                
                    self.collisionLevelButton();
                }
            }
            else{
                self.miniGameButton.layer.borderColor = UIColor.clear.cgColor
                self.settingsButton.layer.borderColor = UIColor.clear.cgColor
                self.playNowButton.layer.borderColor = UIColor.clear.cgColor
                self.levelButton.layer.borderColor = UIColor.clear.cgColor

            }
        }

        
        
    }
    
}

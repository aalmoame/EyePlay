import UIKit
import ARKit
import VisionKit



class MiniGames: UIViewController, ARSessionDelegate{

    @IBOutlet var miniGameView: ARSCNView!
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var TicTacToeButton: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var ballGameButton: UIButton!
    
    let sceneNodes = nodes()
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      let configuration = ARFaceTrackingConfiguration()
      miniGameView.session.run(configuration)
    }
    
    
    // pauses the view
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      miniGameView.session.pause()
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
        TicTacToeButton.layer.cornerRadius = 10;
        mainMenuButton.layer.cornerRadius = 10;
        ballGameButton.layer.cornerRadius = 10;
        
        miniGameView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        miniGameView.scene.background.contents = UIColor.black
        miniGameView.delegate = self

    }
    

    func collisionMenuButton(){

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "MainMenuSegue", sender: self)
            }
    }
    func collisionBallGameButton(){

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "BallGameSegue", sender: self)
            }
    }
    func collisionTicTacToeButton(){

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "TicTacToeSegue", sender: self)
            }
    }
}

extension MiniGames: ARSCNViewDelegate {
    
    //a scene renderer that returns a scene node given a face anchor, runs once
    
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = miniGameView.device else {
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

        
        if cursor.frame.intersects(mainMenuButton.frame) &&
            eyeBlinkValue > 0.5 {

            collisionMenuButton()
        }
        else if cursor.frame.intersects(TicTacToeButton.frame) &&
            eyeBlinkValue > 0.5 {

            collisionTicTacToeButton()
        }
        else if cursor.frame.intersects(ballGameButton.frame) &&
            eyeBlinkValue > 0.5 {

            collisionBallGameButton()
        }
        
    }
    
}

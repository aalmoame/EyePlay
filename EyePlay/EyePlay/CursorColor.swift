import UIKit
import ARKit
import VisionKit



//main view class
class CursorColor: UIViewController, ARSessionDelegate{

    @IBOutlet var cursorColorView: ARSCNView!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var grayButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var cursor: UIImageView!
    
    @IBAction func blueButtonTouch(_ sender: Any) {
        collisionBlueButton()
    }
    @IBAction func redButtonTouch(_ sender: Any) {
        collisionRedButton()
    }
    @IBAction func grayButtonTouch(_ sender: Any) {
        collisionGrayButton()
    }
    @IBAction func settingsButtonTouch(_ sender: Any) {
        collisionSettingsButton()
    }
    
    
    
    let sceneNodes = nodes()
    
    let mainThread = DispatchQueue.main
    
    //sets the view up
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      let configuration = ARFaceTrackingConfiguration()
      cursorColorView.session.run(configuration)
    }
    
    
    // pauses the view
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      cursorColorView.session.pause()
    }
    
    //configures the screen once its loaded up
    override func viewDidLoad() {
        super.viewDidLoad()

        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }

        cursor.frame.size = CGSize(width: cursorSize.width, height: cursorSize.height);
        cursor.tintColor = cursorColor;
        cursor.layer.zPosition = 1;
        
        blueButton.layer.cornerRadius = 10;
        redButton.layer.cornerRadius = 10;
        grayButton.layer.cornerRadius = 10;
        settingsButton.layer.cornerRadius = 10;

        blueButton.layer.borderWidth = 10;
        redButton.layer.borderWidth = 10;
        grayButton.layer.borderWidth = 10;
        settingsButton.layer.borderWidth = 10;
        
        cursorColorView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        cursorColorView.scene.background.contents = UIColor.black
        cursorColorView.delegate = self

    }
    

    func collisionBlueButton(){
        cursorColor = UIColor.blue
        cursor.tintColor = cursorColor
    }
    func collisionRedButton(){
        cursorColor = UIColor.red
        cursor.tintColor = cursorColor
    }
    func collisionGrayButton(){
        cursorColor = UIColor.gray
        cursor.tintColor = cursorColor
    }
    func collisionSettingsButton(){
            mainThread.async {
                self.performSegue(withIdentifier: "SettingsSegue", sender: self)
            }
    }
    
}

extension CursorColor: ARSCNViewDelegate {
    
    //a scene renderer that returns a scene node given a face anchor, runs once
    
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = cursorColorView.device else {
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


        sceneNodes.leftEyeNode.simdTransform = faceAnchor.leftEyeTransform;
        sceneNodes.rightEyeNode.simdTransform = faceAnchor.rightEyeTransform;

        faceGeometry.update(from: faceAnchor.geometry);

        self.sceneNodes.hitTest(withFaceAnchor: faceAnchor, cursor: cursor)
            
        
        let eyeBlinkValue = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
        
        mainThread.async {
            
            if self.cursor.frame.intersects(self.blueButton.frame){
                
                self.blueButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5{
                    self.collisionBlueButton();

                }

            }
            else if self.cursor.frame.intersects(self.redButton.frame){
                self.redButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5{
                    self.collisionRedButton();

                }
            }
            else if self.cursor.frame.intersects(self.grayButton.frame) {
                self.grayButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5{
                    self.collisionGrayButton();

                }
            }
            else if self.cursor.frame.intersects(self.settingsButton.frame){
                self.settingsButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5{
                    self.collisionSettingsButton();

                }
            }
            else{
                self.blueButton.layer.borderColor = UIColor.clear.cgColor
                self.redButton.layer.borderColor = UIColor.clear.cgColor
                self.grayButton.layer.borderColor = UIColor.clear.cgColor
                self.settingsButton.layer.borderColor = UIColor.clear.cgColor                
            }
        }
        
        
    }
    
}

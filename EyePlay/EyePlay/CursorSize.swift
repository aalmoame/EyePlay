import UIKit
import ARKit
import VisionKit



//main view class
class CursorSize: UIViewController, ARSessionDelegate{

    
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet var cursorSizeView: ARSCNView!
    @IBOutlet weak var smallButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var largeButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBAction func smallButtonTouch(_ sender: Any) {
        collisionSmallButton();
    }
    
    @IBAction func mediumButtonTouch(_ sender: Any) {
        collisionMediumButton();
    }
    @IBAction func largeButtonTouch(_ sender: Any) {
        collisionLargeButton();
    }
    @IBAction func settingsButtonTouch(_ sender: Any) {
        collisionSettingsButton();
    }
    
    let sceneNodes = nodes()
    
    //sets the view up
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      let configuration = ARFaceTrackingConfiguration()
      cursorSizeView.session.run(configuration)
    }
    
    
    // pauses the view
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      cursorSizeView.session.pause()
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
        smallButton.layer.cornerRadius = 10;
        mediumButton.layer.cornerRadius = 10;
        mediumButton.layer.cornerRadius = 10;
        largeButton.layer.cornerRadius = 10;
        settingsButton.layer.cornerRadius = 10;

        
        cursorSizeView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        cursorSizeView.scene.background.contents = UIColor.black
        cursorSizeView.delegate = self

    }
    

    func collisionSmallButton(){
        cursor.frame.size = CGSize(width: 50.0, height: 50.0);
        cursorSize.width = 50.0;
        cursorSize.height = 50.0;
    }
    func collisionMediumButton(){
        cursor.frame.size = CGSize(width: 100.0, height: 100.0);
        cursorSize.width = 100.0;
        cursorSize.height = 100.0;
    }
    func collisionLargeButton(){
        cursor.frame.size = CGSize(width: 150.0, height: 150.0);
        cursorSize.width = 150.0;
        cursorSize.height = 150.0;
    }
    func collisionSettingsButton(){
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "SettingsSegue", sender: self)
            }
    }
    
}

extension CursorSize: ARSCNViewDelegate {
    
    //a scene renderer that returns a scene node given a face anchor, runs once
    
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = cursorSizeView.device else {
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

        
        if cursor.frame.intersects(smallButton.frame) &&
            eyeBlinkValue > 0.5 {

            collisionSmallButton();
        }
        else if cursor.frame.intersects(mediumButton.frame) &&
            eyeBlinkValue > 0.5 {

            collisionMediumButton();
        }
        else if cursor.frame.intersects(largeButton.frame) &&
            eyeBlinkValue > 0.5 {

            collisionLargeButton();
        }
        else if cursor.frame.intersects(settingsButton.frame) &&
            eyeBlinkValue > 0.5 {

            collisionSettingsButton();
        }
        
        
    }
    
}

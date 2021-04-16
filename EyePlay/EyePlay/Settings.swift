import UIKit
import ARKit
import VisionKit



//main view class
class Settings: UIViewController, ARSessionDelegate{

    
    @IBOutlet var settingsView: ARSCNView!
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var sizeButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var colorButton: UIButton!
    
    let sceneNodes = nodes()
    let mainThread = DispatchQueue.main
    
    var seconds = 2
    var timer = Timer()
    var isTimerRunning = false
    var hoveringMenu = false
    var hoveringSize = false
    var hoveringColor = false
    
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(Settings.updateTimer)), userInfo: nil, repeats: true)
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
      settingsView.session.run(configuration)
    }
    
    
    // pauses the view
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      settingsView.session.pause()
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
        sizeButton.layer.cornerRadius = 5;
        menuButton.layer.cornerRadius = 5;
        colorButton.layer.cornerRadius = 5;
        sizeButton.layer.borderWidth = 10;
        menuButton.layer.borderWidth = 10;
        colorButton.layer.borderWidth = 10;
        settingsView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        settingsView.scene.background.contents = UIColor.black
        settingsView.delegate = self

    }
    

    func collisionMenuButton(){
        playSelectionSound()
            mainThread.async {
                self.performSegue(withIdentifier: "MainScreenSegue", sender: self)
            }
    }
    func collisionSizeButton(){
        playSelectionSound()
            mainThread.async {
                self.performSegue(withIdentifier: "SizeSegue", sender: self)
            }
    }
    func collisionColorButton(){
        playSelectionSound()
            mainThread.async {
                self.performSegue(withIdentifier: "ColorSegue", sender: self)
            }
    }
}

extension Settings: ARSCNViewDelegate {
    
    //a scene renderer that returns a scene node given a face anchor, runs once
    
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = settingsView.device else {
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

            if self.cursor.frame.intersects(self.sizeButton.frame){
                self.sizeButton.layer.borderColor = UIColor.systemBlue.cgColor

                if !self.isTimerRunning{
                    self.runTimer(button: self.sizeButton)
                }
                
                if self.hoveringSize && self.seconds <= 0 {
                    self.collisionSizeButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringSize{
                    self.resetTimer()
                }
                
                self.hoveringSize = true
                self.hoveringMenu = false
                self.hoveringColor = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.colorButton)
            }
            else if self.cursor.frame.intersects(self.colorButton.frame) {
                self.colorButton.layer.borderColor = UIColor.systemBlue.cgColor

                if !self.isTimerRunning{
                    self.runTimer(button: self.colorButton)
                }
                
                if self.hoveringColor && self.seconds <= 0 {
                    self.collisionColorButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringColor{
                    self.resetTimer()
                }
                
                self.hoveringSize = false
                self.hoveringMenu = false
                self.hoveringColor = true
                
                self.resetColor(button: self.sizeButton)
                self.resetColor(button: self.menuButton)
                
            }
            else if self.cursor.frame.intersects(self.menuButton.frame) {
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
                
                self.hoveringSize = false
                self.hoveringMenu = true
                self.hoveringColor = false
                
                self.resetColor(button: self.sizeButton)
                self.resetColor(button: self.colorButton)
            }
            else{
                self.sizeButton.layer.borderColor = UIColor.clear.cgColor
                self.colorButton.layer.borderColor = UIColor.clear.cgColor
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                
                self.hoveringColor = false
                self.hoveringSize = false
                self.hoveringMenu = false

                self.resetColor(button: self.colorButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.sizeButton)
                
                self.resetTimer()
            }

        }

    }
    
}

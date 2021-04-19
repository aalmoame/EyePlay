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
    @IBOutlet weak var selectionTimeButton: UIButton!
    @IBOutlet weak var emergencyButton: UIButton!
    
    let sceneNodes = nodes()
    let mainThread = DispatchQueue.main
    
    var seconds = selectionTime
    var timer = Timer()
    var isTimerRunning = false
    var hoveringMenu = false
    var hoveringSize = false
    var hoveringColor = false
    var hoveringSelectionTime = false
    var hoveringEmergency = false
    
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
    
    @IBAction func pressEmergency(_ sender: Any) {
        collisionEmergencyButton()
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
        seconds = selectionTime
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
        selectionTimeButton.layer.cornerRadius = 5;
        sizeButton.layer.borderWidth = 10;
        menuButton.layer.borderWidth = 10;
        colorButton.layer.borderWidth = 10;
        selectionTimeButton.layer.borderWidth = 10;
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
    func collisionSelectionTime(){
        playSelectionSound()
            mainThread.async {
                self.performSegue(withIdentifier: "SelectionTimeSegue", sender: self)
            }
    }
    func collisionEmergencyButton() {
        mainThread.async {
            let path = Bundle.main.path(forResource: "emergency.mp3", ofType:nil)!
            let url = URL(fileURLWithPath: path)

            do {
                self.player = try AVAudioPlayer(contentsOf: url)
                self.player?.numberOfLoops = 1000
                self.player?.play()
            } catch {
                // couldn't load file :(
            }
            var image = UIImage(systemName: "ladybug")
            image = image?.withTintColor(UIColor.black)
            
            JSSAlertView().show(
                self,
                  title: "ALERT",
                  text: "User is requesting guidance",
                  buttonText: "OK",
                color: UIColor.white,
                iconImage: image
            ).addAction {
                self.player?.stop()
            }
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
                self.hoveringSelectionTime = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.colorButton)
                self.resetColor(button: self.selectionTimeButton)
                self.hoveringEmergency = false

                self.emergencyButton.backgroundColor = UIColor.clear
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
                self.hoveringSelectionTime = false
                
                self.resetColor(button: self.sizeButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.selectionTimeButton)
                self.hoveringEmergency = false
                
                self.emergencyButton.backgroundColor = UIColor.clear
                
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
                self.hoveringSelectionTime = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.sizeButton)
                self.resetColor(button: self.colorButton)
                self.resetColor(button: self.selectionTimeButton)
            }
            else if self.cursor.frame.intersects(self.selectionTimeButton.frame) {
                self.selectionTimeButton.layer.borderColor = UIColor.systemBlue.cgColor

                if !self.isTimerRunning{
                    self.runTimer(button: self.selectionTimeButton)
                }
                
                if self.hoveringSelectionTime && self.seconds <= 0 {
                    self.collisionSelectionTime()
                    self.resetTimer()
                    
                }
                else if !self.hoveringSelectionTime{
                    self.resetTimer()
                }
                
                self.hoveringEmergency = false
                self.hoveringSize = false
                self.hoveringMenu = false
                self.hoveringColor = false
                self.hoveringSelectionTime = true
                    
                
                self.resetColor(button: self.sizeButton)
                self.resetColor(button: self.colorButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.emergencyButton)
                self.emergencyButton.backgroundColor = UIColor.clear
            }
            else if self.cursor.frame.intersects(self.emergencyButton.frame) {
                self.emergencyButton.layer.borderColor = UIColor.systemBlue.cgColor
                

                if !self.isTimerRunning{
                    self.runTimer(button: self.emergencyButton)
                }
                
                if self.hoveringEmergency && self.seconds <= 0 {
                    self.collisionEmergencyButton()
                    self.resetTimer()
                }
                else if !self.hoveringEmergency{
                    self.resetTimer()
                }
                
                self.hoveringSize = false
                self.hoveringMenu = false
                self.hoveringColor = false
                self.hoveringSelectionTime = true
                self.hoveringEmergency = true
                
                self.resetColor(button: self.sizeButton)
                self.resetColor(button: self.colorButton)
                self.resetColor(button: self.menuButton)

            }
            else{
                self.sizeButton.layer.borderColor = UIColor.clear.cgColor
                self.colorButton.layer.borderColor = UIColor.clear.cgColor
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.selectionTimeButton.layer.borderColor = UIColor.clear.cgColor

                
                self.hoveringColor = false
                self.hoveringSize = false
                self.hoveringMenu = false
                self.hoveringSelectionTime = false
                self.hoveringEmergency = false

                self.resetColor(button: self.colorButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.sizeButton)
                self.resetColor(button: self.selectionTimeButton)
                self.emergencyButton.backgroundColor = UIColor.clear
                
                self.resetTimer()
            }
            }

        }

    }

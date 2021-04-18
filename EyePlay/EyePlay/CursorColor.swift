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
    @IBOutlet weak var emergencyButton: UIButton!
    
    
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
    
    @IBAction func pressEmergency(_ sender: Any) {
        collisionEmergencyButton()
    }
    
    
    let sceneNodes = nodes()
    
    let mainThread = DispatchQueue.main
    
    //sets the view up
    
    var seconds = selectionTime
    var timer = Timer()
    var isTimerRunning = false
    var hoveringBlue = false
    var hoveringRed = false
    var hoveringGray = false
    var hoveringSettings = false
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

    func runTimer(button: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(CursorColor.updateTimer)), userInfo: nil, repeats: true)
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
        playSelectionSound()
        //guard ARFaceTrackingConfiguration.isSupported else {
            //fatalError("Face tracking is not supported on this device")
        //}

        cursor.frame.size = CGSize(width: cursorSize.width, height: cursorSize.height);
        cursor.tintColor = cursorColor;
        cursor.layer.zPosition = 1;
        
        blueButton.layer.cornerRadius = 5;
        redButton.layer.cornerRadius = 5;
        grayButton.layer.cornerRadius = 5;
        settingsButton.layer.cornerRadius = 5;

        blueButton.layer.borderWidth = 10;
        redButton.layer.borderWidth = 10;
        grayButton.layer.borderWidth = 10;
        settingsButton.layer.borderWidth = 10;
        
        cursorColorView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        cursorColorView.scene.background.contents = UIColor.black
        cursorColorView.delegate = self

    }
    

    func collisionBlueButton(){
        playSelectionSound()
        cursorColor = UIColor.blue
        cursor.tintColor = cursorColor
    }
    func collisionRedButton(){
        playSelectionSound()
        cursorColor = UIColor.red
        cursor.tintColor = cursorColor
    }
    func collisionGrayButton(){
        playSelectionSound()
        cursorColor = UIColor.gray
        cursor.tintColor = cursorColor
    }
    func collisionSettingsButton(){
            mainThread.async {
                self.performSegue(withIdentifier: "SettingsSegue", sender: self)
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
            
        mainThread.async {
            
            if self.cursor.frame.intersects(self.blueButton.frame){
                
                self.blueButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.blueButton)
                }
                
                if self.hoveringBlue && self.seconds <= 0 {
                    self.collisionBlueButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringBlue{
                    self.resetTimer()
                }
                
                self.hoveringBlue = true
                self.hoveringRed = false
                self.hoveringGray = false
                self.hoveringSettings = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.redButton)
                self.resetColor(button: self.grayButton)
                self.resetColor(button: self.settingsButton)
                self.emergencyButton.backgroundColor = UIColor.clear

            }
            else if self.cursor.frame.intersects(self.redButton.frame){
                self.redButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.redButton)
                }
                
                if self.hoveringRed && self.seconds <= 0 {
                    self.collisionRedButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringRed{
                    self.resetTimer()
                }
                
                self.hoveringBlue = false
                self.hoveringRed = true
                self.hoveringGray = false
                self.hoveringSettings = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.blueButton)
                self.resetColor(button: self.grayButton)
                self.resetColor(button: self.settingsButton)
                self.emergencyButton.backgroundColor = UIColor.clear
            }
            else if self.cursor.frame.intersects(self.grayButton.frame) {
                self.grayButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.grayButton)
                }
                
                if self.hoveringGray && self.seconds <= 0 {
                    self.collisionGrayButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringGray{
                    self.resetTimer()
                }
                
                self.hoveringBlue = false
                self.hoveringRed = false
                self.hoveringGray = true
                self.hoveringSettings = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.redButton)
                self.resetColor(button: self.blueButton)
                self.resetColor(button: self.settingsButton)
                self.emergencyButton.backgroundColor = UIColor.clear
            }
            else if self.cursor.frame.intersects(self.settingsButton.frame){
                self.settingsButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.settingsButton)
                }
                
                if self.hoveringSettings && self.seconds <= 0 {
                    self.collisionSettingsButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringSettings{
                    self.resetTimer()
                }
                
                self.hoveringBlue = false
                self.hoveringRed = false
                self.hoveringGray = false
                self.hoveringSettings = true
                self.hoveringEmergency = false
                
                self.resetColor(button: self.redButton)
                self.resetColor(button: self.grayButton)
                self.resetColor(button: self.blueButton)
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
                
                self.hoveringBlue = false
                self.hoveringRed = false
                self.hoveringGray = false
                self.hoveringSettings = false
                self.hoveringEmergency = true
                
                self.resetColor(button: self.redButton)
                self.resetColor(button: self.grayButton)
                self.resetColor(button: self.blueButton)
                self.resetColor(button: self.settingsButton)

            }
            else{
                self.blueButton.layer.borderColor = UIColor.clear.cgColor
                self.redButton.layer.borderColor = UIColor.clear.cgColor
                self.grayButton.layer.borderColor = UIColor.clear.cgColor
                self.settingsButton.layer.borderColor = UIColor.clear.cgColor
                
                self.hoveringSettings = false
                self.hoveringRed = false
                self.hoveringGray = false
                self.hoveringBlue = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.settingsButton)
                self.resetColor(button: self.redButton)
                self.resetColor(button: self.blueButton)
                self.resetColor(button: self.grayButton)
                self.emergencyButton.backgroundColor = UIColor.clear
                
                self.resetTimer()
            }
        }
        
        
    }
    
}

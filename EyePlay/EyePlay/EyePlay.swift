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
    @IBOutlet weak var emergencyButton: UIButton!
    
    let sceneNodes = nodes()
    let mainThread = DispatchQueue.main
    
    var seconds = selectionTime
    var timer = Timer()
    var isTimerRunning = false
    var hoveringMiniGames = false
    var hoveringSetting = false
    var hoveringPlay = false
    var hoveringLevelSelect = false
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(EyePlay.updateTimer)), userInfo: nil, repeats: true)
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

    
    @IBAction func pressEmergencyButton(_ sender: Any) {
        collisionEmergencyButton()
    }
    

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
        playSelectionSound()

        //guard ARFaceTrackingConfiguration.isSupported else {
            //fatalError("Face tracking is not supported on this device")
        //}

        miniGameButton.layer.borderWidth = CGFloat(10.0)
        settingsButton.layer.borderWidth = CGFloat(10.0)
        playNowButton.layer.borderWidth = CGFloat(10.0)
        levelButton.layer.borderWidth = CGFloat(10.0)
        
        cursor.frame.size = CGSize(width: cursorSize.width, height: cursorSize.height);
        cursor.tintColor = cursorColor
        cursor.layer.zPosition = 1;
        miniGameButton.layer.cornerRadius = 5;
        settingsButton.layer.cornerRadius = 5;
        playNowButton.layer.cornerRadius = 5;
        levelButton.layer.cornerRadius = 5;
        
        mainView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        mainView.scene.background.contents = UIColor.black
        mainView.delegate = self


    }
    
    
    //checks if the cursor is on top of the game button and if the user blinks
    func collisionMiniGameButton(){
        
            //go to game screen when user blinks over button
            mainThread.async {
                self.playSelectionSound()
                self.performSegue(withIdentifier: "MiniGameSegue", sender: self)
            }
    }
    func collisionSettingsButton(){
        
            //go to game screen when user blinks over button
            mainThread.async {
                self.playSelectionSound()
                self.performSegue(withIdentifier: "SettingsSegue", sender: self)
            }
    }
    
    func collisionPlayNowButton() {
        
        //go to level one when user blinks over button
        mainThread.async {
            self.playSelectionSound()
            self.performSegue(withIdentifier: "LevelOneSegue", sender: self)
        }
    }
    
    func collisionLevelButton() {
        //go to level one when user blinks over button
        
        mainThread.async {
            self.playSelectionSound()
            self.performSegue(withIdentifier: "LevelSelectorSegue", sender: self)
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
        
        
        mainThread.async {
            if self.cursor.frame.intersects(self.miniGameButton.frame){

                self.miniGameButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.miniGameButton)
                }
                
                if self.hoveringMiniGames && self.seconds <= 0 {
                    self.collisionMiniGameButton()
                }
                else if !self.hoveringMiniGames{
                    self.resetTimer()
                }
                
                self.hoveringSetting = false
                self.hoveringPlay = false
                self.hoveringLevelSelect = false
                self.hoveringMiniGames = true
                self.hoveringEmergency = false
                
                self.resetColor(button: self.playNowButton)
                self.resetColor(button: self.levelButton)
                self.resetColor(button: self.settingsButton)
                self.emergencyButton.backgroundColor = UIColor.clear
                
                
            }
            else if self.cursor.frame.intersects(self.settingsButton.frame){
                
                self.settingsButton.layer.borderColor = UIColor.systemBlue.cgColor

                if !self.isTimerRunning{
                    self.runTimer(button: self.settingsButton)
                }
                
                if self.hoveringSetting && self.seconds <= 0 {
                    self.collisionSettingsButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringSetting{
                    self.resetTimer()
                }
                
                self.hoveringSetting = true
                self.hoveringPlay = false
                self.hoveringLevelSelect = false
                self.hoveringMiniGames = false
                self.hoveringEmergency = false
                self.resetColor(button: self.playNowButton)
                self.resetColor(button: self.levelButton)
                self.resetColor(button: self.miniGameButton)
                self.emergencyButton.backgroundColor = UIColor.clear

                
                
            }
            else if self.cursor.frame.intersects(self.playNowButton.frame){
                
                self.playNowButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.playNowButton)
                }
                
                if self.hoveringPlay && self.seconds <= 0 {
                    self.collisionPlayNowButton()
                    self.resetTimer()
                }
                else if !self.hoveringPlay{
                    self.resetTimer()
                }
                
                self.hoveringSetting = false
                self.hoveringPlay = true
                self.hoveringLevelSelect = false
                self.hoveringMiniGames = false
                self.hoveringEmergency = false
                self.resetColor(button: self.settingsButton)
                self.resetColor(button: self.levelButton)
                self.resetColor(button: self.miniGameButton)
                self.emergencyButton.backgroundColor = UIColor.clear

            }
            else if self.cursor.frame.intersects(self.levelButton.frame){
                
                self.levelButton.layer.borderColor = UIColor.systemBlue.cgColor
                

                if !self.isTimerRunning{
                    self.runTimer(button: self.levelButton)
                }
                
                if self.hoveringLevelSelect && self.seconds <= 0 {
                    self.collisionLevelButton()
                    self.resetTimer()
                }
                else if !self.hoveringLevelSelect{
                    self.resetTimer()
                }
                
                self.hoveringSetting = false
                self.hoveringPlay = false
                self.hoveringLevelSelect = true
                self.hoveringMiniGames = false
                self.hoveringEmergency = false
                self.resetColor(button: self.playNowButton)
                self.resetColor(button: self.settingsButton)
                self.resetColor(button: self.miniGameButton)
                self.emergencyButton.backgroundColor = UIColor.clear

            }
            else if self.cursor.frame.intersects(self.emergencyButton.frame){
                
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
                
                self.hoveringSetting = false
                self.hoveringPlay = false
                self.hoveringLevelSelect = false
                self.hoveringMiniGames = false
                self.hoveringEmergency = true
                self.resetColor(button: self.playNowButton)
                self.resetColor(button: self.settingsButton)
                self.resetColor(button: self.miniGameButton)
                self.resetColor(button: self.levelButton)
                
            }
            else{
                self.miniGameButton.layer.borderColor = UIColor.clear.cgColor
                self.settingsButton.layer.borderColor = UIColor.clear.cgColor
                self.playNowButton.layer.borderColor = UIColor.clear.cgColor
                self.levelButton.layer.borderColor = UIColor.clear.cgColor
                
                self.hoveringSetting = false
                self.hoveringPlay = false
                self.hoveringLevelSelect = false
                self.hoveringMiniGames = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.playNowButton)
                self.resetColor(button: self.settingsButton)
                self.resetColor(button: self.miniGameButton)
                self.resetColor(button: self.levelButton)
                self.emergencyButton.backgroundColor = UIColor.clear

                
                self.resetTimer()

            }
        }

        
        
    }
    
}

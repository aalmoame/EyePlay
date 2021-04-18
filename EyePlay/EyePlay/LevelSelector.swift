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
    @IBOutlet weak var emergencyButton: UIButton!
    
    let sceneNodes = nodes()
    let mainThread = DispatchQueue.main
    
    var seconds = selectionTime
    var timer = Timer()
    var isTimerRunning = false
    var hoveringMenu = false
    var hoveringOne = false
    var hoveringTwo = false
    var hoveringThree = false
    var hoveringFour = false
    var hoveringFive = false
    var hoveringSix = false
    var hoveringSeven = false
    var hoveringEight = false
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
    
    
    func runTimer(button: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(LevelSelector.updateTimer)), userInfo: nil, repeats: true)
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
        playSelectionSound()
        //guard ARFaceTrackingConfiguration.isSupported else {
            //fatalError("Face tracking is not supported on this device")
        //}

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
        menuButton.layer.cornerRadius = 5;
        levelOneButton.layer.cornerRadius = 5;
        levelTwoButton.layer.cornerRadius = 5;
        levelThreeButton.layer.cornerRadius = 5;
        levelFourButton.layer.cornerRadius = 5;
        levelFiveButton.layer.cornerRadius = 5;
        levelSixButton.layer.cornerRadius = 5;
        levelSevenButton.layer.cornerRadius = 5;
        levelEightButton.layer.cornerRadius = 5;

        levelSelectorView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        levelSelectorView.scene.background.contents = UIColor.black
        levelSelectorView.delegate = self


    }
    
    //checks if the cursor is on top of the game button and if the user blinks
    func collisionMenuButton(){
        playSelectionSound()
            //go to game screen when user blinks over button
            mainThread.async {
                self.performSegue(withIdentifier: "MainScreenSegue", sender: self)
            }
    }
    
    func collisionOneButton(){
        playSelectionSound()
            //go to game screen when user blinks over button
            mainThread.async {
                self.performSegue(withIdentifier: "LevelOneSegue", sender: self)
            }
    }
    
    func collisionTwoButton() {
        playSelectionSound()
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelTwoSegue", sender: self)
        }
    }
    
    func collisionThreeButton() {
        playSelectionSound()
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelThreeSegue", sender: self)
        }
    }
    
    func collisionFourButton() {
        playSelectionSound()
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelFourSegue", sender: self)
        }
    }
    
    func collisionFiveButton() {
        playSelectionSound()
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelFiveSegue", sender: self)
        }
    }
    
    func collisionSixButton() {
        playSelectionSound()
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelSixSegue", sender: self)
        }
    }
    
    func collisionSevenButton() {
        playSelectionSound()
        //go to level one when user blinks over button
        mainThread.async {
            self.performSegue(withIdentifier: "LevelSevenSegue", sender: self)
        }
    }
    
    func collisionEightButton() {
        playSelectionSound()
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
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.levelOneButton)
                self.resetColor(button: self.levelTwoButton)
                self.resetColor(button: self.levelThreeButton)
                self.resetColor(button: self.levelFourButton)
                self.resetColor(button: self.levelFiveButton)
                self.resetColor(button: self.levelSixButton)
                self.resetColor(button: self.levelSevenButton)
                self.resetColor(button: self.levelEightButton)
                self.emergencyButton.backgroundColor = UIColor.clear

            }
            else if self.cursor.frame.intersects(self.levelOneButton.frame){
                
                self.levelOneButton.layer.borderColor = UIColor.systemBlue.cgColor

                if !self.isTimerRunning{
                    self.runTimer(button: self.levelOneButton)
                }
                
                if self.hoveringOne && self.seconds <= 0 {
                    self.collisionOneButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringOne{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringOne = true
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.levelTwoButton)
                self.resetColor(button: self.levelThreeButton)
                self.resetColor(button: self.levelFourButton)
                self.resetColor(button: self.levelFiveButton)
                self.resetColor(button: self.levelSixButton)
                self.resetColor(button: self.levelSevenButton)
                self.resetColor(button: self.levelEightButton)
                self.emergencyButton.backgroundColor = UIColor.clear
                
            }
            else if self.cursor.frame.intersects(self.levelTwoButton.frame){
                
                self.levelTwoButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.levelTwoButton)
                }
                
                if self.hoveringTwo && self.seconds <= 0 {
                    self.collisionTwoButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringTwo{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringOne = false
                self.hoveringTwo = true
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.levelOneButton)
                self.resetColor(button: self.levelThreeButton)
                self.resetColor(button: self.levelFourButton)
                self.resetColor(button: self.levelFiveButton)
                self.resetColor(button: self.levelSixButton)
                self.resetColor(button: self.levelSevenButton)
                self.resetColor(button: self.levelEightButton)
                self.emergencyButton.backgroundColor = UIColor.clear
            }
            else if self.cursor.frame.intersects(self.levelThreeButton.frame){
                
                self.levelThreeButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.levelThreeButton)
                }
                
                if self.hoveringThree && self.seconds <= 0 {
                    self.collisionThreeButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringThree{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = true
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.levelOneButton)
                self.resetColor(button: self.levelTwoButton)
                self.resetColor(button: self.levelFourButton)
                self.resetColor(button: self.levelFiveButton)
                self.resetColor(button: self.levelSixButton)
                self.resetColor(button: self.levelSevenButton)
                self.resetColor(button: self.levelEightButton)
                self.emergencyButton.backgroundColor = UIColor.clear
            }
            else if self.cursor.frame.intersects(self.levelFourButton.frame){
                
                self.levelFourButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.levelFourButton)
                }
                
                if self.hoveringFour && self.seconds <= 0 {
                    self.collisionFourButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringFour{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = true
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.levelOneButton)
                self.resetColor(button: self.levelThreeButton)
                self.resetColor(button: self.levelTwoButton)
                self.resetColor(button: self.levelFiveButton)
                self.resetColor(button: self.levelSixButton)
                self.resetColor(button: self.levelSevenButton)
                self.resetColor(button: self.levelEightButton)
                self.emergencyButton.backgroundColor = UIColor.clear
            }
            else if self.cursor.frame.intersects(self.levelFiveButton.frame){
                
                self.levelFiveButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.levelFiveButton)
                }
                
                if self.hoveringFive && self.seconds <= 0 {
                    self.collisionFiveButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringFive{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = true
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.levelOneButton)
                self.resetColor(button: self.levelThreeButton)
                self.resetColor(button: self.levelFourButton)
                self.resetColor(button: self.levelTwoButton)
                self.resetColor(button: self.levelSixButton)
                self.resetColor(button: self.levelSevenButton)
                self.resetColor(button: self.levelEightButton)
                self.emergencyButton.backgroundColor = UIColor.clear
            }
            else if self.cursor.frame.intersects(self.levelSixButton.frame){
                
                self.levelSixButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.levelSixButton)
                }
                
                if self.hoveringSix && self.seconds <= 0 {
                    self.collisionSixButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringSix{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = true
                self.hoveringSeven = false
                self.hoveringEight = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.levelOneButton)
                self.resetColor(button: self.levelThreeButton)
                self.resetColor(button: self.levelFourButton)
                self.resetColor(button: self.levelFiveButton)
                self.resetColor(button: self.levelTwoButton)
                self.resetColor(button: self.levelSevenButton)
                self.resetColor(button: self.levelEightButton)
                self.emergencyButton.backgroundColor = UIColor.clear
            }
            else if self.cursor.frame.intersects(self.levelSevenButton.frame){
                
                self.levelSevenButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.levelSevenButton)
                }
                
                if self.hoveringSeven && self.seconds <= 0 {
                    self.collisionSevenButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringSeven{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = true
                self.hoveringEight = false
                self.hoveringEmergency = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.levelOneButton)
                self.resetColor(button: self.levelThreeButton)
                self.resetColor(button: self.levelFourButton)
                self.resetColor(button: self.levelFiveButton)
                self.resetColor(button: self.levelSixButton)
                self.resetColor(button: self.levelTwoButton)
                self.resetColor(button: self.levelEightButton)
                self.emergencyButton.backgroundColor = UIColor.clear
            }
            else if self.cursor.frame.intersects(self.levelEightButton.frame){
                
                self.levelEightButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.levelEightButton)
                }
                
                if self.hoveringEight && self.seconds <= 0 {
                    self.collisionEightButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringEight{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = true
                self.hoveringEmergency = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.levelOneButton)
                self.resetColor(button: self.levelThreeButton)
                self.resetColor(button: self.levelFourButton)
                self.resetColor(button: self.levelFiveButton)
                self.resetColor(button: self.levelSixButton)
                self.resetColor(button: self.levelSevenButton)
                self.resetColor(button: self.levelTwoButton)
                self.emergencyButton.backgroundColor = UIColor.clear
            }
            else if self.cursor.frame.intersects(self.levelEightButton.frame){
                
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
                
                self.hoveringMenu = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                self.hoveringEmergency = true
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.levelOneButton)
                self.resetColor(button: self.levelThreeButton)
                self.resetColor(button: self.levelFourButton)
                self.resetColor(button: self.levelFiveButton)
                self.resetColor(button: self.levelSixButton)
                self.resetColor(button: self.levelSevenButton)
                self.resetColor(button: self.levelTwoButton)
                self.resetColor(button: self.levelEightButton)
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
                
                self.hoveringMenu = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                self.hoveringEmergency = false

                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.levelOneButton)
                self.resetColor(button: self.levelTwoButton)
                self.resetColor(button: self.levelThreeButton)
                self.resetColor(button: self.levelFourButton)
                self.resetColor(button: self.levelFiveButton)
                self.resetColor(button: self.levelSixButton)
                self.resetColor(button: self.levelSevenButton)
                self.resetColor(button: self.levelEightButton)
                self.emergencyButton.backgroundColor = UIColor.clear

                self.resetTimer()
            }
        }

    }
    
}

import UIKit
import ARKit
import VisionKit



//main view class
class SelectionTime: UIViewController{


    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet var timeView: ARSCNView!
    @IBOutlet weak var cursor: UIImageView!
    
    let sceneNodes = nodes()
    
    let mainThread = DispatchQueue.main
    
    //sets the view up
    
    var seconds = selectionTime
    var timer = Timer()
    var isTimerRunning = false
    var hoveringOne = false
    var hoveringTwo = false
    var hoveringThree = false
    var hoveringSettings = false
    
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
    @IBAction func tapOne(_ sender: Any) {
        collisionOne()
    }
    @IBAction func tapTwo(_ sender: Any) {
        collisionTwo()
    }
    @IBAction func tapThree(_ sender: Any) {
        collisionThree()
    }
    
    func runTimer(button: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(SelectionTime.updateTimer)), userInfo: nil, repeats: true)
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
      timeView.session.run(configuration)
    }
    
    
    // pauses the view
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      timeView.session.pause()
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
        
        oneButton.layer.cornerRadius = 5;
        twoButton.layer.cornerRadius = 5;
        threeButton.layer.cornerRadius = 5;
        settingsButton.layer.cornerRadius = 5;

        oneButton.layer.borderWidth = 10;
        twoButton.layer.borderWidth = 10;
        threeButton.layer.borderWidth = 10;
        settingsButton.layer.borderWidth = 10;
        
        timeView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        timeView.scene.background.contents = UIColor.black
        timeView.delegate = self

    }
    

    func collisionOne(){
        playSelectionSound()
        selectionTime = 1
        cursor.tintColor = cursorColor
    }
    func collisionTwo(){
        playSelectionSound()
        selectionTime = 2
        cursor.tintColor = cursorColor
    }
    func collisionThree(){
        playSelectionSound()
        selectionTime = 3
        cursor.tintColor = cursorColor
    }
    func collisionSettingsButton(){
        playSelectionSound()
            mainThread.async {
                self.performSegue(withIdentifier: "SettingsSegue", sender: self)
            }
    }
    
}

extension SelectionTime: ARSCNViewDelegate {
    
    //a scene renderer that returns a scene node given a face anchor, runs once
    
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = timeView.device else {
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
            
            if self.cursor.frame.intersects(self.oneButton.frame){
                
                self.oneButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.oneButton)
                }
                
                if self.hoveringOne && self.seconds <= 0 {
                    self.collisionOne();                    self.resetTimer()
                    
                }
                else if !self.hoveringOne{
                    self.resetTimer()
                }
                
                self.hoveringOne = true
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringSettings = false
                
                self.resetColor(button: self.oneButton)
                self.resetColor(button: self.twoButton)
                self.resetColor(button: self.settingsButton)

            }
            else if self.cursor.frame.intersects(self.twoButton.frame){
                self.twoButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.twoButton)
                }
                
                if self.hoveringTwo && self.seconds <= 0 {
                    self.collisionTwo()
                    self.resetTimer()
                    
                }
                else if !self.hoveringTwo{
                    self.resetTimer()
                }
                
                self.hoveringOne = false
                self.hoveringTwo = true
                self.hoveringThree = false
                self.hoveringSettings = false
                
                self.resetColor(button: self.oneButton)
                self.resetColor(button: self.threeButton)
                self.resetColor(button: self.settingsButton)
            }
            else if self.cursor.frame.intersects(self.threeButton.frame) {
                self.threeButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.threeButton)
                }
                
                if self.hoveringThree && self.seconds <= 0 {
                    self.collisionThree()
                    self.resetTimer()
                    
                }
                else if !self.hoveringThree{
                    self.resetTimer()
                }
                
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = true
                self.hoveringSettings = false
                
                self.resetColor(button: self.oneButton)
                self.resetColor(button: self.twoButton)
                self.resetColor(button: self.settingsButton)
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
                
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringSettings = true
                
                self.resetColor(button: self.oneButton)
                self.resetColor(button: self.twoButton)
                self.resetColor(button: self.threeButton)
            }
            else{
                self.oneButton.layer.borderColor = UIColor.clear.cgColor
                self.twoButton.layer.borderColor = UIColor.clear.cgColor
                self.threeButton.layer.borderColor = UIColor.clear.cgColor
                self.settingsButton.layer.borderColor = UIColor.clear.cgColor
                
                self.hoveringSettings = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.resetColor(button: self.settingsButton)
                self.resetColor(button: self.oneButton)
                self.resetColor(button: self.twoButton)
                self.resetColor(button: self.threeButton)
                
                self.resetTimer()
            }
        }
        
        
    }
    
}


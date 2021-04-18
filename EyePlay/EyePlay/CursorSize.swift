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
    let mainThread = DispatchQueue.main
    //sets the view up
    
    var seconds = selectionTime
    var timer = Timer()
    var isTimerRunning = false
    var hoveringSmall = false
    var hoveringMedium = false
    var hoveringLarge = false
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

    
    func runTimer(button: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(CursorSize.updateTimer)), userInfo: nil, repeats: true)
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
        playSelectionSound()
        //guard ARFaceTrackingConfiguration.isSupported else {
            //fatalError("Face tracking is not supported on this device")
        //}

        cursor.frame.size = CGSize(width: cursorSize.width, height: cursorSize.height);
        cursor.tintColor = cursorColor;
        cursor.layer.zPosition = 1;
        smallButton.layer.cornerRadius = 5;
        mediumButton.layer.cornerRadius = 5;
        largeButton.layer.cornerRadius = 5;
        settingsButton.layer.cornerRadius = 5;

        smallButton.layer.borderWidth = 10;
        mediumButton.layer.borderWidth = 10;
        largeButton.layer.borderWidth = 10;
        settingsButton.layer.borderWidth = 10;
        
        cursorSizeView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        cursorSizeView.scene.background.contents = UIColor.black
        cursorSizeView.delegate = self

    }
    

    func collisionSmallButton(){
        playSelectionSound()
        cursor.frame.size = CGSize(width: 50.0, height: 50.0);
        cursorSize.width = 50.0;
        cursorSize.height = 50.0;
    }
    func collisionMediumButton(){
        playSelectionSound()
        cursor.frame.size = CGSize(width: 100.0, height: 100.0);
        cursorSize.width = 100.0;
        cursorSize.height = 100.0;
    }
    func collisionLargeButton(){
        playSelectionSound()
        cursor.frame.size = CGSize(width: 150.0, height: 150.0);
        cursorSize.width = 150.0;
        cursorSize.height = 150.0;
    }
    func collisionSettingsButton(){
            mainThread.async {
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
            
        mainThread.async {

            
            if self.cursor.frame.intersects(self.smallButton.frame){
                
                self.smallButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.smallButton)
                }
                
                if self.hoveringSmall && self.seconds <= 0 {
                    self.collisionSmallButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringSmall{
                    self.resetTimer()
                }
                
                self.hoveringSmall = true
                self.hoveringMedium = false
                self.hoveringLarge = false
                self.hoveringSettings = false
                
                self.resetColor(button: self.mediumButton)
                self.resetColor(button: self.largeButton)
                self.resetColor(button: self.settingsButton)

            }
            else if self.cursor.frame.intersects(self.mediumButton.frame){

                self.mediumButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.mediumButton)
                }
                
                if self.hoveringMedium && self.seconds <= 0 {
                    self.collisionMediumButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringMedium{
                    self.resetTimer()
                }
                
                self.hoveringSmall = false
                self.hoveringMedium = true
                self.hoveringLarge = false
                self.hoveringSettings = false
                
                self.resetColor(button: self.smallButton)
                self.resetColor(button: self.largeButton)
                self.resetColor(button: self.settingsButton)
            }
            else if self.cursor.frame.intersects(self.largeButton.frame){
                self.largeButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.largeButton)
                }
                
                if self.hoveringLarge && self.seconds <= 0 {
                    self.collisionLargeButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringLarge{
                    self.resetTimer()
                }
                
                self.hoveringSmall = false
                self.hoveringMedium = false
                self.hoveringLarge = true
                self.hoveringSettings = false
                
                self.resetColor(button: self.mediumButton)
                self.resetColor(button: self.smallButton)
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
                
                self.hoveringSmall = false
                self.hoveringMedium = false
                self.hoveringLarge = false
                self.hoveringSettings = true
                
                self.resetColor(button: self.smallButton)
                self.resetColor(button: self.mediumButton)
                self.resetColor(button: self.largeButton)
            }
            else{
                self.smallButton.layer.borderColor = UIColor.clear.cgColor
                self.mediumButton.layer.borderColor = UIColor.clear.cgColor
                self.largeButton.layer.borderColor = UIColor.clear.cgColor
                self.settingsButton.layer.borderColor = UIColor.clear.cgColor
                
                self.hoveringSettings = false
                self.hoveringSmall = false
                self.hoveringMedium = false
                self.hoveringLarge = false
                self.resetColor(button: self.smallButton)
                self.resetColor(button: self.settingsButton)
                self.resetColor(button: self.mediumButton)
                self.resetColor(button: self.largeButton)
                
                self.resetTimer()
            }
        }
        
    }
    
}

import UIKit
import ARKit
import VisionKit



class MiniGames: UIViewController, ARSessionDelegate{

    @IBOutlet var miniGameView: ARSCNView!
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var TicTacToeButton: UIButton!
    @IBOutlet weak var mainMenuButton: UIButton!
    @IBOutlet weak var ballGameButton: UIButton!
    @IBOutlet weak var bugGameButton: UIButton!
    
    let sceneNodes = nodes()
    
    let mainThread = DispatchQueue.main
    
    var seconds = 2
    var timer = Timer()
    var isTimerRunning = false
    var hoveringMenu = false
    var hoveringBallGame = false
    var hoveringTicTacToe = false
    var hoveringBugGame = false

    
    func runTimer(button: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(MiniGames.updateTimer)), userInfo: nil, repeats: true)
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
        TicTacToeButton.layer.cornerRadius = 5;
        mainMenuButton.layer.cornerRadius = 5;
        ballGameButton.layer.cornerRadius = 5;
        bugGameButton.layer.cornerRadius = 5;
        
        TicTacToeButton.layer.borderWidth = 10;
        mainMenuButton.layer.borderWidth = 10;
        ballGameButton.layer.borderWidth = 10;
        bugGameButton.layer.borderWidth = 10;
        
        miniGameView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        miniGameView.scene.background.contents = UIColor.black
        miniGameView.delegate = self

    }
    

    func collisionMenuButton(){

            mainThread.async {
                self.performSegue(withIdentifier: "MainMenuSegue", sender: self)
            }
    }
    func collisionBallGameButton(){

            mainThread.async {
                self.performSegue(withIdentifier: "BallGameSegue", sender: self)
            }
    }
    func collisionTicTacToeButton(){

            mainThread.async {
                self.performSegue(withIdentifier: "TicTacToeSegue", sender: self)
            }
    }
    func collisionBugGameButton(){

            mainThread.async {
                self.performSegue(withIdentifier: "BugGameSegue", sender: self)
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
        
        mainThread.async {
            if self.cursor.frame.intersects(self.mainMenuButton.frame){
                self.mainMenuButton.layer.borderColor = UIColor.systemBlue.cgColor
                if !self.isTimerRunning{
                    self.runTimer(button: self.mainMenuButton)
                }
                
                if self.hoveringMenu && self.seconds <= 0 {
                    self.collisionMenuButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringMenu{
                    self.resetTimer()
                }
                
                self.hoveringMenu = true
                self.hoveringBallGame = false
                self.hoveringTicTacToe = false
                self.hoveringBugGame = false
                
                self.resetColor(button: self.ballGameButton)
                self.resetColor(button: self.TicTacToeButton)
                self.resetColor(button: self.bugGameButton)

            }
            else if self.cursor.frame.intersects(self.TicTacToeButton.frame){
                self.TicTacToeButton.layer.borderColor = UIColor.systemBlue.cgColor
                if !self.isTimerRunning{
                    self.runTimer(button: self.TicTacToeButton)
                }
                
                if self.hoveringTicTacToe && self.seconds <= 0 {
                    self.collisionTicTacToeButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringTicTacToe{
                    self.resetTimer()
                }
                
                self.hoveringBugGame = false
                self.hoveringMenu = false
                self.hoveringBallGame = false
                self.hoveringTicTacToe = true
                
                self.resetColor(button: self.ballGameButton)
                self.resetColor(button: self.mainMenuButton)
                self.resetColor(button: self.bugGameButton)

            }
            else if self.cursor.frame.intersects(self.ballGameButton.frame){
                self.ballGameButton.layer.borderColor = UIColor.systemBlue.cgColor
                if !self.isTimerRunning{
                    self.runTimer(button: self.ballGameButton)
                }
                
                if self.hoveringBallGame && self.seconds <= 0 {
                    self.collisionBallGameButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringBallGame{
                    self.resetTimer()
                }
                
                self.hoveringBugGame = false
                self.hoveringMenu = false
                self.hoveringBallGame = true
                self.hoveringTicTacToe = false
                
                self.resetColor(button: self.mainMenuButton)
                self.resetColor(button: self.TicTacToeButton)
                self.resetColor(button: self.bugGameButton)

            }
            else if self.cursor.frame.intersects(self.bugGameButton.frame){
                self.bugGameButton.layer.borderColor = UIColor.systemBlue.cgColor
                if !self.isTimerRunning{
                    self.runTimer(button: self.bugGameButton)
                }
                
                if self.hoveringBugGame && self.seconds <= 0 {
                    self.collisionBugGameButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringBugGame{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringBugGame = true
                self.hoveringTicTacToe = false
                self.hoveringBallGame = false
                
                
                self.resetColor(button: self.mainMenuButton)
                self.resetColor(button: self.TicTacToeButton)
                self.resetColor(button: self.ballGameButton)
            }
            else{
                self.mainMenuButton.layer.borderColor = UIColor.clear.cgColor
                self.TicTacToeButton.layer.borderColor = UIColor.clear.cgColor
                self.ballGameButton.layer.borderColor = UIColor.clear.cgColor
                self.bugGameButton.layer.borderColor = UIColor.clear.cgColor
                
                self.hoveringTicTacToe = false
                self.hoveringBallGame = false
                self.hoveringMenu = false
                self.hoveringBugGame = false

                self.resetColor(button: self.TicTacToeButton)
                self.resetColor(button: self.mainMenuButton)
                self.resetColor(button: self.ballGameButton)
                self.resetColor(button: self.bugGameButton)
                
                self.resetTimer()

            }
        }
        
    }
    
}

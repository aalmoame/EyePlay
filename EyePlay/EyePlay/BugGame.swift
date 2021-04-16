import UIKit
import ARKit


class BugGame: UIViewController{
    
    @IBOutlet var bugGameView: ARSCNView!
    
    
    
    @IBOutlet weak var miniGamesButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var roach: UIImageView!
    @IBOutlet weak var scoreValue: UILabel!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var ladybug: UIImageView!
    

    
    let sceneNodes = nodes()
    let mainThread = DispatchQueue.main
    
    var timerRoach = Timer()
    var roach_seconds = Int.random(in: 2...5)
    var isTimerRunningRoach = false
    var time_over = true
        
    var seconds = 2
    var timer = Timer()
    var isTimerRunning = false
    
    var hoveringMenu = false
    var hoveringMiniGames = false
    
    var presentedPopup = false
    
    var isRoach = true
    
    @IBOutlet var tapRoach: UITapGestureRecognizer!
    @IBAction func tappedRoach(_ sender: Any) {
        if time_over{
            
            collisionRoach()
        }
    }
    
    
    var player: AVAudioPlayer?

    func playSquashSound() {
                
        let path = Bundle.main.path(forResource: "bug_splat.wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
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
    
    func runTimerRoach() {
        time_over = false
        timerRoach = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(BugGame.updateTimerRoach)), userInfo: nil, repeats: true)
        isTimerRunningRoach = true

    }
    func resetTimerRoach(){
        timerRoach.invalidate()
        isTimerRunningRoach = false
        roach_seconds = Int.random(in: 2...5)
    }
    @objc func updateTimerRoach() {
        roach_seconds -= 1
        if roach_seconds == 0{
            let rand_tf = [0,1]
            let roach_lady = rand_tf.randomElement()
            if (roach_lady == 0){
                isRoach = true
                spawnRoach()
            }
            else{
                isRoach = false
                spawnLadyBug()
            }
            time_over = true
        }
    }

    
    func runTimer(button: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(BugGame.updateTimer)), userInfo: nil, repeats: true)
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
            
      bugGameView.session.run(configuration)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
            
      bugGameView.session.pause()
    }
    
    override func viewDidLoad() {
        //guard ARFaceTrackingConfiguration.isSupported else {
            //fatalError("Face tracking is not supported on this device")
        //}
        playSelectionSound()

        cursor.layer.zPosition = 1
        menuButton.layer.cornerRadius = 5;
        menuButton.layer.borderWidth = 10.0;
        miniGamesButton.layer.cornerRadius = 5;
        miniGamesButton.layer.borderWidth = 10.0;
        
        bugGameView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen);
        bugGameView.scene.background.contents = UIColor.black;
        bugGameView.delegate = self;

    }
        
    func collisionRoach(){
        
        playSquashSound()
            
        roach.isHidden = true
        
        resetTimerRoach()
        
        let val = Int(scoreValue.text!)
        
        scoreValue.text = String(val! + 1)
        
        let dead_roach = UIImage(named: "cockroach_dead.png")
                
        let myImageView:UIImageView = UIImageView()
        myImageView.contentMode = UIView.ContentMode.scaleAspectFit
        myImageView.frame.size.width = roach.frame.size.width
        myImageView.frame.size.height = roach.frame.size.height
        myImageView.center = roach.center
        
        myImageView.image = dead_roach
        
        view.addSubview(myImageView)
 
        self.view = view
        
        UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
            myImageView.alpha = 0.0
        }, completion: nil)
        
        runTimerRoach()
        
    }
    
    func collisionLadyBug(){
        
        playSquashSound()
            
        ladybug.isHidden = true
        
        resetTimerRoach()
        
        let val = Int(scoreValue.text!)
        
        scoreValue.text = String(val! - 1)
        
        runTimerRoach()
        
    }
    
    func roachOffScreen(){
        
            
        roach.isHidden = true
        
        resetTimerRoach()
        
        runTimerRoach()
        
    }
    
    func ladybugOffScreen(){
        
            
        ladybug.isHidden = true
        
        resetTimerRoach()
        
        runTimerRoach()
        
    }
    
    func spawnRoach(){
        
        let xwidth = roach.superview!.bounds.width - roach.frame.width
        let yheight = roach.superview!.bounds.height - roach.frame.height

        let xoffset = CGFloat(arc4random_uniform(UInt32(xwidth)))
        let yoffset = CGFloat(arc4random_uniform(UInt32(yheight)))
        
        mainThread.async {
            self.roach.frame.origin.x = xoffset;
            self.roach.frame.origin.y = yoffset;
            
        }
        
        roach.isHidden = false
                
    }
    
    func spawnLadyBug(){
        
        let xwidth = ladybug.superview!.bounds.width - roach.frame.width
        let yheight = ladybug.superview!.bounds.height - roach.frame.height

        let xoffset = CGFloat(arc4random_uniform(UInt32(xwidth)))
        let yoffset = CGFloat(arc4random_uniform(UInt32(yheight)))
        
        mainThread.async {
            self.ladybug.frame.origin.x = xoffset;
            self.ladybug.frame.origin.y = yoffset;
            
        }
        
        ladybug.isHidden = false
                
    }
        
    func collisionMenuButton(){
        playSelectionSound()
        mainThread.async {
            self.performSegue(withIdentifier: "MainScreenSegue", sender: self)
        
        }
    }
    func collisionMiniGames(){
        playSelectionSound()
        mainThread.async {
            self.performSegue(withIdentifier: "MiniGamesSegue", sender: self)
        
        }
    }
    
    
}

// 1
extension BugGame: ARSCNViewDelegate {
  // 2
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        // 3
        guard let device = bugGameView.device else {
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
            
            if !self.presentedPopup{
                var image = UIImage(systemName: "ladybug")
                image = image?.withTintColor(UIColor.black)
                
                JSSAlertView().show(
                    self,
                      title: "Tip",
                      text: "Don't Hurt the Lady Bugs",
                      buttonText: "OK",
                    color: UIColor.white,
                    iconImage: image,
                    delay: 4.0
                )
                
                self.presentedPopup = true
            }

            
            if (self.roach.center.y <= -200 || self.roach.center.x <= -200) && self.time_over && self.isRoach{
                self.roachOffScreen()
            }
            if (self.ladybug.center.y <= -200 || self.ladybug.center.x <= -200) && self.time_over && !self.isRoach{
                self.ladybugOffScreen()
            }
            
            if !self.roach.isHidden{
                let posNeg = [-5, -5, -5, -5, -5, -5, 5, 5, 5, -10, -10, -10, -10, -10, -10, 10, 10, 10]
                UIView.animate(withDuration: 0.2){
                    
                    self.roach.center.x += CGFloat(posNeg.randomElement()!)
                    self.roach.center.y += CGFloat(posNeg.randomElement()!)
                    
                }
                
            }
            
            if !self.ladybug.isHidden{
                let posNeg = [-5, -5, -5, -5, -5, -5, 5, 5, 5, -10, -10, -10, -10, -10, -10, 10, 10, 10]
                UIView.animate(withDuration: 0.2){
                    
                    self.ladybug.center.x += CGFloat(posNeg.randomElement()!)
                    self.ladybug.center.y += CGFloat(posNeg.randomElement()!)
                    
                }
                
            }
            
            if self.cursor.frame.intersects(self.roach.frame) && self.time_over && self.isRoach{
                self.collisionRoach()

            }
            else if self.cursor.frame.intersects(self.ladybug.frame) && self.time_over && !self.isRoach{
                self.collisionLadyBug()

            }
            
            else if self.cursor.frame.intersects(self.menuButton.frame){
                
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
                self.hoveringMiniGames = false
                
                self.resetColor(button: self.miniGamesButton)
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                
            }
            else if self.cursor.frame.intersects(self.miniGamesButton.frame){
                
                self.miniGamesButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.miniGamesButton)
                }
                
                if self.hoveringMiniGames && self.seconds <= 0 {
                    self.collisionMiniGames()
                    self.resetTimer()
                    
                }
                else if !self.hoveringMiniGames{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringMiniGames = true
                
                self.resetColor(button: self.menuButton)
                self.menuButton.layer.borderColor = UIColor.clear.cgColor

            }
            else{
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                
                self.hoveringMenu = false
                self.hoveringMiniGames = false

                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.miniGamesButton)
                
                self.resetTimer()

            }
        }
        
    }
    
}

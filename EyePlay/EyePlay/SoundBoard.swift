import UIKit
import ARKit
import VisionKit



//main view class
class SoundBoard: UIViewController{

    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var miniGamesButton: UIButton!
    @IBOutlet weak var fartButton: UIButton!
    @IBOutlet weak var moneyButton: UIButton!
    @IBOutlet weak var woofButton: UIButton!
    @IBOutlet weak var meowButton: UIButton!
    @IBOutlet weak var policeButton: UIButton!
    @IBOutlet weak var fairyButton: UIButton!
    @IBOutlet weak var punchButton: UIButton!
    @IBOutlet weak var raceCarButton: UIButton!
    @IBOutlet var soundBoardView: ARSCNView!
    @IBOutlet weak var cursor: UIImageView!
    

    let sceneNodes = nodes()
    let mainThread = DispatchQueue.main
    
    var seconds = selectionTime
    var timer = Timer()
    var isTimerRunning = false
    var hoveringMenu = false
    var hoveringMiniGames = false
    var hoveringFart = false
    var hoveringMoney = false
    var hoveringWoof = false
    var hoveringMeow = false
    var hoveringPolice = false
    var hoveringFairy = false
    var hoveringPunch = false
    var hoveringRaceCars = false
    
    var player: AVAudioPlayer?
    
    func playSound(sound: String) {
                
        let path = Bundle.main.path(forResource: sound, ofType:nil)!
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

    @IBAction func fartTapped(_ sender: Any) {
        collisionFart()
    }
    @IBAction func moneyTapped(_ sender: Any) {
        collisionMoney()
    }
    @IBAction func woofTapped(_ sender: Any) {
        collisionWoof()
    }
    @IBAction func meowTapped(_ sender: Any) {
        collisionMeow()
    }
    @IBAction func policeTapped(_ sender: Any) {
        collisionPolice()
    }
    @IBAction func fairyTapped(_ sender: Any) {
        collisionFairy()
    }
    @IBAction func punchTapped(_ sender: Any) {
        collisionPunch()
    }
    @IBAction func raceCarTapped(_ sender: Any) {
        collisionRaceCars()
    }
    

    func runTimer(button: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(SoundBoard.updateTimer)), userInfo: nil, repeats: true)
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
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      let configuration = ARFaceTrackingConfiguration()
      soundBoardView.session.run(configuration)
    }
    
    
    // pauses the view
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      soundBoardView.session.pause()
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
        
        menuButton.layer.cornerRadius = 5;
        miniGamesButton.layer.cornerRadius = 5;
        fartButton.layer.cornerRadius = 5;
        moneyButton.layer.cornerRadius = 5;
        woofButton.layer.cornerRadius = 5;
        meowButton.layer.cornerRadius = 5;
        policeButton.layer.cornerRadius = 5;
        fairyButton.layer.cornerRadius = 5;
        punchButton.layer.cornerRadius = 5;
        raceCarButton.layer.cornerRadius = 5;
        

        menuButton.layer.borderWidth = 10;
        miniGamesButton.layer.borderWidth = 10;
        fartButton.layer.borderWidth = 10;
        moneyButton.layer.borderWidth = 10;
        woofButton.layer.borderWidth = 10;
        meowButton.layer.borderWidth = 10;
        policeButton.layer.borderWidth = 10;
        fairyButton.layer.borderWidth = 10;
        punchButton.layer.borderWidth = 10;
        raceCarButton.layer.borderWidth = 10;
        
        soundBoardView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        soundBoardView.scene.background.contents = UIColor.black
        soundBoardView.delegate = self

    }
    

    func collisionMenu(){
        playSound(sound: "select.mp3")
        mainThread.async {
            self.performSegue(withIdentifier: "MainScreenSegue", sender: self)
        
        }
    }
    func collisionMiniGames(){
        playSound(sound: "select.mp3")
        mainThread.async {
            self.performSegue(withIdentifier: "MiniGameSegue", sender: self)
        
        }

    }
    func collisionFart(){
        let farts = ["fart1.mp3", "fart2.mp3", "fart3.mp3", "fart4.mp3"]
        playSound(sound: farts.randomElement()!)
    }
    func collisionMoney(){
        playSound(sound: "money.mp3")

    }
    func collisionWoof(){
        let dogs = ["woof.mp3", "woof1.mp3", "woof2.mp3"]
        playSound(sound: dogs.randomElement()!)
    }
    func collisionMeow(){
        //playSound(sound: "police.mp3")
        let cats = ["meow1.mp3", "meow2.mp3"]
        playSound(sound: cats.randomElement()!)
    }
    func collisionPolice(){
        playSound(sound: "police.mp3")
    }
    func collisionFairy(){
        playSound(sound: "fairy.mp3")
    }
    func collisionPunch(){
        let punch = ["punch.mp3", "punch2.mp3"]
        playSound(sound: punch.randomElement()!)
    }
    func collisionRaceCars(){
        let racecars = ["racecar.mp3", "racecar2.mp3"]
        playSound(sound: racecars.randomElement()!)
    }
    
}

extension SoundBoard: ARSCNViewDelegate {
    
    //a scene renderer that returns a scene node given a face anchor, runs once
    
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = soundBoardView.device else {
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
            
            if self.cursor.frame.intersects(self.menuButton.frame){
                
                self.menuButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.menuButton)
                }
                
                if self.hoveringMenu && self.seconds <= 0 {
                    self.collisionMenu()
                    self.resetTimer()
                    
                }
                else if !self.hoveringMenu{
                    self.resetTimer()
                }
                
                self.hoveringMenu = true
                self.hoveringMiniGames = false
                self.hoveringFart = false
                self.hoveringMoney = false
                self.hoveringWoof = false
                self.hoveringMeow = false
                self.hoveringPolice = false
                self.hoveringFairy = false
                self.hoveringPunch = false
                self.hoveringRaceCars = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.fartButton)
                self.resetColor(button: self.moneyButton)
                self.resetColor(button: self.woofButton)
                self.resetColor(button: self.meowButton)
                self.resetColor(button: self.policeButton)
                self.resetColor(button: self.fairyButton)
                self.resetColor(button: self.punchButton)
                self.resetColor(button: self.raceCarButton)
                
                
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                self.fartButton.layer.borderColor = UIColor.clear.cgColor
                self.moneyButton.layer.borderColor = UIColor.clear.cgColor
                self.woofButton.layer.borderColor = UIColor.clear.cgColor
                self.meowButton.layer.borderColor = UIColor.clear.cgColor
                self.policeButton.layer.borderColor = UIColor.clear.cgColor
                self.fairyButton.layer.borderColor = UIColor.clear.cgColor
                self.punchButton.layer.borderColor = UIColor.clear.cgColor
                self.raceCarButton.layer.borderColor = UIColor.clear.cgColor

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
                self.hoveringFart = false
                self.hoveringMoney = false
                self.hoveringWoof = false
                self.hoveringMeow = false
                self.hoveringPolice = false
                self.hoveringFairy = false
                self.hoveringPunch = false
                self.hoveringRaceCars = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.fartButton)
                self.resetColor(button: self.moneyButton)
                self.resetColor(button: self.woofButton)
                self.resetColor(button: self.meowButton)
                self.resetColor(button: self.policeButton)
                self.resetColor(button: self.fairyButton)
                self.resetColor(button: self.punchButton)
                self.resetColor(button: self.raceCarButton)
                
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.fartButton.layer.borderColor = UIColor.clear.cgColor
                self.moneyButton.layer.borderColor = UIColor.clear.cgColor
                self.woofButton.layer.borderColor = UIColor.clear.cgColor
                self.meowButton.layer.borderColor = UIColor.clear.cgColor
                self.policeButton.layer.borderColor = UIColor.clear.cgColor
                self.fairyButton.layer.borderColor = UIColor.clear.cgColor
                self.punchButton.layer.borderColor = UIColor.clear.cgColor
                self.raceCarButton.layer.borderColor = UIColor.clear.cgColor
            }
            else if self.cursor.frame.intersects(self.fartButton.frame) {
                self.fartButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.fartButton)
                }
                
                if self.hoveringFart && self.seconds <= 0 {
                    self.collisionFart()
                    self.resetTimer()
                    
                }
                else if !self.hoveringFart{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringMiniGames = false
                self.hoveringFart = true
                self.hoveringMoney = false
                self.hoveringWoof = false
                self.hoveringMeow = false
                self.hoveringPolice = false
                self.hoveringFairy = false
                self.hoveringPunch = false
                self.hoveringRaceCars = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.moneyButton)
                self.resetColor(button: self.woofButton)
                self.resetColor(button: self.meowButton)
                self.resetColor(button: self.policeButton)
                self.resetColor(button: self.fairyButton)
                self.resetColor(button: self.punchButton)
                self.resetColor(button: self.raceCarButton)
                
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                self.moneyButton.layer.borderColor = UIColor.clear.cgColor
                self.woofButton.layer.borderColor = UIColor.clear.cgColor
                self.meowButton.layer.borderColor = UIColor.clear.cgColor
                self.policeButton.layer.borderColor = UIColor.clear.cgColor
                self.fairyButton.layer.borderColor = UIColor.clear.cgColor
                self.punchButton.layer.borderColor = UIColor.clear.cgColor
                self.raceCarButton.layer.borderColor = UIColor.clear.cgColor
            }
            else if self.cursor.frame.intersects(self.moneyButton.frame){
                self.moneyButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.moneyButton)
                }
                
                if self.hoveringMoney && self.seconds <= 0 {
                    self.collisionMoney()
                    self.resetTimer()
                    
                }
                else if !self.hoveringMoney{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringMiniGames = false
                self.hoveringFart = false
                self.hoveringMoney = true
                self.hoveringWoof = false
                self.hoveringMeow = false
                self.hoveringPolice = false
                self.hoveringFairy = false
                self.hoveringPunch = false
                self.hoveringRaceCars = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.fartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.woofButton)
                self.resetColor(button: self.meowButton)
                self.resetColor(button: self.policeButton)
                self.resetColor(button: self.fairyButton)
                self.resetColor(button: self.punchButton)
                self.resetColor(button: self.raceCarButton)
                
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                self.fartButton.layer.borderColor = UIColor.clear.cgColor
                self.woofButton.layer.borderColor = UIColor.clear.cgColor
                self.meowButton.layer.borderColor = UIColor.clear.cgColor
                self.policeButton.layer.borderColor = UIColor.clear.cgColor
                self.fairyButton.layer.borderColor = UIColor.clear.cgColor
                self.punchButton.layer.borderColor = UIColor.clear.cgColor
                self.raceCarButton.layer.borderColor = UIColor.clear.cgColor
            }
            else if self.cursor.frame.intersects(self.woofButton.frame){
                self.woofButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.woofButton)
                }
                
                if self.hoveringWoof && self.seconds <= 0 {
                    self.collisionWoof()
                    self.resetTimer()
                    
                }
                else if !self.hoveringWoof{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringMiniGames = false
                self.hoveringFart = false
                self.hoveringMoney = false
                self.hoveringWoof = true
                self.hoveringMeow = false
                self.hoveringPolice = false
                self.hoveringFairy = false
                self.hoveringPunch = false
                self.hoveringRaceCars = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.fartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.moneyButton)
                self.resetColor(button: self.meowButton)
                self.resetColor(button: self.policeButton)
                self.resetColor(button: self.fairyButton)
                self.resetColor(button: self.punchButton)
                self.resetColor(button: self.raceCarButton)
                
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                self.fartButton.layer.borderColor = UIColor.clear.cgColor
                self.moneyButton.layer.borderColor = UIColor.clear.cgColor
                self.meowButton.layer.borderColor = UIColor.clear.cgColor
                self.policeButton.layer.borderColor = UIColor.clear.cgColor
                self.fairyButton.layer.borderColor = UIColor.clear.cgColor
                self.punchButton.layer.borderColor = UIColor.clear.cgColor
                self.raceCarButton.layer.borderColor = UIColor.clear.cgColor
            }
            else if self.cursor.frame.intersects(self.meowButton.frame){
                self.meowButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.meowButton)
                }
                
                if self.hoveringMeow && self.seconds <= 0 {
                    self.collisionMeow()
                    self.resetTimer()
                    
                }
                else if !self.hoveringMeow{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringMiniGames = false
                self.hoveringFart = false
                self.hoveringMoney = false
                self.hoveringWoof = false
                self.hoveringMeow = true
                self.hoveringPolice = false
                self.hoveringFairy = false
                self.hoveringPunch = false
                self.hoveringRaceCars = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.fartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.woofButton)
                self.resetColor(button: self.moneyButton)
                self.resetColor(button: self.policeButton)
                self.resetColor(button: self.fairyButton)
                self.resetColor(button: self.punchButton)
                self.resetColor(button: self.raceCarButton)
                
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                self.fartButton.layer.borderColor = UIColor.clear.cgColor
                self.moneyButton.layer.borderColor = UIColor.clear.cgColor
                self.woofButton.layer.borderColor = UIColor.clear.cgColor
                self.policeButton.layer.borderColor = UIColor.clear.cgColor
                self.fairyButton.layer.borderColor = UIColor.clear.cgColor
                self.punchButton.layer.borderColor = UIColor.clear.cgColor
                self.raceCarButton.layer.borderColor = UIColor.clear.cgColor
            }
            else if self.cursor.frame.intersects(self.policeButton.frame){
                self.policeButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.policeButton)
                }
                
                if self.hoveringPolice && self.seconds <= 0 {
                    self.collisionPolice()
                    self.resetTimer()
                    
                }
                else if !self.hoveringPolice{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringMiniGames = false
                self.hoveringFart = false
                self.hoveringMoney = false
                self.hoveringWoof = false
                self.hoveringMeow = false
                self.hoveringPolice = true
                self.hoveringFairy = false
                self.hoveringPunch = false
                self.hoveringRaceCars = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.fartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.woofButton)
                self.resetColor(button: self.meowButton)
                self.resetColor(button: self.moneyButton)
                self.resetColor(button: self.fairyButton)
                self.resetColor(button: self.punchButton)
                self.resetColor(button: self.raceCarButton)
                
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                self.fartButton.layer.borderColor = UIColor.clear.cgColor
                self.moneyButton.layer.borderColor = UIColor.clear.cgColor
                self.woofButton.layer.borderColor = UIColor.clear.cgColor
                self.meowButton.layer.borderColor = UIColor.clear.cgColor
                self.fairyButton.layer.borderColor = UIColor.clear.cgColor
                self.punchButton.layer.borderColor = UIColor.clear.cgColor
                self.raceCarButton.layer.borderColor = UIColor.clear.cgColor
            }
            else if self.cursor.frame.intersects(self.fairyButton.frame){
                self.fairyButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.fairyButton)
                }
                
                if self.hoveringFairy && self.seconds <= 0 {
                    self.collisionFairy()
                    self.resetTimer()
                    
                }
                else if !self.hoveringFairy{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringMiniGames = false
                self.hoveringFart = false
                self.hoveringMoney = false
                self.hoveringWoof = false
                self.hoveringMeow = false
                self.hoveringPolice = false
                self.hoveringFairy = true
                self.hoveringPunch = false
                self.hoveringRaceCars = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.fartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.woofButton)
                self.resetColor(button: self.meowButton)
                self.resetColor(button: self.policeButton)
                self.resetColor(button: self.moneyButton)
                self.resetColor(button: self.punchButton)
                self.resetColor(button: self.raceCarButton)
                
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                self.fartButton.layer.borderColor = UIColor.clear.cgColor
                self.moneyButton.layer.borderColor = UIColor.clear.cgColor
                self.woofButton.layer.borderColor = UIColor.clear.cgColor
                self.meowButton.layer.borderColor = UIColor.clear.cgColor
                self.policeButton.layer.borderColor = UIColor.clear.cgColor
                self.punchButton.layer.borderColor = UIColor.clear.cgColor
                self.raceCarButton.layer.borderColor = UIColor.clear.cgColor
            }
            else if self.cursor.frame.intersects(self.punchButton.frame){
                self.punchButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.punchButton)
                }
                
                if self.hoveringPunch && self.seconds <= 0 {
                    self.collisionPunch()
                    self.resetTimer()
                    
                }
                else if !self.hoveringPunch{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringMiniGames = false
                self.hoveringFart = false
                self.hoveringMoney = false
                self.hoveringWoof = false
                self.hoveringMeow = false
                self.hoveringPolice = false
                self.hoveringFairy = false
                self.hoveringPunch = true
                self.hoveringRaceCars = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.fartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.woofButton)
                self.resetColor(button: self.meowButton)
                self.resetColor(button: self.policeButton)
                self.resetColor(button: self.fairyButton)
                self.resetColor(button: self.moneyButton)
                self.resetColor(button: self.raceCarButton)
                
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                self.fartButton.layer.borderColor = UIColor.clear.cgColor
                self.moneyButton.layer.borderColor = UIColor.clear.cgColor
                self.woofButton.layer.borderColor = UIColor.clear.cgColor
                self.meowButton.layer.borderColor = UIColor.clear.cgColor
                self.policeButton.layer.borderColor = UIColor.clear.cgColor
                self.fairyButton.layer.borderColor = UIColor.clear.cgColor
                self.raceCarButton.layer.borderColor = UIColor.clear.cgColor
            }
            else if self.cursor.frame.intersects(self.raceCarButton.frame){
                self.raceCarButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.raceCarButton)
                }
                
                if self.hoveringRaceCars && self.seconds <= 0 {
                    self.collisionRaceCars()
                    self.resetTimer()
                    
                }
                else if !self.hoveringRaceCars{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringMiniGames = false
                self.hoveringFart = false
                self.hoveringMoney = false
                self.hoveringWoof = false
                self.hoveringMeow = false
                self.hoveringPolice = false
                self.hoveringFairy = false
                self.hoveringPunch = false
                self.hoveringRaceCars = true
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.fartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.woofButton)
                self.resetColor(button: self.meowButton)
                self.resetColor(button: self.policeButton)
                self.resetColor(button: self.fairyButton)
                self.resetColor(button: self.punchButton)
                self.resetColor(button: self.moneyButton)
                
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                self.fartButton.layer.borderColor = UIColor.clear.cgColor
                self.moneyButton.layer.borderColor = UIColor.clear.cgColor
                self.woofButton.layer.borderColor = UIColor.clear.cgColor
                self.meowButton.layer.borderColor = UIColor.clear.cgColor
                self.policeButton.layer.borderColor = UIColor.clear.cgColor
                self.fairyButton.layer.borderColor = UIColor.clear.cgColor
                self.punchButton.layer.borderColor = UIColor.clear.cgColor
            }
            else{
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                self.fartButton.layer.borderColor = UIColor.clear.cgColor
                self.moneyButton.layer.borderColor = UIColor.clear.cgColor
                self.woofButton.layer.borderColor = UIColor.clear.cgColor
                self.meowButton.layer.borderColor = UIColor.clear.cgColor
                self.policeButton.layer.borderColor = UIColor.clear.cgColor
                self.fairyButton.layer.borderColor = UIColor.clear.cgColor
                self.punchButton.layer.borderColor = UIColor.clear.cgColor
                self.raceCarButton.layer.borderColor = UIColor.clear.cgColor
                
                self.hoveringMenu = false
                self.hoveringMiniGames = false
                self.hoveringFart = false
                self.hoveringMoney = false
                self.hoveringWoof = false
                self.hoveringMeow = false
                self.hoveringPolice = false
                self.hoveringFairy = false
                self.hoveringPunch = false
                self.hoveringRaceCars = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.fartButton)
                self.resetColor(button: self.moneyButton)
                self.resetColor(button: self.woofButton)
                self.resetColor(button: self.meowButton)
                self.resetColor(button: self.policeButton)
                self.resetColor(button: self.fairyButton)
                self.resetColor(button: self.punchButton)
                self.resetColor(button: self.raceCarButton)
                
                self.resetTimer()
            }
        }
        
        
    }
    
}


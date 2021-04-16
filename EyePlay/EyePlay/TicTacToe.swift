import UIKit
import ARKit
import VisionKit


struct player{
    var board = [[0,0,0],[0,0,0],[0,0,0]]
}


func checkWin(player: player) -> Bool {
    let playerBoard = player.board
    
    if (playerBoard[0][0] == 1) && (playerBoard[0][1] == 1) && (playerBoard[0][2] == 1){
        return true
    }
    else if (playerBoard[1][0] == 1) && (playerBoard[1][1] == 1) && (playerBoard[1][2] == 1){
        return true
    }
    else if (playerBoard[2][0] == 1) && (playerBoard[2][1] == 1) && (playerBoard[2][2] == 1){
        return true
    }
    else if (playerBoard[0][0] == 1) && (playerBoard[1][0] == 1) && (playerBoard[2][0] == 1){
        return true
    }
    else if (playerBoard[0][1] == 1) && (playerBoard[1][1] == 1) && (playerBoard[2][1] == 1){
        return true
    }
    else if (playerBoard[0][2] == 1) && (playerBoard[1][2] == 1) && (playerBoard[2][2] == 1){
        return true
    }
    else if (playerBoard[0][0] == 1) && (playerBoard[1][1] == 1) && (playerBoard[2][2] == 1){
        return true
    }
    else if (playerBoard[0][2] == 1) && (playerBoard[1][1] == 1) && (playerBoard[2][0] == 1){
        return true
    }
    
    return false
}

func checkTie(player1: player, player2: player) -> Bool {
    let player1Board = player1.board
    let player2Board = player2.board
    
    for row in 0...2 {
        for col in 0...2 {
            if player1Board[row][col] == 0 && player2Board[row][col] == 0{
                return false
            }
        }
    }
    
    return true
}


//main view class
class TicTacToe: UIViewController{
    
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet var gameView: ARSCNView!
    @IBOutlet weak var cursor: UIImageView!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var miniGamesButton: UIButton!
    
    @IBOutlet weak var textBox: UILabel!
    
    @IBOutlet weak var zero: UIButton!
    @IBOutlet weak var one: UIButton!
    @IBOutlet weak var two: UIButton!
    @IBOutlet weak var three: UIButton!
    @IBOutlet weak var four: UIButton!
    @IBOutlet weak var five: UIButton!
    @IBOutlet weak var six: UIButton!
    @IBOutlet weak var seven: UIButton!
    @IBOutlet weak var eight: UIButton!
    
    var presentedPopup = false

    
    var player1 = player()
    var player2 = player()
    
    var circle = resizeImage(image: UIImage(systemName: "circle")!, targetSize: CGSize(width: 200.0, height: 200.0))
    var xmark = resizeImage(image: UIImage(systemName: "xmark")!, targetSize: CGSize(width: 200.0, height: 200.0))
    
    @IBAction func restartTap(_ sender: Any) {
        restart()
    }
    @IBAction func zeroButtonTap(_ sender: Any) {
        collisionCell(cellNumber: 0, isPlayer1: playerOneTurn)
    }
    
    @IBAction func oneButtonTap(_ sender: Any) {
        collisionCell(cellNumber: 1, isPlayer1: playerOneTurn)
    }
    @IBAction func twoButtonTap(_ sender: Any) {
        collisionCell(cellNumber: 2, isPlayer1: playerOneTurn)
    }
    @IBAction func threeButtonTap(_ sender: Any) {
        collisionCell(cellNumber: 3, isPlayer1: playerOneTurn)
    }
    @IBAction func fourButtonTap(_ sender: Any) {
        collisionCell(cellNumber: 4, isPlayer1: playerOneTurn)
    }
    @IBAction func fiveButtonTap(_ sender: Any) {
        collisionCell(cellNumber: 5, isPlayer1: playerOneTurn)
    }
    @IBAction func sixButtonTap(_ sender: Any) {
        collisionCell(cellNumber: 6, isPlayer1: playerOneTurn)
    }
    @IBAction func sevenButtonTap(_ sender: Any) {
        collisionCell(cellNumber: 7, isPlayer1: playerOneTurn)
    }
    @IBAction func eightButtonTap(_ sender: Any) {
        collisionCell(cellNumber: 8, isPlayer1: playerOneTurn)
    }

    var playerOneTurn = true
    
    
    let sceneNodes = nodes()
    
    let mainThread = DispatchQueue.main
    
    var seconds = 2
    var timer = Timer()
    var isTimerRunning = false
    var hoveringMenu = false
    var hoveringRestart = false
    var hoveringMiniGames = false
    var hoveringZero = false
    var hoveringOne = false
    var hoveringTwo = false
    var hoveringThree = false
    var hoveringFour = false
    var hoveringFive = false
    var hoveringSix = false
    var hoveringSeven = false
    var hoveringEight = false

    var soundPlayer: AVAudioPlayer?
    
    func playSelectionSound() {
                
        let path = Bundle.main.path(forResource: "select.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    func runTimer(button: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(TicTacToe.updateTimer)), userInfo: nil, repeats: true)
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
      gameView.session.run(configuration)
    }
    
    
    // pauses the view
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      gameView.session.pause()
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
        menuButton.layer.cornerRadius = 5;
        restartButton.layer.cornerRadius = 5;
        miniGamesButton.layer.cornerRadius = 5;
        
        zero.layer.cornerRadius = 5;
        one.layer.cornerRadius = 5;
        two.layer.cornerRadius = 5;
        three.layer.cornerRadius = 5;
        four.layer.cornerRadius = 5;
        five.layer.cornerRadius = 5;
        six.layer.cornerRadius = 5;
        seven.layer.cornerRadius = 5;
        eight.layer.cornerRadius = 5;
        
        zero.layer.borderWidth = 10;
        one.layer.borderWidth = 10;
        two.layer.borderWidth = 10;
        three.layer.borderWidth = 10;
        four.layer.borderWidth = 10;
        five.layer.borderWidth = 10;
        six.layer.borderWidth = 10;
        seven.layer.borderWidth = 10;
        eight.layer.borderWidth = 10;
        
        
        gameView.pointOfView?.addChildNode(sceneNodes.nodeInFrontOfScreen)
        gameView.scene.background.contents = UIColor.black
        gameView.delegate = self


    }
    
    
    //checks if the cursor is on top of the game button and if the user blinks
    func collisionMenuButton(){
        playSelectionSound()
            //go to game screen when user blinks over button
            mainThread.async {
                self.performSegue(withIdentifier: "mainMenuSegue", sender: self)
            }
    }
    func collisionMiniGamesButton(){
        playSelectionSound()
            //go to game screen when user blinks over button
            mainThread.async {
                self.performSegue(withIdentifier: "miniGameSegue", sender: self)
            }
    }
    
    func restart(){
        
        player1.board = [[0,0,0],[0,0,0],[0,0,0]]
        player2.board = [[0,0,0],[0,0,0],[0,0,0]]
        
        playerOneTurn = true
        
        mainThread.async {
            
            self.zero.setImage(nil, for: UIControl.State.normal)
            self.one.setImage(nil, for: UIControl.State.normal)
            self.two.setImage(nil, for: UIControl.State.normal)
            self.three.setImage(nil, for: UIControl.State.normal)
            self.four.setImage(nil, for: UIControl.State.normal)
            self.five.setImage(nil, for: UIControl.State.normal)
            self.six.setImage(nil, for: UIControl.State.normal)
            self.seven.setImage(nil, for: UIControl.State.normal)
            self.eight.setImage(nil, for: UIControl.State.normal)
            
            self.zero.isEnabled = true
            self.one.isEnabled = true
            self.two.isEnabled = true
            self.three.isEnabled = true
            self.four.isEnabled = true
            self.five.isEnabled = true
            self.six.isEnabled = true
            self.seven.isEnabled = true
            self.eight.isEnabled = true
            
            self.textBox.text = "Player 1 Turn"
            
        }
        
    }
    
    func collisionCell(cellNumber:Int, isPlayer1: Bool){
        playSelectionSound()
        let cellRow = cellNumber / 3;
        let cellCol = cellNumber - (3 * cellRow);
        
        var cellRef = zero.self;
        
        switch cellNumber {
        case 1:
            cellRef = one.self
        case 2:
            cellRef = two.self
        case 3:
            cellRef = three.self
        case 4:
            cellRef = four.self
        case 5:
            cellRef = five.self
        case 6:
            cellRef = six.self
        case 7:
            cellRef = seven.self
        case 8:
            cellRef = eight.self
        default:
            cellRef = zero.self
        }
        
        
        if player1.board[cellRow][cellCol] != 1 && player2.board[cellRow][cellCol] != 1{
            
            if isPlayer1{
                
                player1.board[cellRow][cellCol] = 1;
                
                mainThread.async {
                    cellRef?.setImage(self.circle, for: UIControl.State.normal)
                    self.playerOneTurn = false
                    
                    if checkWin(player: self.player1){
                        self.textBox.text = "Player 1 Wins!"
                        
                        self.zero.isEnabled = false
                        self.one.isEnabled = false
                        self.two.isEnabled = false
                        self.three.isEnabled = false
                        self.four.isEnabled = false
                        self.five.isEnabled = false
                        self.six.isEnabled = false
                        self.seven.isEnabled = false
                        self.eight.isEnabled = false
                        

                    }
                    else if checkTie(player1: self.player1, player2: self.player2){
                        
                        self.textBox.text = "Tie!"
                        
                        self.zero.isEnabled = false
                        self.one.isEnabled = false
                        self.two.isEnabled = false
                        self.three.isEnabled = false
                        self.four.isEnabled = false
                        self.five.isEnabled = false
                        self.six.isEnabled = false
                        self.seven.isEnabled = false
                        self.eight.isEnabled = false
                        
                        self.cursor.tintColor = cursorColor
                    }
                    else{
                        self.textBox.text = "Player 2's Turn"
                    }

                }
                
                
            }
            else{
                player2.board[cellRow][cellCol] = 1;
                
                mainThread.async {
                    cellRef?.setImage(self.xmark, for: UIControl.State.normal)
                    self.playerOneTurn = true
                    
                    if checkWin(player: self.player2){
                        self.textBox.text = "Player 2 Wins!"
                        
                        self.zero.isEnabled = false
                        self.one.isEnabled = false
                        self.two.isEnabled = false
                        self.three.isEnabled = false
                        self.four.isEnabled = false
                        self.five.isEnabled = false
                        self.six.isEnabled = false
                        self.seven.isEnabled = false
                        self.eight.isEnabled = false
                        self.cursor.tintColor = cursorColor
                    }
                    else if checkTie(player1: self.player1, player2: self.player2){
                        
                        self.textBox.text = "Tie!"
                        
                        self.zero.isEnabled = false
                        self.one.isEnabled = false
                        self.two.isEnabled = false
                        self.three.isEnabled = false
                        self.four.isEnabled = false
                        self.five.isEnabled = false
                        self.six.isEnabled = false
                        self.seven.isEnabled = false
                        self.eight.isEnabled = false
                        self.cursor.tintColor = cursorColor
                    }
                    else{
                        self.textBox.text = "Player 1's Turn"
                    }
                }
                
            }
            
        }
        
    }
    
}

extension TicTacToe: ARSCNViewDelegate {
    
    //a scene renderer that returns a scene node given a face anchor, runs once
    
      func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = gameView.device else {
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
                var image = UIImage(systemName: "grid")
                image = image?.withTintColor(UIColor.black)
                
                JSSAlertView().show(
                    self,
                      title: "Tip",
                      text: "Player 1 uses your eyes, Player 2 use your fingers!",
                      buttonText: "OK",
                    color: UIColor.white,
                    iconImage: image,
                    delay: 5.0
                )
                
                self.presentedPopup = true
            }
            
            if !self.playerOneTurn && self.zero.isEnabled{
                self.cursor.tintColor = UIColor.clear
            }
            else if (self.playerOneTurn && self.zero.isEnabled) || (!self.zero.isEnabled){
                self.cursor.tintColor = cursorColor
            }
            

            
            if (self.cursor.frame.intersects(self.menuButton.frame)){
                
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
                self.hoveringRestart = false
                self.hoveringMiniGames = false
                self.hoveringZero = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.one)
                self.resetColor(button: self.two)
                self.resetColor(button: self.three)
                self.resetColor(button: self.four)
                self.resetColor(button: self.five)
                self.resetColor(button: self.six)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.eight)

            }
            else if (self.cursor.frame.intersects(self.restartButton.frame)) {
                self.restartButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.restartButton)
                }
                
                if self.hoveringRestart && self.seconds <= 0 {
                    self.restart()
                    self.resetTimer()
                    
                }
                else if !self.hoveringRestart{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringRestart = true
                self.hoveringMiniGames = false
                self.hoveringZero = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.one)
                self.resetColor(button: self.two)
                self.resetColor(button: self.three)
                self.resetColor(button: self.four)
                self.resetColor(button: self.five)
                self.resetColor(button: self.six)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.eight)
            }
            else if (self.cursor.frame.intersects(self.miniGamesButton.frame)){
                
                self.miniGamesButton.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.miniGamesButton)
                }
                
                if self.hoveringMiniGames && self.seconds <= 0 {
                    self.collisionMiniGamesButton()
                    self.resetTimer()
                    
                }
                else if !self.hoveringMiniGames{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringRestart = false
                self.hoveringMiniGames = true
                self.hoveringZero = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.one)
                self.resetColor(button: self.two)
                self.resetColor(button: self.three)
                self.resetColor(button: self.four)
                self.resetColor(button: self.five)
                self.resetColor(button: self.six)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.eight)
            }
            
            
            else if self.cursor.frame.intersects(self.zero.frame) && self.playerOneTurn{
                
                self.zero.layer.borderColor = UIColor.systemBlue.cgColor
                self.one.layer.borderColor = UIColor.clear.cgColor
                self.two.layer.borderColor = UIColor.clear.cgColor
                self.three.layer.borderColor = UIColor.clear.cgColor
                self.four.layer.borderColor = UIColor.clear.cgColor
                self.five.layer.borderColor = UIColor.clear.cgColor
                self.six.layer.borderColor = UIColor.clear.cgColor
                self.seven.layer.borderColor = UIColor.clear.cgColor
                self.eight.layer.borderColor = UIColor.clear.cgColor

                
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.zero)
                }
                
                if self.hoveringZero && self.seconds <= 0 {
                    self.collisionCell(cellNumber: 0, isPlayer1: self.playerOneTurn)
                    self.resetTimer()
                    
                }
                else if !self.hoveringZero{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringRestart = false
                self.hoveringMiniGames = false
                self.hoveringZero = true
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.one)
                self.resetColor(button: self.two)
                self.resetColor(button: self.three)
                self.resetColor(button: self.four)
                self.resetColor(button: self.five)
                self.resetColor(button: self.six)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.eight)
            }
            else if self.cursor.frame.intersects(self.one.frame) && self.playerOneTurn{
                
                self.zero.layer.borderColor = UIColor.clear.cgColor
                self.one.layer.borderColor = UIColor.systemBlue.cgColor
                self.two.layer.borderColor = UIColor.clear.cgColor
                self.three.layer.borderColor = UIColor.clear.cgColor
                self.four.layer.borderColor = UIColor.clear.cgColor
                self.five.layer.borderColor = UIColor.clear.cgColor
                self.six.layer.borderColor = UIColor.clear.cgColor
                self.seven.layer.borderColor = UIColor.clear.cgColor
                self.eight.layer.borderColor = UIColor.clear.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.one)
                }
                
                if self.hoveringOne && self.seconds <= 0 {
                    self.collisionCell(cellNumber: 1, isPlayer1: self.playerOneTurn)
                    self.resetTimer()
                    
                }
                else if !self.hoveringOne{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringRestart = false
                self.hoveringMiniGames = false
                self.hoveringZero = false
                self.hoveringOne = true
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.two)
                self.resetColor(button: self.three)
                self.resetColor(button: self.four)
                self.resetColor(button: self.five)
                self.resetColor(button: self.six)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.eight)
            }
            else if self.cursor.frame.intersects(self.two.frame) && self.playerOneTurn{
                self.zero.layer.borderColor = UIColor.clear.cgColor
                self.one.layer.borderColor = UIColor.clear.cgColor
                self.two.layer.borderColor = UIColor.systemBlue.cgColor
                self.three.layer.borderColor = UIColor.clear.cgColor
                self.four.layer.borderColor = UIColor.clear.cgColor
                self.five.layer.borderColor = UIColor.clear.cgColor
                self.six.layer.borderColor = UIColor.clear.cgColor
                self.seven.layer.borderColor = UIColor.clear.cgColor
                self.eight.layer.borderColor = UIColor.clear.cgColor

                if !self.isTimerRunning{
                    self.runTimer(button: self.two)
                }
                
                if self.hoveringTwo && self.seconds <= 0 {
                    self.collisionCell(cellNumber: 2, isPlayer1: self.playerOneTurn)
                    self.resetTimer()
                    
                }
                else if !self.hoveringTwo{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringRestart = false
                self.hoveringMiniGames = false
                self.hoveringZero = false
                self.hoveringOne = false
                self.hoveringTwo = true
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.one)
                self.resetColor(button: self.three)
                self.resetColor(button: self.four)
                self.resetColor(button: self.five)
                self.resetColor(button: self.six)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.eight)
            }
            else if self.cursor.frame.intersects(self.three.frame) && self.playerOneTurn{
                
                self.zero.layer.borderColor = UIColor.clear.cgColor
                self.one.layer.borderColor = UIColor.clear.cgColor
                self.two.layer.borderColor = UIColor.clear.cgColor
                self.three.layer.borderColor = UIColor.systemBlue.cgColor
                self.four.layer.borderColor = UIColor.clear.cgColor
                self.five.layer.borderColor = UIColor.clear.cgColor
                self.six.layer.borderColor = UIColor.clear.cgColor
                self.seven.layer.borderColor = UIColor.clear.cgColor
                self.eight.layer.borderColor = UIColor.clear.cgColor

                if !self.isTimerRunning{
                    self.runTimer(button: self.three)
                }
                
                if self.hoveringThree && self.seconds <= 0 {
                    self.collisionCell(cellNumber: 3, isPlayer1: self.playerOneTurn)
                    self.resetTimer()
                    
                }
                else if !self.hoveringThree{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringRestart = false
                self.hoveringMiniGames = false
                self.hoveringZero = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = true
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.one)
                self.resetColor(button: self.two)
                self.resetColor(button: self.four)
                self.resetColor(button: self.five)
                self.resetColor(button: self.six)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.eight)
            }
            else if self.cursor.frame.intersects(self.four.frame) && self.playerOneTurn{

                self.zero.layer.borderColor = UIColor.clear.cgColor
                self.one.layer.borderColor = UIColor.clear.cgColor
                self.two.layer.borderColor = UIColor.clear.cgColor
                self.three.layer.borderColor = UIColor.clear.cgColor
                self.four.layer.borderColor = UIColor.systemBlue.cgColor
                self.five.layer.borderColor = UIColor.clear.cgColor
                self.six.layer.borderColor = UIColor.clear.cgColor
                self.seven.layer.borderColor = UIColor.clear.cgColor
                self.eight.layer.borderColor = UIColor.clear.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.four)
                }
                
                if self.hoveringFour && self.seconds <= 0 {
                    self.collisionCell(cellNumber: 4, isPlayer1: self.playerOneTurn)
                    self.resetTimer()
                    
                }
                else if !self.hoveringFour{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringRestart = false
                self.hoveringMiniGames = false
                self.hoveringZero = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = true
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.one)
                self.resetColor(button: self.three)
                self.resetColor(button: self.two)
                self.resetColor(button: self.five)
                self.resetColor(button: self.six)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.eight)
            }
            else if self.cursor.frame.intersects(self.five.frame) && self.playerOneTurn{

                self.zero.layer.borderColor = UIColor.clear.cgColor
                self.one.layer.borderColor = UIColor.clear.cgColor
                self.two.layer.borderColor = UIColor.clear.cgColor
                self.three.layer.borderColor = UIColor.clear.cgColor
                self.four.layer.borderColor = UIColor.clear.cgColor
                self.five.layer.borderColor = UIColor.systemBlue.cgColor
                self.six.layer.borderColor = UIColor.clear.cgColor
                self.seven.layer.borderColor = UIColor.clear.cgColor
                self.eight.layer.borderColor = UIColor.clear.cgColor

                if !self.isTimerRunning{
                    self.runTimer(button: self.five)
                }
                
                if self.hoveringFive && self.seconds <= 0 {
                    self.collisionCell(cellNumber: 5, isPlayer1: self.playerOneTurn)
                    self.resetTimer()
                    
                }
                else if !self.hoveringFive{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringRestart = false
                self.hoveringMiniGames = false
                self.hoveringZero = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = true
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.one)
                self.resetColor(button: self.three)
                self.resetColor(button: self.four)
                self.resetColor(button: self.two)
                self.resetColor(button: self.six)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.eight)
            }
            else if self.cursor.frame.intersects(self.six.frame) && self.playerOneTurn{

                self.zero.layer.borderColor = UIColor.clear.cgColor
                self.one.layer.borderColor = UIColor.clear.cgColor
                self.two.layer.borderColor = UIColor.clear.cgColor
                self.three.layer.borderColor = UIColor.clear.cgColor
                self.four.layer.borderColor = UIColor.clear.cgColor
                self.five.layer.borderColor = UIColor.clear.cgColor
                self.six.layer.borderColor = UIColor.systemBlue.cgColor
                self.seven.layer.borderColor = UIColor.clear.cgColor
                self.eight.layer.borderColor = UIColor.clear.cgColor

                if !self.isTimerRunning{
                    self.runTimer(button: self.six)
                }
                
                if self.hoveringSix && self.seconds <= 0 {
                    self.collisionCell(cellNumber: 6, isPlayer1: self.playerOneTurn)
                    self.resetTimer()
                    
                }
                else if !self.hoveringSix{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringRestart = false
                self.hoveringMiniGames = false
                self.hoveringZero = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = true
                self.hoveringSeven = false
                self.hoveringEight = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.one)
                self.resetColor(button: self.three)
                self.resetColor(button: self.four)
                self.resetColor(button: self.five)
                self.resetColor(button: self.two)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.eight)
            }
            else if self.cursor.frame.intersects(self.seven.frame) && self.playerOneTurn{

                self.zero.layer.borderColor = UIColor.clear.cgColor
                self.one.layer.borderColor = UIColor.clear.cgColor
                self.two.layer.borderColor = UIColor.clear.cgColor
                self.three.layer.borderColor = UIColor.clear.cgColor
                self.four.layer.borderColor = UIColor.clear.cgColor
                self.five.layer.borderColor = UIColor.clear.cgColor
                self.six.layer.borderColor = UIColor.clear.cgColor
                self.seven.layer.borderColor = UIColor.systemBlue.cgColor
                self.eight.layer.borderColor = UIColor.clear.cgColor

                if !self.isTimerRunning{
                    self.runTimer(button: self.seven)
                }
                
                if self.hoveringSeven && self.seconds <= 0 {
                    self.collisionCell(cellNumber: 7, isPlayer1: self.playerOneTurn)
                    self.resetTimer()
                    
                }
                else if !self.hoveringSeven{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringRestart = false
                self.hoveringMiniGames = false
                self.hoveringZero = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = true
                self.hoveringEight = false
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.one)
                self.resetColor(button: self.three)
                self.resetColor(button: self.four)
                self.resetColor(button: self.five)
                self.resetColor(button: self.six)
                self.resetColor(button: self.two)
                self.resetColor(button: self.eight)
            }
            else if self.cursor.frame.intersects(self.eight.frame) && self.playerOneTurn{
                
                self.zero.layer.borderColor = UIColor.clear.cgColor
                self.one.layer.borderColor = UIColor.clear.cgColor
                self.two.layer.borderColor = UIColor.clear.cgColor
                self.three.layer.borderColor = UIColor.clear.cgColor
                self.four.layer.borderColor = UIColor.clear.cgColor
                self.five.layer.borderColor = UIColor.clear.cgColor
                self.six.layer.borderColor = UIColor.clear.cgColor
                self.seven.layer.borderColor = UIColor.clear.cgColor
                self.eight.layer.borderColor = UIColor.systemBlue.cgColor
                
                if !self.isTimerRunning{
                    self.runTimer(button: self.eight)
                }
                
                if self.hoveringEight && self.seconds <= 0 {
                    self.collisionCell(cellNumber: 8, isPlayer1: self.playerOneTurn)
                    self.resetTimer()
                    
                }
                else if !self.hoveringEight{
                    self.resetTimer()
                }
                
                self.hoveringMenu = false
                self.hoveringRestart = false
                self.hoveringMiniGames = false
                self.hoveringZero = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = true
                
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.one)
                self.resetColor(button: self.three)
                self.resetColor(button: self.four)
                self.resetColor(button: self.five)
                self.resetColor(button: self.six)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.two)
            }
            else{
                self.menuButton.layer.borderColor = UIColor.clear.cgColor
                self.restartButton.layer.borderColor = UIColor.clear.cgColor
                self.miniGamesButton.layer.borderColor = UIColor.clear.cgColor
                self.zero.layer.borderColor = UIColor.clear.cgColor
                self.one.layer.borderColor = UIColor.clear.cgColor
                self.two.layer.borderColor = UIColor.clear.cgColor
                self.three.layer.borderColor = UIColor.clear.cgColor
                self.four.layer.borderColor = UIColor.clear.cgColor
                self.five.layer.borderColor = UIColor.clear.cgColor
                self.six.layer.borderColor = UIColor.clear.cgColor
                self.seven.layer.borderColor = UIColor.clear.cgColor
                self.eight.layer.borderColor = UIColor.clear.cgColor
                
                self.hoveringMenu = false
                self.hoveringRestart = false
                self.hoveringMiniGames = false
                self.hoveringZero = false
                self.hoveringOne = false
                self.hoveringTwo = false
                self.hoveringThree = false
                self.hoveringFour = false
                self.hoveringFive = false
                self.hoveringSix = false
                self.hoveringSeven = false
                self.hoveringEight = false

                self.resetColor(button: self.restartButton)
                self.resetColor(button: self.menuButton)
                self.resetColor(button: self.miniGamesButton)
                self.resetColor(button: self.zero)
                self.resetColor(button: self.one)
                self.resetColor(button: self.two)
                self.resetColor(button: self.three)
                self.resetColor(button: self.four)
                self.resetColor(button: self.five)
                self.resetColor(button: self.six)
                self.resetColor(button: self.seven)
                self.resetColor(button: self.eight)
                
                self.resetTimer()
            }
        }
        
    }
    
}

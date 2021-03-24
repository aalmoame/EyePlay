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

        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }

        cursor.frame.size = CGSize(width: cursorSize.width, height: cursorSize.height);
        cursor.tintColor = cursorColor
        cursor.layer.zPosition = 1;
        menuButton.layer.cornerRadius = 10;
        restartButton.layer.cornerRadius = 10;
        miniGamesButton.layer.cornerRadius = 10;
        
        zero.layer.cornerRadius = 10;
        one.layer.cornerRadius = 10;
        two.layer.cornerRadius = 10;
        three.layer.cornerRadius = 10;
        four.layer.cornerRadius = 10;
        five.layer.cornerRadius = 10;
        six.layer.cornerRadius = 10;
        seven.layer.cornerRadius = 10;
        eight.layer.cornerRadius = 10;
        
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

            //go to game screen when user blinks over button
            mainThread.async {
                self.performSegue(withIdentifier: "mainMenuSegue", sender: self)
            }
    }
    func collisionMiniGamesButton(){

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
                        self.textBox.text = "Player 2 Turn"
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
                        self.textBox.text = "Player 1 Turn"
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
            
        
        let eyeBlinkValue = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
        
        
        mainThread.async {
            
            if !self.playerOneTurn && self.zero.isEnabled{
                self.cursor.tintColor = UIColor.clear
            }
            else if (self.playerOneTurn && self.zero.isEnabled) || (!self.zero.isEnabled){
                self.cursor.tintColor = cursorColor
            }
            

            
            if (self.cursor.frame.intersects(self.menuButton.frame)){
                
                self.menuButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                    self.collisionMenuButton();
                }
                
            }
            else if (self.cursor.frame.intersects(self.restartButton.frame)) {
                self.restartButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                    self.restart();
                }
            }
            else if (self.cursor.frame.intersects(self.miniGamesButton.frame)){
                
                self.miniGamesButton.layer.borderColor = UIColor.red.cgColor
                
                if eyeBlinkValue > 0.5 {
                    self.collisionMiniGamesButton();
                }
            }
            
            
            else if self.cursor.frame.intersects(self.zero.frame) && self.playerOneTurn{
                self.zero.layer.borderColor = UIColor.red.cgColor
                if eyeBlinkValue > 0.5{
                    self.collisionCell(cellNumber: 0, isPlayer1: self.playerOneTurn)

                }
            }
            else if self.cursor.frame.intersects(self.one.frame) && self.playerOneTurn{
                self.one.layer.borderColor = UIColor.red.cgColor
                if eyeBlinkValue > 0.5{
                    self.collisionCell(cellNumber: 1, isPlayer1: self.playerOneTurn)

                }
            }
            else if self.cursor.frame.intersects(self.two.frame) && self.playerOneTurn{
                self.two.layer.borderColor = UIColor.red.cgColor
                if eyeBlinkValue > 0.5{
                    self.collisionCell(cellNumber: 2, isPlayer1: self.playerOneTurn)

                }
            }
            else if self.cursor.frame.intersects(self.three.frame) && self.playerOneTurn{
                self.three.layer.borderColor = UIColor.red.cgColor
                if eyeBlinkValue > 0.5{
                    self.collisionCell(cellNumber: 3, isPlayer1: self.playerOneTurn)

                }
            }
            else if self.cursor.frame.intersects(self.four.frame) && self.playerOneTurn{
                self.four.layer.borderColor = UIColor.red.cgColor
                if eyeBlinkValue > 0.5{
                    self.collisionCell(cellNumber: 4, isPlayer1: self.playerOneTurn)

                }
            }
            else if self.cursor.frame.intersects(self.five.frame) && self.playerOneTurn{
                self.five.layer.borderColor = UIColor.red.cgColor
                if eyeBlinkValue > 0.5{
                    self.collisionCell(cellNumber: 5, isPlayer1: self.playerOneTurn)

                }
            }
            else if self.cursor.frame.intersects(self.six.frame) && eyeBlinkValue > 0.5 && self.playerOneTurn{
                self.six.layer.borderColor = UIColor.red.cgColor
                if eyeBlinkValue > 0.5{
                    self.collisionCell(cellNumber: 6, isPlayer1: self.playerOneTurn)

                }
            }
            else if self.cursor.frame.intersects(self.seven.frame) && self.playerOneTurn{
                self.seven.layer.borderColor = UIColor.red.cgColor
                if eyeBlinkValue > 0.5{
                    self.collisionCell(cellNumber: 7, isPlayer1: self.playerOneTurn)

                }
            }
            else if self.cursor.frame.intersects(self.eight.frame) && self.playerOneTurn{
                self.eight.layer.borderColor = UIColor.red.cgColor
                if eyeBlinkValue > 0.5{
                    self.collisionCell(cellNumber: 8, isPlayer1: self.playerOneTurn)

                }
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

            }
        }
        
    }
    
}

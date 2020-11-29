//
//  MainController.swift
//  Word FlakesGameState

//


import UIKit
import Darwin

class MainController: UIViewController {
    
    
    
// MARK: controllers
    
    @IBOutlet weak var wordView: WordView!
    @IBOutlet weak var boardView: UIImageView!

    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var backspaceButton: UIButton!
    @IBOutlet weak var lblEnergy: UILabel!
    @IBOutlet weak var lblEnergyAdd: UILabel!
    
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblScoreAdd: UILabel!

    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblPause: UIButton!
    
    var gameOverView      :   UIView! = nil
    var gameOverViewLabel : UILabel!  = nil
    
        
// MARK: constants
    
    enum GameState {
        case GameStarted
        case GamePaused
        case GamePausedForQuestionMark
        case GameOver
    }
    
     
    let INIT_ENERGY: Double = 100
    let EXPONENT   : Double = 0.60
    let TIME_CONST : Double = 0.0095
    let TIME_MULT  : Double = 0.00027
    let ENERGY_MULT: Double = 0.00011
    let TIME_INT   : Double = 0.03
    let LOW_ENERGY_MARKER : Double = 75
    let DUR_SPAWNER: Double = 12
    let NUM_CHARS  :   Int  = 6
    let SPAWNER_CHARS: Int  = 11
    let DUR_SNOWFLAKE : Double = 12
    let COIN_BONUS :   Int  = 250
    
    let ipod  = BoomBox()
    let defaults = UserDefaults.standard
    
    
 
// MARK: properties
    
    var specialClock = 0.00
    //var restartButton : UIButton!
    var listLetters : [String]!
    var listFreq    : [Int]!
    
    
    //var snowFlakeMode = 0
    var effects : EffectsController!
    var gameState : GameState!
    var gameStateBeforePause : GameState!
    private var highScores = [Int]()
    private var timer      = Timer()
    
    private var energy      : Double = 0.0
    private var timeElapsed : Double = 0
    private var freeLetters = [LetterView]()
    
    private var snowFlakes = [LetterView]()
    
    private var highScore   = 0
    private var score       = 0
    
    var questionMark : LetterView!
    
// MARK: control actions
    
    override var prefersStatusBarHidden: Bool {
        get {return true}
    }
    
    func decrementEnergy(){
        
        let expScoreAdj = 1.065       //( (energy < 1500) ? 0.98 : 1.05 )
        let scoreAdj = pow(energy, expScoreAdj) * ENERGY_MULT
        let delta    = TIME_CONST + power(timeElapsed) * TIME_MULT + scoreAdj
    
        energy -= delta
        lblEnergy.text = "Energy: \((Int(energy)))"
    }
    
    @IBAction func backspaceButtonClicked(_ sender: UIButton) {
        
        if (gameState != GameState.GameStarted){return}
        
        if (wordView.removeLastLetter()) { ipod.play("forDiscardLetters", "mp3")}
        
        displayBonus()
        // addScore(0, energyAdd: -Double(value) , display: true)
        //  if wordView.tileRack.count <  playSound("forDiscardLetters", type: "mp3")
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        
        if (gameState != GameState.GameStarted){return}
        
        let toAdd = wordView.submitWord()
        
        if (toAdd != 0){
            displayBonus()
            addScore(toAdd,  Double(toAdd),  true)
            if (toAdd > 150){ effects.celebrate()}
            
            ipod.play("wordGood")
        }
        else {
            ipod.play("incorrectWord")
        }
    }
        
    /*This function identifies the Special Tile and calls approapreite method(s) associated with
   that tile */
    @objc
    func specialActivated(_ tile : LetterView){
        
        if (gameState != GameState.GameStarted){return}
        
        freeLetters = freeLetters.filter({ $0 != tile })
        
        switch tile.letter{
        case "*"        : activateSpawner(button:tile)
        case "BOOM"     : sonicBoom(button:tile)
        case "?"        : letterChooser(button:tile)
        case "SNOW"     : snowFlake(button:tile)
        case "COIN"     : goldCoin(button:tile)
        case "PAINT"    : paintBrush(button:tile)
        default         : return
        }
    }
    
    @objc
    func letterClicked(_ button : LetterView){
        
        
        if (gameState != GameState.GameStarted){return}
        
        if (button.superview == wordView){return} // letter is already selected
        
        //animateButtonPress(button)
        
        ipod.playFromStart("click3")
        
        freeLetters = freeLetters.filter({ $0 != button })
        
        wordView.addLetter(button:button)
        
        displayBonus()
        
        if (freeLetters.count < NUM_CHARS) || (specialClock > 0) {addFreeLetter()}
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainController.homeButtonPress(_:)), name:UIApplication.willResignActiveNotification, object: nil)
        
        //srand(UInt32(time(nil)))
        
        effects = EffectsController(mainView: self.view)
        //clearHighScores()
        //var firstTime = true
        
        adjustVolumes()
        //initRestartButton()
        //clearHighScores()
        
        highScores = defaults.object(forKey: "HighScores") as? [Int] ?? [Int]()
        
        if !(highScores.isEmpty){
            highScore = highScores[0]
            //firstTime = false
        }

        let deleteAll = UILongPressGestureRecognizer(target: self, action: #selector(deleteAll(_:)))
        deleteAll.minimumPressDuration = 0.25
        
        self.backspaceButton.addGestureRecognizer(deleteAll)

        //self.setUpLabels()
        
        self.view.sendSubviewToBack(boardView)
        
        initGameOverView()
        
        formatButtons()
        
        // calculate max number of letters to display
        
        let num = ((self.view.frame.width - 20.0)/(LetterView.TILE_SIDE + 3.0))
        
        wordView.maxDisplayLength = Int(num)
        
        run()
    }
    
    //override func prefersStatusBarHidden() -> Bool {
    //    return true
    //}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func pausePressed(_ sender: UIButton) {
        
        if (gameState == GameState.GamePausedForQuestionMark){
            return
        }
        
        ipod.pauseAll()
        ipod.play("pause", "mp3")
        gameStateBeforePause = gameState
        gameState = GameState.GamePaused
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier:"MenuController") as! MenuController
        
        vc.mainController = self
        
        vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
    
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: methods
    @objc
    func deleteAll(_ guesture: UILongPressGestureRecognizer) {
        
        if (gameState != GameState.GameStarted) {return}
        
        if guesture.state == UIGestureRecognizer.State.began {
            if (wordView.removeAll()) {ipod.play("removeAll")}
        }
        
        displayBonus()
    }
    

    func addFreeLetter(x : CGFloat =  -1, y : CGFloat = -1){
        
        let letter = LetterView (boardFrame: boardView.frame)
        
        if (x != -1) {letter.updateCoordinates(x: x, y: y, speed: 1.4)}
        
        if !letter.isSpecial{
            letter.addTarget(self, action: #selector(MainController.letterClicked(_:)), for: .touchDown)
        }
        else {
            letter.addTarget(self, action: #selector(MainController.specialActivated(_:)), for: .touchDown)
        }
        
        self.view.addSubview(letter)
        self.view.bringSubviewToFront(letter)
        
        freeLetters.append(letter)
    }
    
    func run(){
        
        var counter = 0
        
        // clean up the game
        energy = INIT_ENERGY
        score  = 0
        timeElapsed = 0
        gameState = GameState.GameStarted
        
        backspaceButton.isHidden = false
        playButton.isHidden      = false
        //restartButton.hidden   = true
        lblScore.text  = "Score:  \(score)"
        lblEnergy.text = "Energy: \((Int(energy)))"
        
        timer.invalidate()
        
        effects.highScoreCelebrateOff()
        
        _ = wordView.removeAll()
        
        lblStatus.isHidden    = true
        lblEnergyAdd.isHidden = true
        lblScoreAdd.isHidden  = true
        
        gameOverView.isHidden = true
        
        
        if (self.children.count > 0){
            self.children[0].view.removeFromSuperview()
            self.children[0].removeFromParent()
            questionMark.removeFromSuperview()
        }
        
        for letter in freeLetters{
            letter.removeFromSuperview()
        }
        freeLetters.removeAll()
        
        displayStatus(status:"Welcome!", dismiss: true)
        // end of cleanup
        
        for _ in 0..<NUM_CHARS{
            addFreeLetter()
        }
        
        timer = Timer.scheduledTimer(timeInterval:TIME_INT, target:self, selector: #selector(MainController.updateState), userInfo: nil, repeats: true)
        
        counter += 1
    }
        
    func initGameOverView() {
        
        if (gameOverView != nil) {return}
 
        let x : CGFloat = 20
        let y : CGFloat = 100
        let w : CGFloat = self.view.frame.width - 40
        let h : CGFloat =  150
       
        gameOverView = UIView(frame: CGRect(x: x, y: y, width: w, height: h))
 
        gameOverView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        gameOverView.layer.borderWidth = 3
        gameOverView.layer.borderColor = UIColor.white.cgColor
        gameOverView.layer.cornerRadius = 20
        gameOverView.layer.shadowOffset = CGSize(width:0, height:3)
        
        gameOverView.layer.shadowColor = UIColor.white.cgColor
        gameOverView.layer.shadowOpacity = 0.5
        
        gameOverViewLabel = UILabel(frame: CGRect(x: 0, y: 0, width: gameOverView.frame.width, height: 40))
        
        gameOverViewLabel.textAlignment = NSTextAlignment.center
        gameOverViewLabel.font = UIFont(name: "Noteworthy-Bold", size: 30)
        gameOverViewLabel.textColor = UIColor.white
        gameOverView.addSubview(gameOverViewLabel)
        
        gameOverViewLabel.center = CGPoint(x: gameOverView.frame.width/2.0, y: 40)
        
        let restart = UIButton(type: .custom)
        
        restart.frame = CGRect(x: 0, y: 0, width: 71, height: 30)
        restart.setTitle("Restart", for: UIControl.State.normal)
        restart.titleLabel?.font = UIFont(name: "Noteworthy-Bold", size: 14)
        restart.backgroundColor = UIColor.white
        restart.setTitleColor(EffectsController.DARK_BLUE_COLOR, for: .normal)
        
        restart.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        restart.layer.cornerRadius = 15.0;
        
        restart.layer.borderWidth = 2.0; //was 2.0
        restart.layer.borderColor = UIColor.blue.cgColor
        
        restart.layer.shadowOpacity = 0.0
        restart.layer.shadowRadius = 0.0
        
        //effects.formatButton(restart)
        restart.addTarget(self, action:   #selector(MainController.restartButtonClicked(_:)), for: .touchDown)
        
        gameOverView.addSubview(restart)
        
        restart.center = CGPoint(x: gameOverView.frame.width/2.0, y: gameOverView.frame.height - 30)
      
        let imgR = UIImageView(image: UIImage(named: "Rt"))
        
        imgR.frame = CGRect(x: 18, y: gameOverView.frame.height - 55, width: 45, height: 45)
        
        gameOverView.addSubview(imgR)
        
        let imgS = UIImageView(image: UIImage(named: "St"))
        
        imgS.frame = CGRect(x: gameOverView.frame.width - 54, y: 57, width: 45, height: 45)
        
        gameOverView.addSubview(imgS)
        
        self.view.addSubview(gameOverView)
        self.view.bringSubviewToFront (gameOverView)
        
        gameOverView.isHidden = true
    }
    
    
    @objc
    func restartButtonClicked(_ button : UIButton){run()}
    
    
    @objc
    func updateState() {
        if (gameState != GameState.GameStarted) {return}
        
        if (energy < 15) && (energy > 9){ //Do not call too many times
            ipod.playIfNotPlaying(file:"dramatic", type: "mp3")
        }
        
        if (energy <= 0){
            let toAdd = wordView.submitWord()
            
            if (toAdd != 0){
                addScore( toAdd, Double(toAdd ), true)
            }
            else{
                gameOver()
                return
            }
        }

        if (snowFlakes.count == 0){
            
            specialClock -= TIME_INT
            timeElapsed += 1
            decrementEnergy()
        }
        
        if (energy > LOW_ENERGY_MARKER){
           lblEnergy.textColor = EffectsController.LABEL_TEXT_COLOR
        }
        else {
            lblEnergy.textColor = EffectsController.COLOR_PLATE[9 - Int( energy*(9/LOW_ENERGY_MARKER))]
        }
        
        for i in (0..<freeLetters.count).reversed(){
            
            let l = freeLetters[i]
            
            let (dx, dy) = l.velocity
            
            var x = l.center.x + CGFloat(dx)
            var y = l.center.y + CGFloat(dy)
            
            if (l.isAged()){
                if !boardView.superview!.frame.intersects(l.frame) {
                    
                    l.removeFromSuperview()
                    freeLetters.remove(at:i)
                    if (freeLetters.count < NUM_CHARS) || (specialClock > 0) {addFreeLetter()}
                }
            }
            else {
                if (x > boardView.frame.maxX + 0.05) {
                    if (l.incrementAge()){
                        x = boardView.frame.maxX
                        l.velocity = (-dx, dy)
                    }
                }
                else if (x < boardView.frame.minX - 0.05) {
                    if (l.incrementAge()){
                        x = boardView.frame.minX
                        l.velocity = (-dx, dy)
                    }
                }
                if (y > boardView.frame.maxY +  0.05) {
                    if (l.incrementAge()) {
                        y = boardView.frame.maxY
                        l.velocity = (dx, -dy)
                    }
                }
                else if (y < boardView.frame.minY - 0.05) {
                    if (l.incrementAge()){
                        y = boardView.frame.minY
                        l.velocity = (dx, -dy)
                    }
                }
            }
            l.center = CGPoint(x:x, y:y)
            l.rotationAngle = l.rotationAngle + l.angularVelocity
            l.rotate()
        }
    }
    
        
    @objc
    func moveLetters(){
        
        if (freeLetters.count == 0) {timer.invalidate()} //No more need to move
        
        for i in (0..<freeLetters.count).reversed(){
            
            let l = freeLetters[i]
            
            let (dx, dy) = l.velocity
            
            var x = l.center.x + CGFloat(dx)
            var y = l.center.y + CGFloat(dy)
            
            if (l.isAged()){
                if !boardView.superview!.frame.intersects(l.frame){
                    
                    l.removeFromSuperview()
                    freeLetters.remove(at: i)
                    if (freeLetters.count < NUM_CHARS) || (specialClock > 0){
                        // nothing?
                    }
                }
            }
            else {
                if (x > boardView.frame.maxX) {
                    if (l.incrementAge()){
                        x = boardView.frame.maxX
                        l.velocity = (-dx, dy)
                    }
                }
                else if (x < boardView.frame.minX) {
                    if (l.incrementAge()){
                        x = boardView.frame.minX
                        l.velocity = (-dx, dy)
                    }
                }
                if (y > boardView.frame.maxY) {
                    if (l.incrementAge()) {
                        y = boardView.frame.maxY
                        l.velocity = (dx, -dy)
                    }
                }
                else if (y < boardView.frame.minY) {
                    if (l.incrementAge()){
                        y = boardView.frame.minY
                        l.velocity = (dx, -dy)
                    }
                }
            }
            l.center = CGPoint(x:x, y:y)
            l.rotationAngle = l.rotationAngle + l.angularVelocity
            l.rotate()
        }
    }
    

    func gameOver(){
        
        timer.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval:TIME_INT, target:self, selector: #selector(MainController.moveLetters), userInfo: nil, repeats: true)
        
        ipod.shutUp(file:"dramatic", type: "mp3")
        ipod.shutUp(file:"forSnow", type: "mp3")
        ipod.play("gameOver")
        
        gameOverView.alpha = 0.0
        gameOverView.isHidden = false
        
        self.gameOverView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(CGFloat(Double.pi), 0.3, 0.5, 0.3), CATransform3DMakeScale(0.2, 0.2, 0.2))
        self.view.bringSubviewToFront(self.gameOverView)
        
        self.view.bringSubviewToFront(gameOverView)
        
        let place = handleHighScore()
        
        if place != -1 {
            effects.highScoreCelebrateOn()
            
            if (place == 0){
                gameOverViewLabel.font = gameOverViewLabel.font.withSize(28)
                // gameOverViewLabel.textColor = UIColor.redColor()
                gameOverViewLabel.text = "New High Score!"
            }
            else {
                gameOverViewLabel.font = gameOverViewLabel.font.withSize(31)
                gameOverViewLabel.textColor = UIColor.white
                gameOverViewLabel.text = "Top Ten Score!"
            }
        }
        else {
            gameOverViewLabel.text = "Game Over!"
            gameOverViewLabel.font = gameOverViewLabel.font.withSize(37)
            gameOverViewLabel.textColor = UIColor.white
        }
        
        UIView.animate(withDuration:2, animations: {
            self.gameOverView.alpha = 1.0
            self.gameOverView.transform = CGAffineTransform.identity
        })
  
        gameState = GameState.GameOver
    }
    
    func handleHighScore() -> Int {
        let len = highScores.count
        var place = -1
        var i = 0
        var newArray = [Int]()
        
        print("score = \(score)")
        
        if (score == 0) {return -1}
        
        if (len < 10) {
            while (i < len) && (score < highScores[i]) {
                newArray.append(highScores[i])
                i += 1
            }
            newArray.append(score)
            place = i
            while i < (len){
                newArray.append(highScores[i])
                i += 1
            }
            
            defaults.set(newArray, forKey: "HighScores")
            
            highScores = newArray
            
            highScore = highScores[0]
            
            //playSound("newHighScore")
        }
        else if (score > highScores.last!){
            while(score < highScores[i]){
                newArray.append(highScores[i])
                i += 1
            }
            newArray.append(score)
            place = i
            while i < (9){
                newArray.append(highScores[i])
                i += 1
            }
            defaults.set(newArray, forKey: "HighScores")
            
            highScores = newArray
            
            highScore = highScores[0]
        }
        print("\(highScores) \(place)")
        
        return place
    }

    
    func displayStatus(status : String, dismiss : Bool = true){
        
        lblStatus.isHidden = false
        
        self.view.bringSubviewToFront(lblStatus)
        
        lblStatus.transform = CGAffineTransform.init(scaleX:0.5, y:0.5)
        self.lblStatus.text = status
        
        UIView.animate(withDuration:1, animations: {
            self.lblStatus.transform = CGAffineTransform.init(scaleX:1.5, y:1.5)
            }, completion: { (i : Bool) in
                if (dismiss){self.lblStatus.isHidden = true}
        })
    }
    
    func addScore(_ scoreAdd : Int, _ energyAdd : Double, _ display : Bool = false){
        
        if (scoreAdd == 0) {return}
        
        score  += scoreAdd
        energy += energyAdd
        
        if (!display) {return}
        
        switch scoreAdd {
        case scoreAdd where scoreAdd < 30:
            displayStatus(status: "Nice:  +\(scoreAdd)", dismiss: true)
        case scoreAdd where scoreAdd < 60:
            displayStatus(status: "Great:  +\(scoreAdd)", dismiss: true)
        case scoreAdd where scoreAdd < 110:
            displayStatus(status: "Amazing:  +\(scoreAdd)", dismiss: true)
        case scoreAdd where scoreAdd < 160:
            displayStatus(status: "Incredible:  +\(scoreAdd)", dismiss: true)
        case scoreAdd where scoreAdd < 230:
            displayStatus(status: "Genius:  +\(scoreAdd)", dismiss: true)
        case scoreAdd where scoreAdd < 300:
            displayStatus(status:"Unstoppable:  +\(scoreAdd)", dismiss: true)
            ipod.play("unstoppable", "mp3")
        case scoreAdd where scoreAdd < 400:
            displayStatus(status:"Masterpiece:  +\(scoreAdd)", dismiss: true)
            ipod.play("masterpiece")
        case scoreAdd where scoreAdd < 600:
            displayStatus(status:"Legandary:  +\(scoreAdd)", dismiss: true)
            ipod.play("Legendary", "mp3")
        default:
            displayStatus(status:"Godlike:  +\(scoreAdd)", dismiss: true)
            ipod.play("godlike", "mp3")
        }
        lblScore.text  = "Score:  \(score)"
        lblEnergy.text = "Energy: \((Int(energy)))"
    }
    
    
    func addEnergy(energyAdd : Double){
        
        if (energyAdd == 0) {return}
        
        energy += energyAdd
        lblEnergy.text = "Energy: \((Int(energy)))"
    }
    
    
    func formatButtons(){
        
        backspaceButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        
        backspaceButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        backspaceButton.layer.cornerRadius = 3.0;
        backspaceButton.layer.borderWidth = 0.0; //was 2.0
        backspaceButton.layer.borderColor = UIColor.white.cgColor
        
        backspaceButton.setImage(UIImage(named: "Backspace"), for: UIControl.State.normal)
        backspaceButton.contentEdgeInsets = UIEdgeInsets.init(top:5, left:0, bottom:5, right:15)
        
        
        playButton.setImage(UIImage(named: "Submit"), for: UIControl.State.normal)
        playButton.setTitleColor(UIColor.clear, for: UIControl.State.normal)
        playButton.contentEdgeInsets = UIEdgeInsets(top:5, left:15, bottom:5, right:0)
        playButton.layer.cornerRadius = 3.0;
        playButton.layer.borderWidth = 0.0;
        //playButton.layer.borderColor = UIColor.whiteColor().CGColor
        playButton.layer.shadowColor = UIColor.clear.cgColor
        //playButton.layer.shadowOpacity = 1.0
        //playButton.layer.shadowRadius = 1.0
        //playButton.layer.shadowOffset = CGSizeMake(0, 3);
        playButton.clipsToBounds = true
        
        //pause button
        lblPause.setImage(UIImage(named: "Pause"), for: .normal)
        //lblPause.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        lblPause.contentEdgeInsets = UIEdgeInsets.init(top:10, left:10, bottom:10, right:10)
        //lblPause.layer.borderWidth = 1
        //lblPause.layer.borderColor = UIColor.redColor().CGColor
     }
    
    
    func getHighScores() -> [Int]{return highScores}
    
    //func setHighScores(hs : [Int]){highScores = hs}
    
    func power(_ num : Double) -> Double {return pow(num, EXPONENT)}

    
    func activateSpawner(button: LetterView){
        ipod.play("BC")
        let frame = button.frame
        specialClock = DUR_SPAWNER
        for _ in freeLetters.count..<SPAWNER_CHARS{
            addFreeLetter(x:frame.midX, y: frame.midY)
        }
     
        UIView.animate(withDuration:0.5, animations: {
    
            button.addEmitter()
            button.transform = CGAffineTransform(scaleX:0.1, y:0.1)
            button.backgroundColor = UIColor.blue
            }, completion: { (i : Bool) in
                button.removeFromSuperview()
        })
    }
    
    
    func sonicBoom(button: LetterView){
        
        var toAdd = 0
    
        for snow in snowFlakes {
            snow.isHidden = true
        }
        snowFlakes.removeAll()
        
        effects.sunshine()
        ipod.shutUp(file:"forSnow", type: "mp3")
        
        ipod.play("bomb2")
        
        UIView.animate(withDuration:0.3, animations: {
            
            button.addEmitter(birthRate:5)
            button.transform = CGAffineTransform.init(scaleX:200, y:200)
            //button.removeFromSuperview()
            
            for letter in self.freeLetters{
                letter.addEmitter()
                letter.transform = CGAffineTransform.init(scaleX:200, y:200)
            }
            //
        }, completion: { (i : Bool) in
            button.removeFromSuperview()
            let lettersToSpawn = ((self.specialClock > 0) ?  self.SPAWNER_CHARS : self.NUM_CHARS)
            
            for _ in 0..<lettersToSpawn{
                self.addFreeLetter()
            }
        })

        for letter in self.freeLetters{
            toAdd += letter.letterValue
            
            letter.isHidden = true
            
            letter.removeFromSuperview()
            freeLetters.removeAll()
        }
        
        addScore(toAdd, Double(toAdd), true)
    }
    
    func paintBrush(button: LetterView){

        ipod.play("paint")
        
        // determine color
        
        var color : CGColor!
        if (button.multiplier == 3){
            color = UIColor.red.cgColor
        }
        else {
            color = UIColor.yellow.cgColor
        }
        
        let glayer = CAGradientLayer()
        let dlayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        
        dlayer.frame = self.view.bounds
        dlayer.strokeColor = color
        dlayer.fillColor = nil
        dlayer.lineWidth = 3
        dlayer.lineJoin = CAShapeLayerLineJoin.round
        dlayer.lineCap = CAShapeLayerLineCap.round
       
        glayer.frame = self.view.bounds
        glayer.colors = [UIColor.black.cgColor, color as Any, UIColor.black.cgColor]
        glayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        glayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let cent : Double = Double(button.center.x / self.view.frame.width)
        glayer.locations = [NSNumber(value: cent - 0.1), NSNumber(value: cent) , NSNumber(value: cent + 0.1)]
        UIView.animate(withDuration:0.2, animations: {
            
            path.move(to:button.center)

            for letter in self.freeLetters{
                
                if (letter.hasMultiplier() && letter.multiplier <= button.multiplier){
                    letter.updateMultiplier(button.multiplier)
                    path.addLine(to:letter.center)
                }
            }
            dlayer.path = path.cgPath

            button.alpha = 0.0
          
            self.view.layer.insertSublayer(glayer, at: 0)
            self.view.layer.addSublayer(dlayer)
            
            let pathAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 0.1
            pathAnimation.fromValue = 0.0
            pathAnimation.toValue = 1.0
            dlayer.add(pathAnimation, forKey: "strokeEnd")
            //
            
            }, completion: { (i : Bool) in
                button.removeFromSuperview()
                glayer.removeFromSuperlayer()
                dlayer.removeFromSuperlayer()
                
                self.addFreeLetter()
        })
    }
    
    func letterChooser(button: LetterView){
        
        gameStateBeforePause = gameState
        gameState = GameState.GamePausedForQuestionMark
        
        ipod.play("questSound")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier:"LetterChooserController") as! LetterChooserController
        
        vc.mainController = self
        
        vc.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        questionMark = button
        
        //self.presentViewController(vc, animated: true, completion: nil)

        vc.view.frame = CGRect(x: 30, y: 60, width: self.view.frame.width - 60, height: 405)
        
        vc.view.transform = CGAffineTransform(scaleX:0.2, y:0.2)
        self.view.alpha = 0.1
        
        vc.view.layer.borderWidth = 1
        vc.view.layer.borderColor = UIColor.white.cgColor
        vc.view.layer.cornerRadius = 60
            
        self.addChild(vc)
        
        self.view.addSubview(vc.view)
        
        UIView.animate(withDuration:0.5, animations: {
            vc.view.transform = CGAffineTransform.identity
            self.view.alpha = 1
        })
    }
    
    
    func snowFlake (button : LetterView){
        
        self.addFreeLetter()
        snowFlakes.append(button)
        
        UIView.animate(withDuration:6.8, animations: {
            
            self.effects.LetItSnow()
            button.alpha = 0.1
          
            button.transform = CGAffineTransform(scaleX:0.1, y:0.1).rotated(by: CGFloat(2 * Double.pi - 0.01))
            
        }, completion: { (i : Bool) in
            button.removeFromSuperview()
            self.snowFlakes = self.snowFlakes.filter({ $0 != button })
            
            if (self.snowFlakes.count == 0){
                self.effects.sunshine()
            }
        })
        ipod.playFromStart("forSnow", "mp3")
    }
    

    
    func goldCoin (button : LetterView){
        
        self.addFreeLetter()
        ipod.play("ping")
        score  += COIN_BONUS
        energy += Double(COIN_BONUS)
        
        UIView.animate(withDuration:0.5,animations: {
            button.transform  =  CGAffineTransform(scaleX:0.2, y:0.2)
         
            self.view.backgroundColor = UIColor(red: 255.0/255, green: 223.0/255, blue: 0.0/255, alpha: 1.0)
            
            //UIColor.orangeColor()
        
        }, completion: {(i: Bool) in
            
            self.view.backgroundColor = UIColor.black
            button.removeFromSuperview()
            
            self.displayStatus(status: "Nice Catch:  +\(self.COIN_BONUS)", dismiss: true)
            
            self.lblScore.text  = "Score:  \(self.score)"
            self.lblEnergy.text = "Energy: \((Int(self.energy)))"
        
            //self.ipod.play("coindrop")
        })
    }
    
    @objc
    func homeButtonPress(_ notification : NSNotification){
        if gameState == GameState.GameStarted {pausePressed(lblPause)}
    }
    
    func adjustVolumes(){
        
        ipod.setVolume(file:"forDiscardLetters", type: "mp3", vol : 0.5)
        ipod.setVolume(file:"pause", type: "mp3", vol: 0.5)
        ipod.setVolume(file:"questSound", vol: 0.6)
        ipod.setVolume(file:"dramatic", type: "mp3", vol: 0.7)
    }
    
    func clearHighScores() {defaults.removeObject(forKey: "HighScores")}
    
    func displayBonus(){

        var str = ""
        
        let mult = wordView.multiplier()
        if (mult > 1) {str = "Mult: x\(mult)   "}
        
        let bonus = wordView.bonus()
        if (bonus > 0){str += "Bonus: +\(bonus)"}
        
        UIView.animate(withDuration:0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseInOut, animations: {
        
        if (str.count > 0){
            self.lblEnergyAdd.isHidden = false
            self.lblEnergyAdd.text = str
        }
        else {self.lblEnergyAdd.isHidden = true}
        },completion: nil)
    }
}

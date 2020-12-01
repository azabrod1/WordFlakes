//
//  MenuController.swift
//  Word Flakes
//
// 

import UIKit

class MenuController: UIViewController {

    // MARK: controls
    
    @IBOutlet weak var resumeButton: UIButton!
    
    @IBOutlet weak var restartButton: UIButton!
    
    @IBOutlet weak var InstructionsButton: UIButton!
    
    @IBOutlet weak var highScoreButton: UIButton!
    
    
    // MARK: properties
    
    var mainController : MainController!
    
    // MARK: control actions
    
 
    @IBAction func resumeTouchedDown(_ sender: UIButton) {
        EffectsController.animateButtonPress(sender)
    }
    
    @IBAction func restartTouchedDown(_ sender: UIButton) {
        EffectsController.animateButtonPress(sender)
    }
    
    @IBAction func instructionsTouchedDown(_ sender: UIButton) {
        EffectsController.animateButtonPress(sender)
    }
 
    @IBAction func highScoreTouchedDown(_ sender: UIButton) {
        EffectsController.animateButtonPress(sender)
    }

    
    @IBAction func HighScoreButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier:"High Score Controller") as! HighScoreController
        
        vc.menuController = self
        
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        EffectsController.easySound(m:mainController)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func restartPressed(_ sender: UIButton) {
        
        self.dismiss(animated:true, completion: {});
        
        let ipod  = BoomBox()
        ipod.shutUp(file:"dramatic", type: "mp3")
        ipod.shutUp(file:"forSnow", type: "mp3")
        
        EffectsController.easySound(m:mainController)
        
        mainController.run()
    
    }
    
    @IBAction func resumePressed(_ sender: UIButton){
        
        EffectsController.easySound(m:mainController)
        
        self.dismiss(animated:true, completion: {});
        mainController.ipod.resumeAll()
        mainController.gameState = mainController.gameStateBeforePause
    }
    
    
    @IBAction func instructionsPressed(_ sender: UIButton) {
        
        EffectsController.easySound(m:mainController)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier:"HelpController") as! HelpController
        
        vc.menuController = self
        
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        self.present(vc, animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        get {return true}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        EffectsController.formatButton(b:resumeButton)
        EffectsController.formatButton(b:restartButton)
        EffectsController.formatButton(b:InstructionsButton)
        EffectsController.formatButton(b:highScoreButton)
        
        if (mainController.gameStateBeforePause == MainController.GameState.GameStarted){
            //resumeButton.enabled = true
            restartButton.setTitle("Restart", for: UIControl.State())
            //resumeButton.alpha = 1.0
       }
        else {
            //resumeButton.enabled = false
            restartButton.setTitle("Start", for: UIControl.State())
            //resumeButton.alpha = 0.5
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

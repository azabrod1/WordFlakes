//
//  HighScoreController.swift
//  Word Flakes
//

import UIKit

class HighScoreController: UIViewController {
    
    var menuController : MenuController!
    
    var highScores: [Int]!

    @IBOutlet weak var menuReturn: UIButton!
    @IBOutlet weak var scoresText: UITextView!

    //@IBOutlet weak var highScoreView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        highScores = menuController.mainController.getHighScores()
                
        var toDisplay : String = ""
        
        
        if highScores.isEmpty{
            toDisplay = "You have no High Scores! That means you are either really bad...or should play more!"
        }
        else{
                toDisplay += "    \(1) .     \(highScores[0])\n" //For better alignment
            for i in 1..<highScores.count{
                toDisplay += "    \(i+1) .    \(highScores[i])\n"

            }
        }
        
        scoresText.text = toDisplay
        scoresText.isHidden = false
        scoresText.isEditable = false
        scoresText.allowsEditingTextAttributes = false
            
            scoresText.font = UIFont(name: "Noteworthy-Bold" , size: 19)
        scoresText.textColor = UIColor.white
            
        EffectsController.formatButton(b: menuReturn, orange: true)
        
        menuReturn.frame = CGRect(x:menuReturn.frame.midX, y:menuReturn.frame.midY, width: 137, height: 38)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
    override func viewDidLayoutSubviews() {
        scoresText.setContentOffset(CGPoint.zero, animated: false)
    }
    
    
    @IBAction func menuReturnPressed(_ sender: UIButton) {
        
        EffectsController.easySound(m: menuController.mainController)
        
        self.dismiss(animated: true, completion: {})
    }

 
    @IBAction func menuReturnTouchedDown(_ sender: UIButton) {
        EffectsController.animateButtonPress(sender)
    }
 }

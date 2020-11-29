//
//  LetterChooserController.swift
//  Word Flakes
//

import UIKit

class LetterChooserController: UIViewController {
    
    var mainController : MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var allLetters = Array(65...90).map {String(UnicodeScalar($0))}
        
        var letter : LetterView!
        
        var x : CGFloat = 0.0
        
        var y : CGFloat = 0.0
        
        let multiplier = self.mainController.questionMark.multiplier

        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        
        for i in 0...25 {
            
            x = self.view.center.x - 86 + 44 * CGFloat(i % 4) - 30
            
            y = 55 + 50 * CGFloat(i / 4)
            
            if (i/4 == 6){
                x += 44
            }
            
            
            letter = LetterView(boardFrame: self.view.frame, char: allLetters[i])
            
            letter.updateCoordinates(x: CGFloat(x), y: CGFloat(y), speed: 1)
            
            letter.decorate(letter: letter.letter, multiplier: multiplier, value: String(letter.letterValue))

            letter.addTarget(self, action: #selector(EffectsController.animateButtonPress(_:)),
                             for: UIControl.Event.touchUpInside)
            
            letter.addTarget(self, action: #selector(LetterChooserController.letterClicked(_:)),
                             for: .touchDown)
        
            self.view.addSubview(letter)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {return true}
    }
    
    @objc
    func letterClicked(_ button : LetterView){
        
        EffectsController.animateButtonPress(button)
        
        self.mainController.gameState = self.mainController.gameStateBeforePause
        
        self.mainController.questionMark.updateLetter(char: button.letter)
        
        self.mainController.letterClicked(self.mainController.questionMark)
        
        UIView.animate (withDuration: 0.5, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            self.view.alpha = 0.1
        
            }, completion: { (b : Bool) in
        
                self.view.removeFromSuperview()
                self.removeFromParent()
        })
    }

    
    
    

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
}




}

//
//  BoardView.swift
//  Word Flakes
//
//  Created by Tatyana kudryavtseva on 23/07/16.
//  Copyright © 2016 Organized Chaos. All rights reserved.
//

import UIKit

class BoardView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var backgroundImage = UIImageView()
    
    var letter : LetterView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder : aDecoder)
        
        
        
        backgroundImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        
        backgroundImage.image = UIImage(named: "two_owl")
        
        
        backgroundImage.layer.borderColor = UIColor.brownColor().CGColor
        backgroundImage.layer.borderWidth = 2
        //backgroundImage.backgroundColor = UIColor.redColor()
        
        addSubview(backgroundImage)
        
        sendSubviewToBack(backgroundImage)
        
        //bringSubviewToFront(backgroundImage)
        
        
        
     
        
        //let lbl = LetterView(aDecoder)
        letter = LetterView(x: 50, y: 50, char: "M")
        
        
        print(letter.tileButton.allTargets())
        
        letter.tileButton.addTarget(self, action: #selector(BoardView.letterClicked(_:)),
                                    forControlEvents: .TouchDown)
        
        print(letter.tileButton.allTargets())
        
        addSubview(letter)
        bringSubviewToFront(letter)
        letter.tileButton.enabled = true 
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BoardView.labelClicked(_:)))
        //tapGesture.setValue(letter.letter, forKey: "Letter")
        
        //letter.addGestureRecognizer(tapGesture)
        //self.addGestureRecognizer(tapGesture)
        
        letter.rotate(30)
        //letter.scale(0.5, dy: 0.75)
        
        
        
        
        
    }
    
    func letterClicked(button : UIButton){
        print("Click ")// + String(sender.valueForKey("Letter")))
    }
    

}

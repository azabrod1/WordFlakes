//
//  WordView.swift
//  Word Flakes
//
import UIKit

class WordView: UIView {
    //var playButton : UIButton?
    //var label = UILabel()
    
    let lengthBonus = [0, 0, 0, 0, 0, 5, 30, 75, 125, 225, 350, 500, 750, 1500, 2000, 5000, 7500, 10000]
    
    var maxDisplayLength = 8 // number of characters to display
    
    var tileRack = [LetterView]()
    private var strWord = ""
    var dictionary = Set<String>()
    
    required init? (coder aDecoder :NSCoder){
        super.init(coder: aDecoder)
        _ = loadDictionary()
        
    }
    
    
    func submitWord() -> Int{
        
        var rackScore  = 0
        var multiplier = 1
        var temp : [LetterView] = []
        
        
        if dictionary.contains(strWord) && strWord.count > 3 {
            
            for letter in self.tileRack{
                rackScore += letter.letterValue
                multiplier *= letter.multiplier
                temp += [letter]
                
            }
            rackScore *= multiplier
            rackScore += lengthBonus[strWord.count]
            self.tileRack.removeAll() // destroy it before the animation, so can add letters while anim runs
            self.strWord = ""
            
            UIView.animate(withDuration: 3, animations: {
                // animation starts
                for letter in temp {
                    
                    letter.addEmitter(birthRate: 3)
                    letter.frame = letter.frame.offsetBy(dx: (self.superview?.frame.width)!/2,
                        dy: (-(self.superview?.frame.height)!-2*letter.frame.height))
                    letter.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    letter.setTitle("", for: UIControl.State.normal)
                }
                
                // animation ends
                
               }, completion: {(i : Bool) in
                    
                    // completion block
                    for letter in temp{
                        letter.removeFromSuperview()
                    }
                
            }) // end of completion block
        }
            
            
        else{
            //Invalid Word
            
            for l in self.tileRack{
                let animation = CABasicAnimation(keyPath: "position")
                animation.duration = 0.07
                animation.repeatCount = 4
                animation.autoreverses = true
                
                animation.fromValue = NSValue(cgPoint: CGPoint(x: l.center.x, y: l.center.y - 5))
                animation.toValue = NSValue(cgPoint: CGPoint(x: l.center.x, y: l.center.y + 5))
                l.layer.add(animation, forKey: "position")
            }
            
            
        }
        
        return rackScore
    }
    
    
    func linesFromResource(fileName: String) throws -> [String] {
        
        guard let path = Bundle.main.path (forResource: fileName, ofType: nil) else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: [ NSFilePathErrorKey : fileName ])
        }
        let content = try String(contentsOfFile: path)
        return content.components(separatedBy: "\n")
    }
    
    
    func loadDictionary() -> Bool{
        
        let fileLocation  = Bundle.main.path(forResource: "wordList", ofType: "txt")!
        let text : String
        do{
            text = try String(contentsOfFile: fileLocation)
        }
        catch{
            text = ""
            return false
        }
        dictionary = Set(text.components(separatedBy: "\n"))
        return true
        
    }
    
    func addLetter(button : LetterView){
        
        var x : CGFloat!
        let count = self.tileRack.count
        let w : CGFloat!
        
        // width of a letter tile in the word (if count == 0, does not matter)
        if count > 0 {
            w = tileRack.last!.frame.width
        } else {
            w = 0
        }
        
        let t = min(maxDisplayLength - 1, count)
        // position of the letter (will be adjusted for a potential race condition later)
        x = 15 + (w + 3) * CGFloat(t)
        
        button.transform = CGAffineTransform(translationX: 2, y: 2)
        let newFrame = self.superview?.convert(button.frame, to: self)
        
        button.removeFromSuperview()
        button.frame = newFrame!
        
        self.addSubview(button)
        self.bringSubviewToFront(button)
        
        self.tileRack.append(button)
        self.strWord += button.getChars()
        
        
        UIView.animate(withDuration: 1, animations: {
            
            
            if (count >= self.maxDisplayLength){
                
                for l in self.tileRack {
                
                    if (l != button){
                        l.frame = l.frame.offsetBy(dx: -(l.frame.width  + 3.0), dy: 0)
                    }
                }
            }
            
            button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            if (count >= self.maxDisplayLength - 1 && count < self.tileRack.count - 1){
                
                // by the time this letter lands, another one is selected, so the original letter needs to be shifted
                
                let adj = (button.frame.width  + 3.0) * CGFloat(self.tileRack.count - count - 1)
                
                x = x - adj
                
            }
            button.frame = CGRect(x: x, y: 0, width: button.frame.width , height: button.frame.height )
            button.layer.shadowOpacity = 0.3
 
            
            // end of animation
            
            } )
    
    }
    
    func removeLastLetter() -> Bool{
        
        
        if (tileRack.count == 0){return false}
        
        
        let letter = tileRack.removeLast() as LetterView
        
        
        UIView.animate( withDuration: 1, animations: {
            
            // animation starts
            letter.frame = letter.frame.offsetBy(dx: 0, dy: 50)
            
            letter.backgroundColor = UIColor.clear
            
            if (self.tileRack.count >= self.maxDisplayLength){
                for l in self.tileRack {
                    l.frame = l.frame.offsetBy(dx: +(l.frame.width  + 3.0), dy: 0)
                }
            }
            
            //animation ends
            }, completion: {(i : Bool) in
                // after animation
                letter.removeFromSuperview()
                letter.isHidden = true
          }) // end of completion
        
        
        self.strWord = ""
        
        for letter in self.tileRack{
            self.strWord += letter.getChars()
            
        }
        
        return true
        
    }
    
    func removeAll() -> Bool{
        
        if (tileRack.count == 0){
            return false
        }
        
        let tempRack = self.tileRack //Create Shallow copy of tileRack so can clear tileRack
        self.tileRack.removeAll()
        self.strWord = ""
        
        UIView.animate(withDuration: 1, animations: {
            
            for letter in tempRack{
               
            // animation starts
                letter.frame = letter.frame.offsetBy(dx: 0, dy: 50)
                letter.backgroundColor = UIColor.clear
            }
            
            //animation ends
            }, completion: {(i : Bool) in
                // after animation
                for letter in tempRack{
                    letter.removeFromSuperview()
                    letter.isHidden = true
                }
                
        }) // end of completion
        
    
        return true
    }
    
    
    func isWord() -> Bool {
        return (dictionary.contains(strWord) && strWord.count > 2)
    }
    
    func count() -> Int {return tileRack.count}
    
    func multiplier() ->Int {
        
      //  print( (UIScreen.main.bounds.width * UIScreen.main.bounds.width + UIScreen.main.bounds.height * UIScreen.main.bounds.height).squareRoot() );
        
        var mult =  1
        
        for letter in self.tileRack{
            if( letter.multiplier > 1){
                mult *= letter.multiplier;
            }
        }
        return mult
        
    }
    
    func bonus() -> Int{return lengthBonus[min(strWord.count, lengthBonus.count-1)]}
    
    
}

    


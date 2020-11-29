//
//  LetterView.swift
//  Word Flakes
//


import UIKit

class LetterView: UIButton {
    
    
    
    static let TILE_SIDE : CGFloat = 40.0
    static let TILE_OFFSET : CGFloat = 3.0
    static let TILE_SIDE_WITH_OFFSET : CGFloat = TILE_SIDE + TILE_OFFSET
    
    // colors
    
    //let borderBlueColor = UIColor(red: 26.0/255.0, green: 8.0/255.0, blue: 194.0/255.0, alpha: 1.0)
    //let borderYellowColor = UIColor(red: 230.0/255.0, green: 152.0/255.0, blue: 50.0/255.0, alpha: 1.0)
    //let borderRedColor = UIColor(red: 171.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    //let borderPurpleColor = UIColor(red: 166.0/255.0, green: 4.0/255.0, blue: 181.0/255.0, alpha: 1.0)
    

   
    var multiplier = 1
    var isSpecial = false
    
    
    
    // properties
    let initialVelocity = 4.5
    var velocity : (x: Double, y: Double)!
    var age = 0 as Int
    
    var maximumAge : Int!
    
    var rotationAngle :Double!
    var angularVelocity : Double!
    
    var letter : String!
    var letterValue : Int!
    

    init(boardFrame : CGRect, char : String = "") {
    
        
        super.init(frame: CGRect(x: 0, y: 0, width: LetterView.TILE_SIDE, height: LetterView.TILE_SIDE))
        
        
        self.isUserInteractionEnabled = true
        
        self.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center

        self.backgroundColor = UIColor.white
        
        
        self.layer.cornerRadius = 0.2 * self.frame.width
        self.clipsToBounds = true
        
        self.layer.borderWidth = 2
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowRadius = 15.0
       
        self.layer.masksToBounds = false
        
        let path = UIBezierPath(rect: self.bounds)
        self.layer.shadowPath = path.cgPath
        
        if (char == ""){
            setRandom(boardFrame: boardFrame)
        }
        else {
            letter = char
        }
        
        letterValue = getCharValue(char: letter)
        
        setPhysics(boardFrame: boardFrame)
        
        if !isSpecial{
            
            decorate(letter: letter, multiplier: multiplier, value: String(letterValue))
            
        }
            
        else{
            decorateSpecial(identifier: letter)
            
        }
        
        setPosition(boardFrame: boardFrame)
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

    
    func rotate(){
        
        self.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle * Double.pi/180.0))
        
        
        /*if (self.letter == "COIN"){
            var t  = CATransform3DMakeRotation(CGFloat(CGFloat(rotationAngle * M_PI_2/90.0)), 0.2, 0.3, 0.2)
            
            t.m34 = -1.0/500
            
            //self.layer.anchorPoint = CGPoint(x:1, y:1)
            self.layer.transform = t
        } */

    }
    
    func scale(dx: Double, dy: Double){
        self.transform = CGAffineTransform(scaleX: CGFloat(dx), y: CGFloat(dy))
    }
    
    func getCharValue(char : String) -> Int{
        
        switch char {
        case char where "EAIORTLS".contains(char):
            return 1
        case char where "DUN".contains(char):
            return 2
        case char where "BCMPG".contains(char):
            return 3
        case char where "FHWY".contains(char):
            return 4
        case char where "V".contains(char):
            return 7
        case char where "K".contains(char):
            return 9
        case char where "JX".contains(char):
            return 10
        case char where "Z".contains(char):
            return 15
        case char where "Q".contains(char):
            return 15
        case char where char == "QU":
            return 7
        case char where char == "ING":
            return 0
        case char where char == "ED":
            return 3
        case char where char == "ER":
            return 2
        case char where char == "CK":
            return 6
            
            
        default:
            return 0
        }
        
        
    }
    
    func getChars() -> String {
        return letter;
    }
    
    
    
   // override func intrinsicContentSize() -> CGSize {
   //     return CGSize(width: 240, height: 44)
   // }
    
    
    func applyCurvedShadow(view: UIView) {
        let size = view.bounds.size
        let width = size.width
        let height = size.height
        let depth = CGFloat(11.0)
        let lessDepth = 0.8 * depth
        let curvyness = CGFloat(5)
        let radius = CGFloat(1)
        
        let path = UIBezierPath()
        
        // top left
        path.move(to: CGPoint(x: radius, y: height))
        
        // top right
        path.addLine( to: CGPoint(x: width - 2*radius, y: height))
        
        // bottom right + a little extra
        path.addLine(to: CGPoint(x: width - 2*radius, y: height + depth))
        
        // path to bottom left via curve
        path.addCurve( to: CGPoint(x: radius, y: height + depth),
                             controlPoint1: CGPoint(x: width - curvyness, y: height + lessDepth - curvyness),
                             controlPoint2: CGPoint(x: curvyness, y: height + lessDepth - curvyness))
        
        let layer = view.layer
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: -3)
    }
    
    func setRandom( boardFrame : CGRect){
        
        // randomize seed - REMOVE IF WANT REPEATABLE random values
        
        //srand(UInt32(time(nil)))
    
        // select random letter
    
        var letterFrequency = [90, 20, 25, 40, 120, 20, 26, 20, 90, 10, 10, 40, 20, 60, 80, 20, 8, 60, 50, 60, 40, 20, 20, 10, 20, 10 /* Z */, 5, 10 , 5, 2 , 3, 9 /* ? */, 5, 9, 5, 7, 3]
        
        var allLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "QU", "ED", "ING", "CK", "ER", "?", "*", "BOOM", "SNOW", "COIN", "PAINT"]

        for j in (0..<(letterFrequency.count-1)){
            letterFrequency[j+1] += letterFrequency[j]
        }
        
        let r = Int(arc4random_uniform(UInt32(letterFrequency[letterFrequency.count-1] + 1)))

        
        var i = 0
        while (letterFrequency[i] < r){
            i += 1
        }
               

        letter = allLetters[i]
        
        if (letter == "*") || (letter == "BOOM" || letter == "?" || letter == "SNOW" || letter == "COIN" || letter == "PAINT"){
            self.isSpecial = true
            return
        }
        
        setWordMult()
        
    
    }
    
    
    func setPhysics( boardFrame : CGRect){
        
        // set random velocity
        
        // set random velocity angle and velocity component
        
        let initialVelocityAngle = drand48() * 360
        
        velocity = (initialVelocity * cos(initialVelocityAngle), initialVelocity * sin (initialVelocityAngle))
        
        // set initial rotation angle
        
        rotationAngle = drand48() * 360
        
        // set angular velocity
        
        angularVelocity = (drand48() > 0.5) ? 1 : -1
        
        // how many times it bumps against the wall
        maximumAge = 1 + Int(arc4random_uniform(3))
    
        
    }
    
    
    //Function for decorating normal letter Tiles
    func decorate( letter: String!, multiplier: Int, value: String = ""){
        
        
        let fontCol = [EffectsController.DARK_BLUE_COLOR,
                       UIColor(red: CGFloat(1.0), green: CGFloat(0.2745), blue: CGFloat(0), alpha: CGFloat(1.0)),
                       UIColor.white,
                       UIColor.clear,
                       UIColor.white]
        
        let col = [UIColor.white, UIColor(red: 0.953, green: 0.953, blue: 0.647, alpha: 1.0), UIColor(red: 0.992, green: 0.329, blue: 0.243, alpha: 1.0) , UIColor(red: 0.7686, green: 0.540, blue: 0.8117, alpha: 1.0),  UIColor(red: 0.7686, green: 0.540, blue: 0.8117, alpha: 1.0)]
        
        let borderCol = [UIColor(red: CGFloat(0.01), green: CGFloat(0.02), blue: CGFloat(0.627), alpha: CGFloat(1.0)),
                         UIColor(red: CGFloat(0.902), green: CGFloat(152.0/255.0), blue: CGFloat(0.2157), alpha: CGFloat(1.0)),
                         UIColor(red: CGFloat(150.0/255.0), green: CGFloat(0.0/255.0), blue: CGFloat(0.0/255.0), alpha: CGFloat(1.0)),
                         UIColor.clear,
                         UIColor(red: CGFloat(110/255.0), green: CGFloat(0.02), blue: CGFloat(170/255.0), alpha: CGFloat(1.0))]
        
        let shadowCol = [UIColor.white,
                         UIColor(red: CGFloat(0.98), green: CGFloat(1.0), blue: CGFloat(0.6655), alpha: CGFloat(1.0)),
                         UIColor(red: CGFloat(1), green: CGFloat(0.333), blue:CGFloat(0.333), alpha: CGFloat(1.0)),
                         UIColor.clear,
                         UIColor(red: CGFloat(0.7686), green: CGFloat(0.540), blue: CGFloat(0.8117), alpha: CGFloat(1.0))]
        
        let fontSize = [CGFloat(23), CGFloat(23),CGFloat(17), CGFloat(15)] //Font size depends on how many characters the tile has (Usually 1)
        
        
        let attrs1 : [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-Bold", size: fontSize[letter.count])!, NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): fontCol[multiplier-1]]
        
        let attributedText = NSMutableAttributedString(string:letter, attributes: attrs1)
        
        
        
        let attrs2 : [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-Bold", size: 10)!, NSAttributedString.Key(rawValue: NSAttributedString.Key.baselineOffset.rawValue): -5 as AnyObject, NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): fontCol[multiplier-1]]
        
        
        if(value != ""){
            attributedText.append(NSAttributedString(string: value, attributes: attrs2))
        }

        self.backgroundColor = col[multiplier-1]
        self.layer.borderColor = borderCol[multiplier - 1].cgColor
        self.layer.shadowColor = shadowCol[multiplier-1].cgColor
        self.setAttributedTitle(attributedText, for: UIControl.State.normal)
        

    }
    
    func incrementAge() -> Bool{
        age += 1
        return true
    }
    
    func isAged() -> Bool{
        return age >= maximumAge
    }

    
    func setWordMult(){
        // word multiplier
        let r = Int(arc4random_uniform(550))
        
        if (r % 15 == 0){
            multiplier = 2
        }
        else if (r % 33 == 0){
            multiplier = 3
        }
        else if(r == 2){
            multiplier = 5
        }
        
    }
    
    
    
    
    func addEmitter( birthRate : Int = 1, vel: Int = 1){
        
         
         let emitter = CAEmitterLayer()
         emitter.emitterPosition = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
         emitter.emitterSize = self.bounds.size
         emitter.emitterMode = CAEmitterLayerEmitterMode.outline
        
        
        emitter.emitterShape = CAEmitterLayerEmitterShape.rectangle
        
        
         self.layer.addSublayer(emitter)
        
        
        
         let texture:UIImage? = UIImage(named:"Spark")
         //assert(texture != nil, "particle image not found")
         
         //3
         let emitterCell = CAEmitterCell()
         
         //4
        emitterCell.contents = texture!.cgImage
         
         //5
         emitterCell.name = "cell"
         
         //6
         emitterCell.birthRate = 100 * Float(birthRate)
         emitterCell.lifetime = 0.5
         
         //7
         emitterCell.blueRange = 0.33
         //emitterCell.greenRange = 0.33
         // emitterCell.redRange = 0.33
        
          //emitterCell.blueSpeed = -0.33
         emitterCell.greenSpeed = -0.33
         //emitterCell.redSpeed = -0.33
         
         //8
         emitterCell.velocity = CGFloat(100 * vel)
         emitterCell.velocityRange = CGFloat(10 * vel)
        
        //emitterCell.speed = 200
        
         
         //9
         emitterCell.scaleRange = 0.2
         emitterCell.scaleSpeed = -0.1
         emitterCell.scale = 0.1
         emitterCell.yAcceleration = 100 //* (-CGFloat(velocity.y))
         emitterCell.xAcceleration = 0 //100 *  (-CGFloat(velocity.x))
        
         emitterCell.spin = CGFloat(angularVelocity)
        
        
        
        emitterCell.emissionLatitude = -CGFloat(velocity.x)
        emitterCell.emissionLongitude = -CGFloat(velocity.y)
        
         //10
        
        
        emitterCell.emissionRange = CGFloat(2*Double.pi)
         
         //11
         emitter.emitterCells = [emitterCell]
         
         
    }
    
    
    
    func addBallEmitter( birthRate : Int = 1, vel: Int = 1){

        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        emitter.emitterSize = self.bounds.size
        emitter.emitterMode = CAEmitterLayerEmitterMode.outline
        
        
        emitter.emitterShape = CAEmitterLayerEmitterShape.rectangle
        
        
        self.layer.addSublayer(emitter)
        
        let texture:UIImage? = UIImage(named:"Spark")
        //assert(texture != nil, "particle image not found")
        
        //3
        let emitterCell = CAEmitterCell()
        
        //4
        emitterCell.contents = texture!.cgImage
        
        //5
        emitterCell.name = "cell"
        
        //6
        emitterCell.birthRate = 5 * Float(birthRate)
        emitterCell.lifetime = 2
        
        //7
        //emitterCell.blueRange = 0.33
        //emitterCell.greenRange = 0.33
        //emitterCell.redRange = 0.33
        
        //emitterCell.blueSpeed = -0.33
        //emitterCell.greenSpeed = -0.75
      //  emitterCell.redSpeed = -0.75
        emitterCell.color = UIColor.yellow.cgColor
        
        //8
        emitterCell.velocity = CGFloat(20 * vel)
        emitterCell.velocityRange = CGFloat(10 * vel)
        
        //emitterCell.speed = 200
        
        //9
        emitterCell.scaleRange = 0.2
        emitterCell.scaleSpeed = -0.1
        emitterCell.scale = 0.1
        emitterCell.yAcceleration = 0 //* (-CGFloat(velocity.y))
        emitterCell.xAcceleration = 0 //100 *  (-CGFloat(velocity.x))
        
        emitterCell.spin = CGFloat(angularVelocity)
        
        
        
        emitterCell.emissionLatitude = -CGFloat(velocity.x)
        emitterCell.emissionLongitude = -CGFloat(velocity.y)
        
        //10
        
        
        emitterCell.emissionRange = CGFloat(Double.pi * 2)
        
        //11
        emitter.emitterCells = [emitterCell]
        
        
    }
    
    func hasMultiplier() ->Bool {
        return !self.isSpecial || self.letter == "?"
    }
    
    func updateMultiplier(_ mult : Int){
        
        if hasMultiplier(){
           
            self.multiplier = mult
            
            if (self.letter == "?"){
                self.decorate(letter: "?", multiplier: mult)
            }
            else {
                self.decorate(letter: self.letter, multiplier: mult, value: String(self.letterValue))
            }
        }
        
    }
    
    func updateLetter( char : String, value : Int = -1){
        
        self.letter = char
        
        isSpecial = false
        self.setImage(nil, for: UIControl.State.normal)
        self.layer.borderWidth = 2
        self.transform = CGAffineTransform.identity
        self.frame = CGRect(x: self.frame.midX, y: self.frame.midY, width: LetterView.TILE_SIDE, height: LetterView.TILE_SIDE)
        
        if (value != -1){
            self.letterValue = value
        }
        else {
            self.letterValue = getCharValue(char: char)
        }
        
        decorate(letter: letter, multiplier: self.multiplier, value: String(self.letterValue))
        
    }
    
    
    
    func updateCoordinates( x : CGFloat, y : CGFloat, speed : Double){
        
        self.frame = CGRect(x: x, y: y, width: LetterView.TILE_SIDE, height: LetterView.TILE_SIDE)
        
        velocity.x *= speed
        velocity.y *= speed
    }
    
    
    func decorateSpecial( identifier: String! ){
        if identifier == "*"{
            self.backgroundColor = UIColor.clear
            
            //self.layer.borderColor = UIColor.cyanColor().CGColor
           // self.layer.shadowColor = UIColor.blueColor().CGColor
            self.layer.borderWidth = 0
            let image = UIImage(named: "BriefCase") as UIImage?
            
            self.setImage(image, for: UIControl.State.normal)
            self.transform = CGAffineTransform(scaleX: 0.67, y: 0.83)
            
        }
        else if identifier == "BOOM"{
            
                self.backgroundColor = UIColor.clear
                
                //self.layer.borderColor = UIColor.cyanColor().CGColor
                // self.layer.shadowColor = UIColor.blueColor().CGColor
                self.layer.borderWidth = 0
                let image = UIImage(named: "bomb2") as UIImage?
                
            self.setImage(image, for: UIControl.State.normal)
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                addBombEmitter()

                
        }
        else if identifier == "?"{
            
            setWordMult()
            decorate(letter: "?", multiplier: multiplier)
            
            
        }
        
        else if identifier == "SNOW"{
            
            self.backgroundColor = UIColor.clear
            
            //self.layer.borderColor = UIColor.cyanColor().CGColor
            // self.layer.shadowColor = UIColor.blueColor().CGColor
            self.layer.borderWidth = 0
            let image = UIImage(named: "snowflake") as UIImage?
            
            self.setImage(image, for: UIControl.State.normal)
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            
        }
        
        else if identifier == "COIN"{
            self.backgroundColor = UIColor.clear
            self.layer.shadowColor = UIColor.clear.cgColor
         
            self.layer.borderWidth = 0

            
            self.setImage(UIImage(named: "goldball"), for: UIControl.State.normal)
            //self.transform = CGAffineTransformMakeScale(1.25, 1.25)
            self.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            
            
            
            //self.transform = CGAffineTransformMakeScale(1.5, 1.5)
           
            self.velocity.x *= 4.5
            self.velocity.y *= 4.5
            self.maximumAge = Int(arc4random_uniform(3))
            self.angularVelocity = 3.5 * self.angularVelocity
            addBallEmitter()
            
        }
        
        else if identifier == "PAINT"{
            self.backgroundColor = UIColor.clear
            self.layer.shadowColor = UIColor.clear.cgColor
            
            self.layer.borderWidth = 0
            
            self.backgroundColor = UIColor.clear
            
            if (arc4random_uniform(10) < 2){
            
                self.multiplier = 3
                self.setImage(UIImage(named: "redPB"), for: UIControl.State.normal)
            
            }
            else {
                self.multiplier = 2
                self.setImage(UIImage(named: "yellowPB"), for: UIControl.State.normal)
            }
            
            //self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
             //self.transform = CGAffineTransformMakeScale(1.5, 1.5)
        }
   }
    
    
    func setPosition( boardFrame : CGRect){
        
        var x, y : CGFloat!
        
        if (arc4random_uniform(2) == 1){
            // veritical
            x = CGFloat(drand48()) * boardFrame.width + boardFrame.minX
            y = (velocity.y > 0) ? boardFrame.minY : boardFrame.maxY
        }
        else{
            y = CGFloat(drand48()) * boardFrame.height + boardFrame.minY
            x = (velocity.x > 0) ? boardFrame.minX : boardFrame.maxX
        }
        self.frame = CGRect(x: x, y: y, width: LetterView.TILE_SIDE, height: LetterView.TILE_SIDE)
        
        
    }
    
    
    func addBombEmitter( birthRate : Int = 1, vel: Int = 1){
        
        
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: self.bounds.size.width*1.01 , y: 0)
        emitter.emitterSize = CGSize(width: 8.0, height: 8.0)
        emitter.emitterMode = CAEmitterLayerEmitterMode.outline
        
        
        emitter.emitterShape = CAEmitterLayerEmitterShape.rectangle
        
        
        self.layer.addSublayer(emitter)
        
        
        
        let texture:UIImage? = UIImage(named:"Spark")
        //assert(texture != nil, "particle image not found")
        
        //3
        let emitterCell = CAEmitterCell()
        
        //4
        emitterCell.contents = texture!.cgImage
        
        //5
        emitterCell.name = "cell"
        
        //6
        emitterCell.birthRate = 150 * Float(birthRate)
        emitterCell.lifetime = 0.108
        
        //7
        emitterCell.blueRange = 0.33
        //emitterCell.greenRange = 0.33
        // emitterCell.redRange = 0.33
        
        //emitterCell.blueSpeed = -0.33
        emitterCell.greenSpeed = -0.33
        //emitterCell.redSpeed = -0.33
        
        //8
        emitterCell.velocity = CGFloat(100 * vel)
        emitterCell.velocityRange = CGFloat(10 * vel)
        
        //emitterCell.speed = 200
        
        
        //9
        emitterCell.scaleRange = 0.2
        emitterCell.scaleSpeed = -0.1
        emitterCell.scale = 0.01
        emitterCell.yAcceleration = 100 //* (-CGFloat(velocity.y))
        emitterCell.xAcceleration = 0 //100 *  (-CGFloat(velocity.x))
        
        emitterCell.spin = CGFloat(angularVelocity)
        
        emitterCell.emissionLatitude = -CGFloat(velocity.x)
        emitterCell.emissionLongitude = -CGFloat(velocity.y)
        
        //10
        
        emitterCell.emissionRange = CGFloat(2*Double.pi)
        
        //11
        emitter.emitterCells = [emitterCell]
    }

}






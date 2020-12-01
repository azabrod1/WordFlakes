//
//  EffectsController.swift
//  Word Flakes
//


import UIKit
import Foundation
import AVFoundation

class EffectsController: UIView {
    
    // MARK: static colors
    static let COLOR_PLATE = [UIColor( red:  0.564 , green: 0.764, blue:0.9519, alpha: 0.7 ) , UIColor( red:  0.564 , green: 0.88235, blue:0.882, alpha: 0.7 ),  UIColor( red:  0.564 , green: 0.8824, blue:0.7059, alpha: 0.7 ), UIColor( red:  0.564 , green: 0.8824, blue:0.4705, alpha: 0.7 ), UIColor( red:  0.733 , green: 0.8824, blue:0.3529, alpha: 0.7 ) , UIColor( red:  0.8824 , green: 0.8824, blue:0.3829, alpha: 0.7 ),  UIColor( red:  0.9019 , green: 0.8078, blue:0.1960, alpha: 0.85 ),  UIColor( red:  0.9019 , green: 0.63137, blue:0.1960, alpha: 0.85 ) , UIColor( red:  0.9019 , green: 0.39215, blue:0.1960, alpha: 0.85 ), UIColor( red:  0.8019 , green: 0.1960, blue:0.25, alpha: 0.85 ) ]
    
    static let LABEL_TEXT_COLOR = UIColor(red: 0.357258, green: 0.740995, blue: 1, alpha: 1)
    static let DARK_BLUE_COLOR = UIColor(red: 0, green: 0, blue: 0.453 , alpha: 1.0)
    static let ORANGE_COLOR = UIColor(red: 195/255, green: 78/255, blue: 22/255 , alpha: 1.0)
    
    // MARK: properties
    
    let cloud = CAEmitterLayer()
    let flake:UIImage? = UIImage(named:"flake2")
    let cloudCell = CAEmitterCell()
    let SNOW_BIRTHRATE = 65
    
    let launcher = CAEmitterLayer()
    let spark:UIImage? = UIImage(named:"Spark")
    let flare = CAEmitterCell()
    let FIREWORK_BIRTHRATE = 1300
    
   
    init(mainView : UIView) {
        super.init(frame:  CGRect(x: 10, y: 10, width: 10, height: 10))
        
        setUpCloud(mainView: mainView)
        setUpFirework(mainView: mainView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func LetItSnow(){
        cloud.setValue(SNOW_BIRTHRATE, forKeyPath: "emitterCells.cell.birthRate")
        
        
    }
    
    func sunshine(){
        cloud.setValue(0, forKeyPath: "emitterCells.cell.birthRate")
        
        
    }
    
    func setUpCloud( mainView : UIView){
        
        cloud.emitterPosition = CGPoint(x: mainView.frame.width/2 , y: -50)
        cloud.emitterSize = CGSize(width: mainView.frame.width, height: 80)
        //cloud.emitterMode = kCAEmitterLayerAdditive
        cloud.emitterMode = CAEmitterLayerEmitterMode.outline
        
        cloud.emitterShape = CAEmitterLayerEmitterShape.rectangle
        
        self.layer.addSublayer(cloud)
        mainView.addSubview(self)
        mainView.sendSubviewToBack( self)
        cloudCell.contents = flake!.cgImage
        
        //5
        cloudCell.name = "cell"
        
        //6
        cloudCell.birthRate = 0
        cloudCell.lifetime = 2
        
        //7
        cloudCell.blueRange = 0.33
        
        cloudCell.greenSpeed = -0.33
        
        //8
        cloudCell.velocity = CGFloat(500)
        
        
        //9
        cloudCell.scaleRange = 0.2
        cloudCell.scaleSpeed = -0.1
        cloudCell.scale = 0.025
        cloudCell.yAcceleration = 100 //* (-CGFloat(velocity.y))
        cloudCell.xAcceleration = 0 //100 *  (-CGFloat(velocity.x))
        
        
        //10
        
        cloudCell.emissionRange = CGFloat(2*Double.pi)
        
        //11
        cloud.emitterCells = [cloudCell]
        
        
    }
    
    
    
    func setUpFirework( mainView : UIView){
        
        launcher.emitterPosition = CGPoint(x: mainView.frame.width/2 , y: -7)
        launcher.emitterSize = CGSize(width: mainView.frame.width, height: 80)
        //launcher.emitterMode = kCAEmitterLayerAdditive
        launcher.emitterMode = CAEmitterLayerEmitterMode.outline
        
        launcher.emitterShape = CAEmitterLayerEmitterShape.rectangle
        
        self.layer.addSublayer(launcher)
        mainView.addSubview(self)
        mainView.sendSubviewToBack(self)
        flare.contents = spark!.cgImage
        
        //5
        flare.name = "cell"
        
        //6
        flare.birthRate = 0
        flare.lifetime = 1.7
        
        //7
        flare.blueRange = 1.0
        flare.redRange = 1.0
        flare.greenRange = 1.0


        
        flare.greenSpeed = -0.25
        
        //8
        flare.velocity = CGFloat(1000)
        
        
        //9
        flare.scaleRange = 0.2
        flare.scaleSpeed = -0.1
        flare.scale = 0.06
        flare.yAcceleration = 100 //* (-CGFloat(velocity.y))
        flare.xAcceleration = 0 //100 *  (-CGFloat(velocity.x))
        
        
        //10
        
        flare.emissionRange = CGFloat(2*Double.pi)
        
        //11
        launcher.emitterCells = [flare]
    }
    
    
    func smallCelebrate(){celebrate(birthRate: 200)}

    
    func celebrate( birthRate : Int? = nil){
        let spawnRate = (birthRate != nil) ? birthRate : FIREWORK_BIRTHRATE
        
        UIView.animate (withDuration: 0.01, animations: {
            self.launcher.setValue(spawnRate, forKeyPath: "emitterCells.cell.birthRate")
            }, completion: { (i : Bool) in
                self.launcher.setValue(0, forKeyPath: "emitterCells.cell.birthRate")
            })
    }
    
    func highScoreCelebrateOn( birthRate : Int? = 30){
        self.launcher.setValue(birthRate, forKeyPath: "emitterCells.cell.birthRate")
        self.launcher.setValue(CGFloat(100), forKeyPath: "emitterCells.cell.velocity")
        self.launcher.setValue(5,             forKeyPath: "emitterCells.cell.lifetime")
    }
 
    
    func highScoreCelebrateOff(){
        self.launcher.setValue(0, forKeyPath: "emitterCells.cell.birthRate")
        self.launcher.setValue(CGFloat(1000), forKeyPath: "emitterCells.cell.velocity")
        self.launcher.setValue(1.7,             forKeyPath: "emitterCells.cell.lifetime")
    }
  
    // MARK: statics
    
    static func easySound(m : MainController) {m.ipod.play("menu_click")}
    
    @objc
    static func animateButtonPress(_ b : UIButton){
  
        UIView.animate( withDuration: 0.1, animations: {
            b.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: {(i : Bool) in
                b.transform = CGAffineTransform.identity
        })
    }
    
    
    static func formatButton(b : UIButton, orange : Bool = false){
        
        //b.backgroundColor = UIColor.whiteColor()
        if (orange){
            b.setTitleColor(UIColor.orange, for: UIControl.State.normal)
            
        } else {
            b.setTitleColor(UIColor(red: 175/255.0, green:175/255.0, blue: 237/255.0, alpha: 1.0), for: UIControl.State.normal)
        }
        b.setTitleColor(UIColor.white, for: UIControl.State.highlighted)
        b.layer.borderWidth = 2
        
        if (orange){
            b.layer.borderColor = (ORANGE_COLOR).cgColor
        } else {
            b.layer.borderColor = UIColor(red: 40/255.0, green:40/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        }
        b.layer.cornerRadius = 10
        b.layer.masksToBounds = true
        
        //gradient color
        let btnGradient = CAGradientLayer()
        btnGradient.frame = b.bounds
        btnGradient.colors =
            [UIColor(red: 102.0/255.0, green:102.0/255.0, blue: 102.0/255.0, alpha: 1.0).cgColor,
             UIColor(red: 20/255, green:20/255, blue: 20/255, alpha: 1).cgColor]
        
        btnGradient.masksToBounds = true
        b.layer.insertSublayer(btnGradient, at: 0)
    }
    
}

//
//  boomBox.swift
//  Word Flakes
//


import Foundation
import AVFoundation


class BoomBox{
    
    static var bb = BoomBox()
    
    //only one instance of BB
    static func ipod() -> BoomBox {return bb}
    
    var sounds = [String : AVAudioPlayer]()
    var paused = [String : AVAudioPlayer]()
    
    func play(_ file:NSString, _ type:NSString = "wav", _ checkIfPlaying:Bool = false){
        do {
            if (sounds[file as String] == nil ) {
                let path = Bundle.main.path(forResource: file as String, ofType: type as String)
                try sounds[file as String] = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: path!) as URL)
            }
            // if it is already playing and the flag set, do nothing
            if checkIfPlaying && sounds[file as String]!.isPlaying {return}
            
            sounds[file as String]?.prepareToPlay()
            sounds[file as String]?.play()
        }
        catch {
            print("Player not available")
        }
    }
    
    
    func playFromStart(_ file:NSString,_ type:NSString = "wav"){
        
        do {
            if (sounds[file as String] == nil ) {
                let path = Bundle.main.path(forResource: file as String, ofType: type as String)
                let url = NSURL(fileURLWithPath: path!)
                try sounds[file as String] = AVAudioPlayer(contentsOf: url as URL)
            }
            if sounds[file as String]!.isPlaying{
                sounds[file as String]?.pause()
                sounds[file as String]?.currentTime = 0
            }
            sounds[file as String]?.prepareToPlay()
            sounds[file as String]?.play()
        }
        catch {
            print("Player not available")
        }
        
    }
    
    
    func shutUp(_ file:NSString, _ type:NSString = "wav"){
        
        if (sounds[file as String] == nil ) {
            return
        }
        paused.removeValue(forKey: file as String)
        
        sounds[file as String]!.stop()
        sounds[file as String]?.currentTime = 0
    }
    
    
    func setVolume(_ file : NSString, _ type : NSString = "wav", _ vol : Float ){
        
        do {
            if (sounds[file as String] == nil ) {
                let path = Bundle.main.path (forResource: file as String, ofType: type as String)
                try sounds[file as String] = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: path!) as URL)
            }
            sounds[file as String]?.volume = vol
        }
        catch {
            print("Player not available")
        }
        
    }
    
    func pause(_ file:NSString, _ type:NSString = "wav"){
        
        if (sounds[file as String] == nil ) {
            return
        }
        if (sounds[file as String]!.isPlaying){
            sounds[file as String]!.pause()
        }
    }

    
    func pauseAll(){
        for (soundKey, soundValue) in sounds{
            if (soundValue.isPlaying){
                soundValue.pause()
                paused[soundKey] = soundValue
            }
        }
    }
    
    
    func resumeAll(){
        for sound in paused.values{
            sound.play()
        }
        paused.removeAll()
    }
    

}

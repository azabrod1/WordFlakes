//
//  boomBox.swift
//  Word Flakes
//


import Foundation
import AVFoundation


class BoomBox{
    
    
    var sounds = [String : AVAudioPlayer]()
    var paused = [AVAudioPlayer]()
    
    func play(_ file:NSString, _ type:NSString = "wav"){
        
        do {
            if (sounds[file as String] == nil ) {
                let path = Bundle.main.path(forResource: file as String, ofType: type as String)
                let url = NSURL(fileURLWithPath: path!)
                try sounds[file as String] = AVAudioPlayer(contentsOf: url as URL)
            }
            sounds[file as String]?.prepareToPlay()
            sounds[file as String]?.play()
        }
        catch {
            print("Player not available")
        }
        
    }
    
    func playIfNotPlaying(file:NSString, type:NSString = "wav"){
        
        do {
            if (sounds[file as String] == nil ) {
                let path = Bundle.main.path(forResource: file as String, ofType: type as String)
                let url = NSURL(fileURLWithPath: path!)
                try sounds[file as String] = AVAudioPlayer(contentsOf: url as URL)
            }
            if !(sounds[file as String]!).isPlaying {
            
                sounds[file as String]?.prepareToPlay()
                sounds[file as String]?.play()
            }
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
    
    
    func shutUp(file:NSString, type:NSString = "wav"){
        
        if (sounds[file as String] == nil ) {
            return
        }
        sounds[file as String]!.stop()
        sounds[file as String]?.currentTime = 0
    }
    
    
    func setVolume(file : NSString, type : NSString = "wav", vol : Float ){
        
        do {
            if (sounds[file as String] == nil ) {
                let path = Bundle.main.path (forResource: file as String, ofType: type as String)
                let url = NSURL(fileURLWithPath: path!)
                try sounds[file as String] = AVAudioPlayer(contentsOf: url as URL)
            }
            sounds[file as String]?.volume = vol
        }
        catch {
            print("Player not available")
        }
        
    }
    
    func pause(file:NSString, type:NSString = "wav"){
        
        if (sounds[file as String] == nil ) {
            return
        }
        if (sounds[file as String]!.isPlaying){
            sounds[file as String]!.pause()
        
        }
    }

    
    func pauseAll(){
 
        for sound in sounds.values{
            if (sound.isPlaying){
                sound.pause()
                paused.append(sound)
            }
        }
    }
    
    
    func resumeAll(){
        for sound in paused{
            sound.play()
        }
        paused.removeAll()
    }
}

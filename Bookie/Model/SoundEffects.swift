//
//  SoundEffects.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/6/22.
//

import Foundation
import AVFoundation


enum BookSounds: String{
    case pageFlip = "pageFlip"
    case deletion = "deletion"
    case bookClose = "bookClose"
}

class SoundEffect {
    
    static let shared = SoundEffect()
    
    var audioPlayer: AVAudioPlayer?
    
    func playSoundEffect(_ soundname: BookSounds) {
        
        do {
            try! AVAudioSession.sharedInstance().setActive(true)
            let soundURL = Bundle.main.url(forResource: soundname.rawValue, withExtension: "mp3")!

            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
           
            audioPlayer!.play()
            
        } catch {
            print("Setting up audio player \(error.localizedDescription)")
        }
    }
}

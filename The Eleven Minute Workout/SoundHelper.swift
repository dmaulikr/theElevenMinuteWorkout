//
//  SoundHelper.swift
//  The Elven Minute Workout
//
//  Created by Whitney Powell on 3/9/16.
//  Copyright © 2016 Whitney Powell. All rights reserved.
//

import Foundation
import AVFoundation

class SoundHelper {
    private var soundOn:Bool = true 
    private var tickingSound:AVAudioPlayer?
    private var successSound = AVAudioPlayer()
    
    private struct SoundFiles {
        static let tickingSoundFile = "old-clock-ticking"
        static let tickingSoundExtension = "wav"
        static let successSoundFile = "success"
        static let successSoundExtension = "wav"
    }
    
    func getValuesForResultsController() -> (AVAudioPlayer,Bool) {
        return (successSound,soundOn)
    }
    
    private func setupAudioPlayer(fileName:String, fileExtension:String) -> AVAudioPlayer {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: fileExtension)
        let url = NSURL.fileURLWithPath(path!)
        //var error:NSError?'
        return try! AVAudioPlayer(contentsOfURL: url)
    }
    
    func setUpSounds() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let soundShouldBeOn = userDefaults.stringForKey("soundPreference") {
            if(soundShouldBeOn == "yes") {
                soundOn = true
                tickingSound = setupAudioPlayer(SoundFiles.tickingSoundFile,fileExtension:SoundFiles.tickingSoundExtension)
                tickingSound?.volume = 1.0
                successSound = setupAudioPlayer(SoundFiles.successSoundFile, fileExtension: SoundFiles.successSoundExtension)
            } else {
                soundOn = false
            }
        } else {
            userDefaults.setObject("yes", forKey: "soundPreference")
            soundOn = true
            tickingSound = setupAudioPlayer(SoundFiles.tickingSoundFile,fileExtension:SoundFiles.tickingSoundExtension)
            tickingSound?.volume = 1.0
            
            successSound = setupAudioPlayer(SoundFiles.successSoundFile, fileExtension: SoundFiles.successSoundExtension)
        }
    }
    
    func stopSoundIfItIsPlaying() {
        if((tickingSound?.playing) != nil) {
            tickingSound!.stop()
        }
    }
    
    func turnOffSound() {
        soundOn = false
        stopSoundIfItIsPlaying()
    }
    func startTicking() {
        if(soundOn) {
            tickingSound!.play()
        }
    }
    
    func stopTicking() {
        if(soundOn) { tickingSound!.stop() }
    }
    
}
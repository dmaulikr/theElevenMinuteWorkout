//
//  CountUp.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 6/17/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import Foundation
import UIKit



class CountUpTimer:Timer {
    private var removedCircles:Bool = false
    
    override func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        elapsedTime =  elapsedTime + currentTime - lastTime
        let minutesLeft = Int(elapsedTime/60)
        let secondsLeft = Int(elapsedTime - (Double)((minutesLeft*60)))
        updateClockUI(minutesLeft,seconds:secondsLeft)
        if(!removedCircles || elapsedTime < 1) { removeCircles() }
        lastTime = currentTime
    }
    
    override func pauseTimer() {
        super.pauseTimer()
        delegate?.timerCompleted()
    }
    
//    func setTimerTextFromPausedTime(pausedTime:Double) {
//        elapsedTime = pausedTime
//        updateClockUIFromTimeLeft(pausedTime)
//    }
    
    func pauseWithoutEndingWorkout() {
        codeTimer.invalidate()
    }
    
    func removeCircles() {
        delegate?.removeClockCircles()
        removedCircles = true
    }
    
}
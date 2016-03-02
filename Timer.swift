//
//  ClockTimer.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 6/11/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import Foundation
import UIKit

protocol ClockTimerDelegate {
    func timerCompleted()
    func updateProgressCircleEndPoint(strokeEnd:CGFloat)
    func updateEntireCircleStartPoint(strokeStart:CGFloat)
    func setTimerText(time:String)
    func removeClockCircles()
    func startTicking()
    func stopTicking()
}

class Timer:NSObject {
    var delegate: ClockTimerDelegate?
    var codeTimer = NSTimer()
    var completionTime = NSTimeInterval(5)
    var elapsedTime = NSTimeInterval(0)
    var lastTime = NSTimeInterval()
    private var countdownTimer = true
    
    func setTimerText(currentExercise:Int) {
        if(elapsedTime == 0) {
            let timeToCompleteThisExerciseInMinutes = ExerciseTimes.exerciseTimesInMinutes[currentExercise-1]
            completionTime = NSTimeInterval(timeToCompleteThisExerciseInMinutes * 60)
            updateClockUI(Int(timeToCompleteThisExerciseInMinutes), seconds: 0)
        } else {
            let timeToCompleteThisExerciseInMinutes = ExerciseTimes.exerciseTimesInMinutes[currentExercise-1]
            completionTime = NSTimeInterval(timeToCompleteThisExerciseInMinutes * 60)
            updateClockUIFromTimeLeft(completionTime - elapsedTime)
        }
    }
//    
//    func setTimerText(currentExercise:Int, pausedTime:Double) {
//        var timeToCompleteThisExerciseInMinutes = ExerciseTimes.exerciseTimesInMinutes[currentExercise-1]
//        completionTime = NSTimeInterval(timeToCompleteThisExerciseInMinutes * 60)
//        elapsedTime = pausedTime
//        updateClockUIFromTimeLeft(completionTime - pausedTime)
//    }
//    
    
    
    func updateClockUIFromTimeLeft(timeLeft:Double) {
        let minutesLeft = Int(timeLeft/60)
        let secondsLeft = Int(timeLeft - (Double)((minutesLeft*60)))
        updateClockUI(minutesLeft,seconds:secondsLeft)
    }
    
    func revertTimer(currentExercise:Int) {
        setTimerText(currentExercise)
        delegate?.updateProgressCircleEndPoint(0)
        delegate?.updateEntireCircleStartPoint(0)
    }
    
    func updateTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        elapsedTime =  elapsedTime + currentTime - lastTime
        let timeLeft = completionTime - elapsedTime
        let minutesLeft = Int(timeLeft/60)
        let secondsLeft = Int(timeLeft - (Double)((minutesLeft*60)))
        updateClockUI(minutesLeft,seconds:secondsLeft)
        delegate?.updateProgressCircleEndPoint(CGFloat(elapsedTime)/CGFloat(completionTime))
        delegate?.updateEntireCircleStartPoint(CGFloat(elapsedTime)/CGFloat(completionTime))
        lastTime = currentTime
        if minutesLeft == 0 && secondsLeft <= 5 {
            delegate?.startTicking()
        }
        if(elapsedTime > completionTime) {
            delegate?.stopTicking()
            codeTimer.invalidate()
            elapsedTime = 0
            delegate?.timerCompleted()
        }
    }
    
    func updateClockUI(minutes:Int,seconds:Int) {
        let minutesString = String(minutes)
        let secondsString:String = (seconds > 9 ? String(seconds) : "0" + String(seconds))
        let time = minutesString + ":" + secondsString
        delegate?.setTimerText(time)
    }
    
    func startTimer() {
        let updateTimeSelector : Selector = "updateTime"
        codeTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: updateTimeSelector, userInfo: nil, repeats: true)
        lastTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func pauseTimer() {
        codeTimer.invalidate()
    }
    
    override init() {
        super.init()
    }
   
}
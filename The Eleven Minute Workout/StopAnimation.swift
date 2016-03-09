//
//  StopAnimation.swift
//  The Elven Minute Workout
//
//  Created by Whitney Powell on 3/9/16.
//  Copyright © 2016 Whitney Powell. All rights reserved.
//

import Foundation
import UIKit

protocol _11MinuteWorkoutStopAnimationProtocol {
    func startButtonTransitionHasFinished()
}

class StopAnimation {
    private var exerciseImage:UIImageView?
    private var stopAnimationDelegate:_11MinuteWorkoutStopAnimationProtocol?
    
    func setUpExerciseImageAnimation(exercise:Int,workoutIndex:Int) -> UIImageView!
    {
        var exerciseSteps = [UIImage]()
        var thisExerciseIndex = 1
        while(true) {
            let workoutName:String = "chart_" + String(workoutIndex) + "_exercise_" + String(exercise) + "_image_" + String(thisExerciseIndex)
            let nextImage = UIImage(named:workoutName)
            if((nextImage) != nil) {
                exerciseSteps.append(nextImage!)
            } else {
                break
            }
            thisExerciseIndex++
        }
        exerciseImage!.animationImages = exerciseSteps
        exerciseImage!.animationDuration = Double(thisExerciseIndex*2)
        exerciseImage!.animationRepeatCount = 10000
        return exerciseImage
    }
    
    func setup(exerciseImage:UIImageView!,delegate:_11MinuteWorkoutStopAnimationProtocol) {
        self.exerciseImage = exerciseImage
        self.stopAnimationDelegate = delegate
    }

    
    
    func runAnimationOnExerciseImageWhenStartButtonPressed() {
        UIView.transitionWithView(exerciseImage!, duration: 2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {self.exerciseImage!.startAnimating() }, completion:{
            (Bool) in
            self.stopAnimationDelegate?.startButtonTransitionHasFinished()

        })

        }
    
    func runAnimationOnExerciseImageWhenPauseButtonPressed() {
            UIView.transitionWithView(exerciseImage!, duration: 2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {self.exerciseImage!.stopAnimating() }, completion: nil)
    }
    
    func loadRunOrWalkImage(exercise:Int) {
        let nextExerciseImage = exercise == 6 ? UIImage(named: RunAndWalkImageNames.runImageName) : UIImage(named: RunAndWalkImageNames.walkImageName)
        UIView.transitionWithView(exerciseImage!, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {self.exerciseImage!.image = nextExerciseImage }, completion: nil)
    }
    
    func loadExerciseImage(exercise:Int,workoutIndex:Int, currentExercise:Int) {
        switch currentExercise {
        case 1,2,3,4,5:
            let nextExerciseImage = UIImage(named: "chart_" + String(workoutIndex) + "_exercise_" + String(exercise))
            UIView.transitionWithView(exerciseImage!, duration: 2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {self.exerciseImage!.image = nextExerciseImage }, completion: nil)
        case 6:
            loadRunOrWalkImage(6)
        case 7:
            loadRunOrWalkImage(7)
        default:
            break
        }
    }
    
    func stopAnimating() {
        exerciseImage?.stopAnimating()
    }

}
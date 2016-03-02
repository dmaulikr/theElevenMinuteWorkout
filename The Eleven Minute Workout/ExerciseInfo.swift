//
//  ExerciseOverviewViewController.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 4/22/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit

class ExerciseOverviewViewController: UIViewController {
    @IBOutlet weak var exerciseOverview: UITextView!
    var chartIndex = 0
    var exerciseIndex = 0
    var currentExerciseTime:Double = 0.0
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var exerciseImage: UIImageView!
    private func setUpExerciseImageAnimation() {
        var exerciseSteps = [UIImage]()
        var thisExerciseImage = 1
        while(true) {
            let workoutName:String = "chart_" + String(chartIndex) + "_exercise_" + String(exerciseIndex) + "_image_" + String(thisExerciseImage)
            let nextImage = UIImage(named:workoutName)
            if((nextImage) != nil) {
                exerciseSteps.append(nextImage!)
            } else {
                break
            }
            thisExerciseImage++
        }
        
        exerciseImage.animationImages = exerciseSteps
        exerciseImage.animationDuration = Double(thisExerciseImage)
        exerciseImage.animationRepeatCount = 10000
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        exerciseImage.startAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exerciseOverview.scrollRangeToVisible(NSMakeRange(0, 0))
        exerciseOverview?.text = ExerciseExplanations.pickExerciseExplanation(chartIndex, exercise:exerciseIndex)
        if(exerciseIndex <= 5) {
            setUpExerciseImageAnimation()
        } else {
            exerciseImage.image = exerciseIndex == 6 ? UIImage(named: RunAndWalkImageNames.runImageName) : UIImage(named: RunAndWalkImageNames.walkImageName)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let workoutController = segue.destinationViewController as? CountDownTimerViewController{
            if(exerciseIndex <= 5) {
                workoutController.clock.elapsedTime = currentExerciseTime
            } else {
                workoutController.countUpTimer.elapsedTime = currentExerciseTime
            }
            workoutController.exerciseViewController = nil
        }
    }

}

//
//  RecordResultsViewController.swift
//  The Elven Minute Workout
//
//  Created by Whitney Powell on 7/29/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class RecordResultsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var currentExercise = 1
    var currentWorkout = 1
    var alternateExerciseTime:Double = 0.0
    var soundOn = true
    var successSound = AVAudioPlayer()
    var currentRow = 0
    var workoutFinished = false
    private var bestExerciseScores = [-1,-1,-1,-1,-1,-1,-1]
    private var workoutDatabaseObject:Workouts?
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    @IBOutlet weak var subtitleMessage: UILabel!
    @IBOutlet weak var resultsPicker: UIPickerView!
    @IBOutlet weak var resumeThisExerciseButton: UIButton!

    
    @IBAction func submitResults(sender: UIButton) {
        switch currentExercise {
        case 1,2,3,4:
            //addResultsDatabase(ExerciseValues.pickExerciseValue(currentWorkout, exercise:currentExercise)[currentRow].1)
            addResultsDatabase(12 - currentRow)
            performSegueWithIdentifier(SegueIdentifiers.submitResultsSegue, sender: self)
        case 5:
            //addResultsDatabase(ExerciseValues.pickExerciseValue(currentWorkout, exercise:currentExercise)[currentRow].1)
            addResultsDatabase(12 - currentRow)
            performSegueWithIdentifier(SegueIdentifiers.endOfWorkoutSegue, sender: self)
        case 6,7:
            let gradeForThisElapsedTime = ExerciseValues.pickExerciseValue(currentWorkout, exercise:currentExercise, elapsedTime:alternateExerciseTime)
            addResultsDatabase(ExerciseValues.convertGradeToInt(gradeForThisElapsedTime))
            performSegueWithIdentifier(SegueIdentifiers.endOfWorkoutSegue, sender: self)
        default:
            break
        }
    }
    
    private struct SegueIdentifiers {
        static let endOfWorkoutSegue = "show workout finished view controller"
        static let cancelSubmittingResultsSegue = "cancel results"
        static let submitResultsSegue = "submit results"
        static let resumeExerciseSegue = "resume exercise"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBestWorkoutData()
        resultsPicker.dataSource = self
        resultsPicker.delegate = self
        if(currentExercise < 6) {
            resumeThisExerciseButton.hidden = true
        } else {
            resumeThisExerciseButton.hidden = false
            subtitleMessage.text = "Here is your time."
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getElapsedTimeAsString(elapsedTime:Double) -> String{
        //var time = elapsedTime
        let minutes = Int(elapsedTime/60)
        let seconds = Int(elapsedTime - Double(minutes * 60))
        return minutes.description + ":" + (seconds > 9 ? String(seconds) : "0" + String(seconds))
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(currentExercise < 6) {
            let exerciseValues = ExerciseValues.pickExerciseValue(currentWorkout, exercise:currentExercise)
            return exerciseValues.count
        } else {
            return 1
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(currentExercise < 6) {
            var exerciseValues = ExerciseValues.pickExerciseValue(currentWorkout, exercise:currentExercise)
            return exerciseValues[row].0
        } else {
            return getElapsedTimeAsString(alternateExerciseTime)
        }
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("\(row)")
        currentRow = row
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "submit results":
                if let workoutViewController = segue.destinationViewController as? CountDownTimerViewController {
                    // go back to my workout
                    workoutViewController.workoutIndex = currentWorkout
                    workoutViewController.currentExercise = currentExercise + 1
                }
            case SegueIdentifiers.endOfWorkoutSegue:
                if let completedWorkoutViewController = segue.destinationViewController as? CompletedWorkoutViewController {
                    if(soundOn) { successSound.play() }
                    completedWorkoutViewController.currentChart = currentWorkout
                    completedWorkoutViewController.currentExercise = currentExercise
                }
            case SegueIdentifiers.cancelSubmittingResultsSegue:
                if let workoutViewController = segue.destinationViewController as? CountDownTimerViewController {
                    // go back to my workout
                    workoutViewController.workoutIndex = currentWorkout
                    workoutViewController.currentExercise = currentExercise
                }
            case SegueIdentifiers.resumeExerciseSegue:
                if let workoutViewController = segue.destinationViewController as? CountDownTimerViewController {
                    // go back to my workout
                    workoutViewController.workoutIndex = currentWorkout
                    workoutViewController.currentExercise = currentExercise
                    workoutViewController.countUpTimer.elapsedTime = alternateExerciseTime
                }
            default:
                break
            }
        }
    }
    
    func loadBestWorkoutData() {
        let fetchRequest = NSFetchRequest(entityName: "Best_Workouts")
        fetchRequest.predicate = NSPredicate(format: "id == %d", currentWorkout)
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Best_Workouts]
        if(fetchResults != nil && fetchResults!.count > 0) {
            let bestWorkout = fetchResults![0]
            bestExerciseScores[0] = Int(bestWorkout.exercise_1_score)
            bestExerciseScores[1] = Int(bestWorkout.exercise_2_score)
            bestExerciseScores[2] = Int(bestWorkout.exercise_3_score)
            bestExerciseScores[3] = Int(bestWorkout.exercise_4_score)
            bestExerciseScores[4] = Int(bestWorkout.exercise_5_score)
            bestExerciseScores[5] = Int(bestWorkout.exercise_run_score)
            bestExerciseScores[6] = Int(bestWorkout.exercise_walk_score)
        } else {
            let bestWorkout = NSEntityDescription.insertNewObjectForEntityForName("Best_Workouts",inManagedObjectContext: self.managedObjectContext!) as? Best_Workouts
            bestWorkout!.id = currentWorkout
            save()
        }
    }
    
    func save() {
        do {
            try managedObjectContext!.save()
        } catch {
            print("did not save")
        }
    }

    // all of this needs to be tested, I'm not sure about the ids here
    func addResultsDatabase(score:Int) {
        let fetchRequest = NSFetchRequest(entityName: "Workouts")
        fetchRequest.predicate = NSPredicate(format: "completed == false AND workout_id == %d",currentWorkout)
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Workouts]
        workoutDatabaseObject = fetchResults![0]//
        let bestWorkoutFetchRequest = NSFetchRequest(entityName: "Best_Workouts")
        bestWorkoutFetchRequest.predicate = NSPredicate(format: "id == %d", currentWorkout)
        let bestWorkoutFetchResults = (try? managedObjectContext!.executeFetchRequest(bestWorkoutFetchRequest)) as? [Best_Workouts]
        let bestWorkoutsObject = bestWorkoutFetchResults![0]
        let bestExerciseScore = bestExerciseScores[currentExercise - 1]
        switch(currentExercise) {
        case 1:
            workoutDatabaseObject!.exercise_1_score = score
            if thisExerciseGradeIsBetterThanPreviousBest(bestExerciseScore, thisExerciseScore: score) { bestWorkoutsObject.exercise_1_score = score }
        case 2:
            workoutDatabaseObject!.exercise_2_score = score
            if thisExerciseGradeIsBetterThanPreviousBest(bestExerciseScore, thisExerciseScore: score) { bestWorkoutsObject.exercise_2_score = score }
        case 3:
            workoutDatabaseObject!.exercise_3_score = score
            if thisExerciseGradeIsBetterThanPreviousBest(bestExerciseScore, thisExerciseScore: score) { bestWorkoutsObject.exercise_3_score = score }
        case 4:
            workoutDatabaseObject!.exercise_4_score = score
            if thisExerciseGradeIsBetterThanPreviousBest(bestExerciseScore, thisExerciseScore: score) { bestWorkoutsObject.exercise_4_score = score }
        case 5:
            setFinalExerciseScores(score, walkScore: -1, runScore: -1)
            if thisExerciseGradeIsBetterThanPreviousBest(bestExerciseScore, thisExerciseScore: score) { bestWorkoutsObject.exercise_5_score = score }
        case 6:
            setFinalExerciseScores(-1, walkScore: -1, runScore: score)
            if thisExerciseGradeIsBetterThanPreviousBest(bestExerciseScore, thisExerciseScore: score) { bestWorkoutsObject.exercise_run_score = score }
        case 7:
            setFinalExerciseScores(-1, walkScore: score, runScore: -1)
            if thisExerciseGradeIsBetterThanPreviousBest(bestExerciseScore, thisExerciseScore: score) { bestWorkoutsObject.exercise_walk_score = score }
        default:
            break
        }
        save()
    }
    
    func thisExerciseGradeIsBetterThanPreviousBest(bestExerciseScore:Int, thisExerciseScore:Int) -> Bool {
        return bestExerciseScore < thisExerciseScore
    }
    
    func setFinalExerciseScores(exercise5Score:Int,walkScore:Int,runScore:Int) {
        workoutDatabaseObject!.exercise_5_score = exercise5Score
        workoutDatabaseObject!.exercise_walk_score = walkScore
        workoutDatabaseObject!.exercise_run_score = runScore
        workoutDatabaseObject!.completed = true
        workoutFinished = true
    }
}

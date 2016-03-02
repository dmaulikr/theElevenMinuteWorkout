//
//  ExerciseViewController.swift
//  The Elven Minute Workout
//
//  Created by Whitney Powell on 2/11/16.
//  Copyright © 2016 Whitney Powell. All rights reserved.
//

import UIKit
import CoreData

protocol ExerciseDatabaseProtocol {
    func getReadyForANewExercise(nextExercise:Int)
}

class ExerciseResumeHelper {
    private var haventCheckedForResumeOnThisWorkout = true
    private var workoutDatabaseObject:Workouts?
    private var workout:Workouts?
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var exerciseDatabaseDelegate:ExerciseDatabaseProtocol?

    
    // do an initial save of the workout index and date, to be used later by resume
    private func saveInitialWorkoutData(workoutIndex:Int) {
        workoutDatabaseObject = NSEntityDescription.insertNewObjectForEntityForName("Workouts",inManagedObjectContext: self.managedObjectContext!) as? Workouts
        workoutDatabaseObject!.date = NSDate()
        workoutDatabaseObject!.workout_id = workoutIndex
        workoutDatabaseObject!.completed = false
        workoutDatabaseObject!.exercise_1_score = -1
        workoutDatabaseObject!.exercise_2_score = -1
        workoutDatabaseObject!.exercise_3_score = -1
        workoutDatabaseObject!.exercise_4_score = -1
        workoutDatabaseObject!.exercise_5_score = -1
        workoutDatabaseObject!.exercise_run_score = -1
        workoutDatabaseObject!.exercise_walk_score = -1
        save()
    }
    
    func sendAlertForResumeIfNeeded(currentExercise:Int,workoutIndex:Int) -> UIAlertController? {
        if haventCheckedForResumeOnThisWorkout && currentExercise == 1 {
            haventCheckedForResumeOnThisWorkout = false
            return getExerciseNumberToLoad(workoutIndex)
        }
        return nil
    }

    private func getExerciseNumberToLoad(workoutIndex:Int) -> UIAlertController? {
        let fetchRequest = NSFetchRequest(entityName: "Workouts")
        fetchRequest.predicate = NSPredicate(format: "completed == false AND workout_id == %d",workoutIndex)
        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Workouts]
        if(fetchResults?.count > 0) {
            for theWorkout in fetchResults! {
                workout = theWorkout
                if(workout!.workout_id.integerValue == workoutIndex) {
                    if(workout!.exercise_1_score != -1) { // if you have done at least the first exercise
                        //Create an Alert for resume
                        let title = "Resume?"
                        let message = "Would you like to resume your last workout or start a new one? Starting a new workout will delete your uncompleted workout data."
                        let alert = UIAlertController(title:title,message: message,preferredStyle: UIAlertControllerStyle.Alert)
                        let newWorkoutAction = UIAlertAction(title: "Start a new workout", style: UIAlertActionStyle.Cancel, handler:{
                            (UIAlertAction) -> Void in
                            self.managedObjectContext!.deleteObject(self.workout!)
                            self.saveInitialWorkoutData(workoutIndex)
                        })
                        let resumeAction = UIAlertAction(title: "Resume the old workout", style: UIAlertActionStyle.Default, handler:{
                            (UIAlertAction) -> Void in
                         self.workout!.date = NSDate()
                            self.exerciseDatabaseDelegate!.getReadyForANewExercise(self.pickResumePlace(self.workout!))
                        })
                        alert.addAction(newWorkoutAction)
                        alert.addAction(resumeAction)
                        
                        return alert
                    } else {
                        // you haven't even done the first exercise, so delete the old workout data gracefully and create new workout data
                        self.managedObjectContext!.deleteObject(workout!)
                        self.saveInitialWorkoutData(workoutIndex)
                        return nil
                    }
                }
            }
        } else {
            saveInitialWorkoutData(workoutIndex)
            return nil
        }
        return nil
    }
    
    private func save() {
        do {
            try managedObjectContext!.save()
        } catch {
            print("did not save")
        }
    }
    
    private func pickResumePlace(workout:Workouts) -> Int{
        if(workout.exercise_1_score == -1) { return 1 }
        if(workout.exercise_2_score == -1) { return 2 }
        if(workout.exercise_3_score == -1) { return 3 }
        if(workout.exercise_4_score == -1) { return 4 }
        if(workout.exercise_5_score == -1) { return 5 }
        if(workout.exercise_run_score == -1) { return 6 }
        if(workout.exercise_walk_score == -1) { return 7 }
        return 1
    }


}

//
//  CompletedWorkoutViewController.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 5/1/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit
import CoreData

class CompletedWorkoutViewController: UIViewController {
    var currentChart = 0
    var currentExercise = 0
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var exercise1: UILabel!
    @IBOutlet weak var exercise2: UILabel!
    @IBOutlet weak var exercise3: UILabel!
    @IBOutlet weak var exercise4: UILabel!
    @IBOutlet weak var exercise5: UILabel!
    @IBOutlet weak var exercise1Grade: UILabel!
    @IBOutlet weak var exercise2Grade: UILabel!
    @IBOutlet weak var exercise3Grade: UILabel!
    @IBOutlet weak var exercise4Grade: UILabel!
    @IBOutlet weak var exercise5Grade: UILabel!
    
    private func setExerciseNamesForCurrentChart() {
        exercise1.text = ExerciseNames.pickExerciseName(currentChart, exercise: 1)
        exercise2.text = ExerciseNames.pickExerciseName(currentChart, exercise: 2)
        exercise3.text = ExerciseNames.pickExerciseName(currentChart, exercise: 3)
        exercise4.text = ExerciseNames.pickExerciseName(currentChart, exercise: 4)
        exercise5.text = ExerciseNames.pickExerciseName(currentChart, exercise: currentExercise)
    }
    
    private func setWorkoutDataFromTheDatabase() {
        let workoutDatabaseRequest = NSFetchRequest(entityName: "Workouts")
        workoutDatabaseRequest.predicate = NSPredicate(format: "workout_id == %d", currentChart)
        workoutDatabaseRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        workoutDatabaseRequest.fetchLimit = 1
        let workoutData = (try? managedObjectContext!.executeFetchRequest(workoutDatabaseRequest)) as? [Workouts]
        setWorkoutData(workoutData![0])
    }
    
    private func setWorkoutOutlet(score:NSNumber, gradeOutlet:UILabel) {
        gradeOutlet.text = ExerciseValues.convertIntToGrade(score.integerValue)
    }
    
    private func setWorkoutData(workout:Workouts) {
        
        setWorkoutOutlet(workout.exercise_1_score!, gradeOutlet: exercise1Grade)
        setWorkoutOutlet(workout.exercise_2_score!, gradeOutlet: exercise2Grade)
        setWorkoutOutlet(workout.exercise_3_score!, gradeOutlet: exercise3Grade)
        setWorkoutOutlet(workout.exercise_4_score!,  gradeOutlet: exercise4Grade)
        switch currentExercise {
        case 5:
            setWorkoutOutlet(workout.exercise_5_score!, gradeOutlet: exercise5Grade)
        case 6:
            setWorkoutOutlet(workout.exercise_run_score!, gradeOutlet: exercise5Grade)
        case 7:
            setWorkoutOutlet(workout.exercise_walk_score!, gradeOutlet: exercise5Grade)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setExerciseNamesForCurrentChart()
        setWorkoutDataFromTheDatabase()
                // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//        if(segue.identifier == "go to progress") {
//            //if let progressDatasourceViewController = segue.destinationViewController as? ProgressDatasourceViewController {
//                
//            }
        //}
    }


}

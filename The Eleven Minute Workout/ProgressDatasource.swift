//
//  ProgressDatasourceViewController.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 5/4/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit
import CoreData

class ProgressDatasourceViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate  {
    private var pageViewController: UIPageViewController?
    private var progressTitles = ["Percentage of Total Workouts", "Workout 1", "Workout 2", "Workout 3", "Workout 4", "Workout 5", "Workout 6"]
    private var pageIsAnimating = true
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    private var numberOfWorkouts:[Float] = [0,0,0,0,0,0]
    private var bestWorkouts = [[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
    
    func getWorkoutDataFromTheDatabase() {
        // Create a new fetch request using the LogItem entity
        let workoutsDatabaseRequest = NSFetchRequest(entityName: "Workouts")
        let workoutsData = (try? managedObjectContext!.executeFetchRequest(workoutsDatabaseRequest)) as? [Workouts]
        if(workoutsData != nil) {
            for workout in workoutsData! {
                let workoutID = Int(workout.workout_id)
                numberOfWorkouts[workoutID - 1]++
            }
        }
        let bestWorkoutsDatabaseRequest = NSFetchRequest(entityName: "Best_Workouts")
        let bestWorkoutsData = (try? managedObjectContext!.executeFetchRequest(bestWorkoutsDatabaseRequest)) as? [Best_Workouts]
        if(bestWorkoutsData != nil) {
            for workout in bestWorkoutsData! {
                let workoutID = Int(workout.id)
                bestWorkouts[workoutID - 1] = [Int(workout.exercise_1_score),Int(workout.exercise_2_score),Int(workout.exercise_3_score),Int(workout.exercise_4_score),Int(workout.exercise_5_score),Int(workout.exercise_run_score),Int(workout.exercise_walk_score)]
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        getWorkoutDataFromTheDatabase()
        createPageViewController()
        pageIsAnimating = false
     }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        pageIsAnimating = true
    }
    
   
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if(completed || finished) {
            pageIsAnimating = false
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return progressTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    private func createPageViewController() {
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("Progress Page Controller") as! UIPageViewController
        pageController.dataSource = self
        pageController.delegate = self
        let firstController = getItemController(0)!
        let startingViewControllers: NSArray = [firstController]
        pageController.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if(!pageIsAnimating) {
            if let itemController = viewController as? ProgressPageViewController {
                if(itemController.progressPageIndex > 0) {
                    return getItemController(itemController.progressPageIndex - 1)
                }
            } else {
                let itemController = viewController as! BarChartProgressViewController
                if(itemController.chartIndex > 0) {
                    return getItemController(itemController.chartIndex - 1)
                }
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if(!pageIsAnimating) {
            if let itemController = viewController as? ProgressPageViewController {
                if(itemController.progressPageIndex < progressTitles.count) {
                    return getItemController(itemController.progressPageIndex + 1)
                }
            } else {
                let itemController = viewController as! BarChartProgressViewController
                if(itemController.chartIndex < progressTitles.count) {
                    return getItemController(itemController.chartIndex + 1)
                }
            }
        }
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> UIViewController? {
        if itemIndex == 0 {
            let progressController = self.storyboard!.instantiateViewControllerWithIdentifier("Progress View Controller") as! ProgressPageViewController
            progressController.progressPageTitleText = progressTitles[itemIndex]
            progressController.progressPageIndex = itemIndex
            progressController.workoutsPerformed = numberOfWorkouts
            return progressController
        } else if itemIndex < progressTitles.count {
            let progressController = self.storyboard!.instantiateViewControllerWithIdentifier("Bar Chart View Controller") as! BarChartProgressViewController
            progressController.workoutTitleText = progressTitles[itemIndex]
            progressController.chartIndex = itemIndex
            progressController.exerciseScores = bestWorkouts[itemIndex-1]//shift left because bar chart is the first item
            return progressController
        }
        return nil
    }
}

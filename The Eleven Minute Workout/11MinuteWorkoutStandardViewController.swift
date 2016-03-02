//
//  11MinuteWorkoutStandardViewController.swift
//  The Elven Minute Workout
//
//  Created by Whitney Powell on 2/9/16.
//  Copyright © 2016 Whitney Powell. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import AVFoundation

class _11MinuteWorkoutStandardViewController: CountDownTimerViewController {
    var exercise:Exercise?
//    var id = (workout:0,exercise:0) {
//        didSet {
//            // do or die here. If we can't get the exercise data, explode.
//            try! exercise = Exercise.init(workoutId: id.workout, exerciseId: id.exercise)
//        }
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

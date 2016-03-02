//
//  SevenMinuteWorkoutViewController.swift
//  The Elven Minute Workout
//
//  Created by Whitney Powell on 2/11/16.
//  Copyright © 2016 Whitney Powell. All rights reserved.
//

import UIKit

class SevenMinuteWorkoutViewController: UIViewController {
    let GROUP_ID = 11
    var exercise:Exercise?
    //let exerciseCountdownViewCreator = ExerciseCountdownViewCreator()
    
    
    @IBOutlet weak var clockView: UIView!
    
    var id = (workout:0,exercise:0) {
        didSet {
            // do or die here. If we can't get the exercise data, explode.
            try! exercise = Exercise.init(groupId:GROUP_ID, workoutId: id.workout, exerciseId: id.exercise)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        
        //clockView.addSubview(exerciseCountdownViewCreator.returnTheViewOfCircleWithCirclesCountdownTimer(self.view))
        clockView.addSubview(CirclePercentageChart())
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

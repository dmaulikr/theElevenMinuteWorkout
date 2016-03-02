//
//  ProgressPageViewController.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 5/4/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit

class ProgressPageViewController: UIViewController {
    var progressPageIndex = 0
    var progressPageTitleText = ""
    var workoutsPerformed1:[Float] = [1,1,0,4,5,2]
    var workoutsPerformed:[Float] = [1,1,0,4,5,2]


    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressPageTitle: UILabel!
    @IBOutlet weak var workout1Label: UILabel!
    @IBOutlet weak var workout2Label: UILabel!
    @IBOutlet weak var workout3Label: UILabel!
    @IBOutlet weak var workout4Label: UILabel!
    @IBOutlet weak var workout5Label: UILabel!
    @IBOutlet weak var workout6Label: UILabel!
    @IBOutlet weak var workout1Icon: SquareColorIcon!
    @IBOutlet weak var workout2Icon: SquareColorIcon!
    @IBOutlet weak var workout3Icon: SquareColorIcon!
    @IBOutlet weak var workout4Icon: SquareColorIcon!
    @IBOutlet weak var workout5Icon: SquareColorIcon!
    @IBOutlet weak var workout6Icon: SquareColorIcon!
    
    
    func convertHexToUIColor(red:CGFloat, green:CGFloat, blue:CGFloat) -> UIColor {
        return UIColor(
            red: red / 255.0,
            green: green / 255.0,
            blue: blue / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpWorkoutLabelTexts()
        progressPageTitle.text = progressPageTitleText
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLabelTextForPercentagePerformedValue(label:UILabel,labelName:String,numberOfTimesPerformed:Float,numberOfTotalWorkouts:Float, percentageNumberFormatter:NSNumberFormatter) {
        if(numberOfTotalWorkouts > 0) {
            let decimalOfTimesPerformedOverTotalWorkouts = numberOfTimesPerformed/numberOfTotalWorkouts
            label.text = labelName + ": " + percentageNumberFormatter.stringFromNumber(decimalOfTimesPerformedOverTotalWorkouts)!
        } else {
            label.text = labelName + ": " + percentageNumberFormatter.stringFromNumber(0)!
        }
    }
    
    func setUpWorkoutLabelTexts() {
        let numberOfTotalWorkouts = workoutsPerformed.reduce(0, combine: +)
        let percentageNumberFormatter = NSNumberFormatter()
        percentageNumberFormatter.numberStyle = .PercentStyle
        percentageNumberFormatter.maximumFractionDigits = 2
        setLabelTextForPercentagePerformedValue(workout1Label, labelName: "Level 1", numberOfTimesPerformed: workoutsPerformed[0], numberOfTotalWorkouts: numberOfTotalWorkouts, percentageNumberFormatter: percentageNumberFormatter)
        setLabelTextForPercentagePerformedValue(workout2Label, labelName: "Level 2", numberOfTimesPerformed: workoutsPerformed[1], numberOfTotalWorkouts: numberOfTotalWorkouts, percentageNumberFormatter: percentageNumberFormatter)
        setLabelTextForPercentagePerformedValue(workout3Label, labelName: "Level 3", numberOfTimesPerformed: workoutsPerformed[2], numberOfTotalWorkouts: numberOfTotalWorkouts, percentageNumberFormatter: percentageNumberFormatter)
        setLabelTextForPercentagePerformedValue(workout4Label, labelName: "Level 4", numberOfTimesPerformed: workoutsPerformed[3], numberOfTotalWorkouts: numberOfTotalWorkouts, percentageNumberFormatter: percentageNumberFormatter)
        setLabelTextForPercentagePerformedValue(workout5Label, labelName: "Level 5", numberOfTimesPerformed: workoutsPerformed[4], numberOfTotalWorkouts: numberOfTotalWorkouts, percentageNumberFormatter: percentageNumberFormatter)
        setLabelTextForPercentagePerformedValue(workout6Label, labelName: "Level 6", numberOfTimesPerformed: workoutsPerformed[5], numberOfTotalWorkouts: numberOfTotalWorkouts, percentageNumberFormatter: percentageNumberFormatter)
    }
    
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let progressChart = progressView as! CirclePercentageChart
        var colors = [convertHexToUIColor(0x65, green: 0x92, blue: 0x7b),convertHexToUIColor(0x7b, green: 0x65, blue: 0x92),convertHexToUIColor(0x92, green: 0x65, blue: 0x66),convertHexToUIColor(0xa4, green: 0x86, blue: 0x55),convertHexToUIColor(0x65, green: 0x7c, blue: 0x92),convertHexToUIColor(0x3a, green: 0x31, blue: 0x28)]
        progressChart.colors = colors
        workout1Icon.color = colors[0]
        workout2Icon.color = colors[1]
        workout3Icon.color = colors[2]
        workout4Icon.color = colors[3]
        workout5Icon.color = colors[4]
        workout6Icon.color = colors[5]
        progressChart.workoutUsage = workoutsPerformed
    }
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */



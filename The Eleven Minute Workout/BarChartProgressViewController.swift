//
//  BarChartProgressViewController.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 5/6/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit

class BarChartProgressViewController: UIViewController {
    var chartLevelShowing = true
    var chartIndex = 0
    var workoutTitleText = ""
    var exerciseScores = [0]
    
    @IBOutlet weak var workoutTitle: UILabel!
    @IBOutlet weak var exercise1Icon: SquareColorIcon!
    @IBOutlet weak var exercise2Icon: SquareColorIcon!
    @IBOutlet weak var exercise3Icon: SquareColorIcon!
    @IBOutlet weak var exercise4Icon: SquareColorIcon!
    @IBOutlet weak var exercise5Icon: SquareColorIcon!
    @IBOutlet weak var exercise1Label: UILabel!
    @IBOutlet weak var exercise2Label: UILabel!
    @IBOutlet weak var exercise3Label: UILabel!
    @IBOutlet weak var exercise5Label: UILabel!
    @IBOutlet weak var chartDetailView: VerticalBarChart!
    @IBOutlet weak var exercise4Label: UILabel!
    
    private func setUpExerciseLables(scores:[Int]) {
        exercise1Label.text = ExerciseNames.pickExerciseName(chartIndex, exercise: 1) +  ": " + ExerciseValues.convertIntToGrade(scores[0])
        exercise2Label.text = ExerciseNames.pickExerciseName(chartIndex, exercise: 2) +  ": " + ExerciseValues.convertIntToGrade(scores[1])
        exercise3Label.text = ExerciseNames.pickExerciseName(chartIndex, exercise: 3) + ": " + ExerciseValues.convertIntToGrade(scores[2])
        exercise4Label.text = ExerciseNames.pickExerciseName(chartIndex, exercise: 4) + ": " + ExerciseValues.convertIntToGrade(scores[3])
        if(chartIndex > 4) {
            exercise5Label.text = ExerciseNames.pickExerciseName(chartIndex, exercise: 5) + " or " + ExerciseNames.pickExerciseName(chartIndex, exercise: 6) + ": " + ExerciseValues.convertIntToGrade(scores[4])
        } else {
            exercise5Label.text = ExerciseNames.pickExerciseName(chartIndex, exercise: 5) + ", " + ExerciseNames.pickExerciseName(chartIndex, exercise: 6) + ", or " + ExerciseNames.pickExerciseName(chartIndex, exercise: 7) + ": " + ExerciseValues.convertIntToGrade(scores[4])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpExerciseLables(setBarChartScores())
        workoutTitle.text = "Best Scores for " + workoutTitleText
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        chartDetailView.setNeedsDisplay()
    }
    
    func convertHexToUIColor(red:CGFloat, green:CGFloat, blue:CGFloat) -> UIColor {
        return UIColor(
            red: red / 255.0,
            green: green / 255.0,
            blue: blue / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    func setUpColors(chartColors:[UIColor]) {
        exercise1Icon.color = chartColors[0]
        exercise2Icon.color = chartColors[1]
        exercise3Icon.color = chartColors[2]
        exercise4Icon.color = chartColors[3]
        exercise5Icon.color = chartColors[4]
        chartDetailView.colors = chartColors
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        let chart1BarColors = [UIColorFromRGB(UInt(0x927f65)),UIColorFromRGB(0x92658b),UIColorFromRGB(0x65927b),UIColorFromRGB(0x776592),UIColorFromRGB(0x926569)]
        let chart2BarColors = [UIColorFromRGB(UInt(0x65927f)),UIColorFromRGB(0x8b9265),UIColorFromRGB(0x7b6592),UIColorFromRGB(0x927765),UIColorFromRGB(0x699265)]
        let chart3BarColors = [UIColorFromRGB(UInt(0x686592)),UIColorFromRGB(0x659282),UIColorFromRGB(0x926566),UIColorFromRGB(0x6a9265),UIColorFromRGB(0x658092)]
        let chart4BarColors = [UIColorFromRGB(UInt(0x8d55a4)),UIColorFromRGB(0x558da4),UIColorFromRGB(0xa48655),UIColorFromRGB(0x55a47f),UIColorFromRGB(0x5855a4)]
        let chart5BarColors = [UIColorFromRGB(UInt(0x789265)),UIColorFromRGB(0x926c65),UIColorFromRGB(0x657c92),UIColorFromRGB(0x926580),UIColorFromRGB(0x92be65)]
        let chart6BarColors = [UIColorFromRGB(UInt(0x33283a)),UIColorFromRGB(0x28373a),UIColorFromRGB(0x3a3128),UIColorFromRGB(0x283a30),UIColorFromRGB(0x282a3a)]
        switch(chartIndex) {
        case 1:
            setUpColors(chart1BarColors)
        case 2:
            setUpColors(chart2BarColors)
        case 3:
            setUpColors(chart3BarColors)
        case 4:
            setUpColors(chart4BarColors)
        case 5:
            setUpColors(chart5BarColors)
        case 6:
            setUpColors(chart6BarColors)
        default: break
        }
        let tint = convertHexToUIColor(0x49, green: 0x3d, blue: 0x32)
        chartDetailView.edgesColor = tint
        chartDetailView.scores = setBarChartScores()
    }
    
    func setBarChartScores() -> [Int]{
        var reducedExerciseScores = [exerciseScores[0],exerciseScores[1],exerciseScores[2],exerciseScores[3]]
        if(chartIndex > 4) {
            reducedExerciseScores.append(max(exerciseScores[4],exerciseScores[5]))
            return reducedExerciseScores
        } else {
            let bestOfRunAndWalk = max(exerciseScores[5],exerciseScores[6])
            let bestExercise5Score = max(exerciseScores[4],bestOfRunAndWalk)
            reducedExerciseScores.append(bestExercise5Score)
            return reducedExerciseScores
        }
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

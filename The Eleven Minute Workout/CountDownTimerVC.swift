//
//  CountDownTimerViewController.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 4/13/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import AVFoundation

class CountDownTimerViewController: UIViewController, ClockTimerDelegate, UIPopoverPresentationControllerDelegate, ExerciseDatabaseProtocol, _11MinuteWorkoutStopAnimationProtocol {
    // new stuff begins
    let exerciseResumeHelper = ExerciseResumeHelper()
    let soundHelper = SoundHelper()
    let stopAnimation = StopAnimation()
    // new stuff ends
    
    var workoutIndex = 1 
    var currentExercise = 1
    var clock = Timer()
    var countUpTimer = CountUpTimer()
    private var progressCircle = CAShapeLayer()
    private var entireCircle = CAShapeLayer()
    private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    private var workoutDatabaseObject:Workouts?
    private let buttonStartTag = 0
    private let buttonPauseTag = 1
    private var comingFromExerciseOverview = false
    var exerciseViewController:ExerciseOverviewViewController? = nil
    private var displayedAsPopover = false
    private var exiting = false

    @IBAction func exitExerciseOverview(segue:UIStoryboardSegue) {
        comingFromExerciseOverview = true
        exerciseViewController = nil
    }
    
    @IBAction func exitPlaylistCreator(segue:UIStoryboardSegue) {
        comingFromExerciseOverview = true
    }
    
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        exerciseViewController = nil
        comingFromExerciseOverview = true
    }
    
    
    struct SegueIdentifiers {
        static let exerciseExplanationSegue = "show exercise overview"
        static let cancelWorkoutSegue = "cancel workout"
        static let recordResultsSegue = "record results"
        static let openPlaylistCreator = "open playlist creator"
    }
    
    func getCurrentTime() -> Double {
        if(currentExercise <= 5) {
            return clock.elapsedTime
        } else {
            return countUpTimer.elapsedTime
        }
    }
    
    func pauseTimerWithoutEndingWorkout() {
        if(currentExercise <= 5) {
            clock.pauseTimer()
        } else {
            countUpTimer.pauseWithoutEndingWorkout()
        }
        updateToStartState(startStopButton)
        stopAnimation.stopAnimating()
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        displayedAsPopover = true
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case SegueIdentifiers.exerciseExplanationSegue:
                if let exerciseOverviewController = segue.destinationViewController as? ExerciseOverviewViewController {
                    exerciseOverviewController.popoverPresentationController!.delegate = self
                    pauseTimerWithoutEndingWorkout()
                    soundHelper.stopSoundIfItIsPlaying()
                    exerciseOverviewController.chartIndex = workoutIndex
                    exerciseOverviewController.exerciseIndex = currentExercise
                    exerciseOverviewController.currentExerciseTime = getCurrentTime()
                    exerciseViewController = exerciseOverviewController
                }
            case SegueIdentifiers.cancelWorkoutSegue:
                exiting = true
                soundHelper.turnOffSound() // locally turn off sound, so it doesn't play while view controller is being removed from the view hierarchy, can we use stopsoundifitisplaying here? why not?
            case SegueIdentifiers.recordResultsSegue:
                if let resultsController = segue.destinationViewController as? RecordResultsViewController {
                    if(exerciseViewController != nil && exerciseViewController!.isViewLoaded()) { // close the overview controller if it is still open
                      exerciseViewController?.dismissViewControllerAnimated(true, completion: nil)
                    }
                    resultsController.currentExercise = currentExercise
                    resultsController.currentWorkout = workoutIndex
                    resultsController.alternateExerciseTime = countUpTimer.elapsedTime
                    let soundValues = soundHelper.getValuesForResultsController()
                    resultsController.soundOn = soundValues.1
                    resultsController.successSound = soundValues.0
                }
            case SegueIdentifiers.openPlaylistCreator:
                if let playlistController = segue.destinationViewController as? PlaylistViewController {
                    pauseTimerWithoutEndingWorkout()
                    soundHelper.stopSoundIfItIsPlaying()
                    playlistController.exerciseIndex = currentExercise
                    playlistController.currentExerciseTime = getCurrentTime()
                }
            default:
                break
            }
        }
    }
    
    @IBOutlet weak var alternateExerciseSegmentedControl: UISegmentedControl!
    @IBOutlet weak var countDownTimerView: UIView!
    @IBOutlet weak var exerciseImage: UIImageView! {
        didSet {
            stopAnimation.setup(self.exerciseImage, delegate: self)
        }
    }
    @IBOutlet weak var upNextLabel: UILabel!
    @IBOutlet weak var workoutName: UILabel!
    @IBOutlet weak var timer: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBAction func startStopAction(button: UIButton) {
        flipStartStopButton(button)
    }
    
    // The user is messing with the segmented control on the workout 5/6/7 page. If a current workout is running (not paused), show the confirmStopWorkout alert and handle from there. If not, check to see if the workout has progressed (elapsed time > 0). If so, show the confirmStopWorkout alert, etc. Otherwise, just switch the segmented control to the part the user touched.
    @IBAction func alternateExerciseSelected(sender: UISegmentedControl) {
        if(startStopButton.tag == buttonPauseTag) {
            confirmStopWorkout(sender)
        } else {
            if(currentExercise == 5) {
                if(clock.elapsedTime > 0) {
                    confirmStopWorkout(sender)
                } else {
                    switchExerciseDataForSegmentedControl(sender)
                }
            } else if(countUpTimer.elapsedTime > 0) {
                confirmStopWorkout(sender)
            } else {
                switchExerciseDataForSegmentedControl(sender)
            }
        }
    }
    
    func switchExerciseDataForSegmentedControl(sender:UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentExercise = 5
            stopAnimation.loadExerciseImage(5,workoutIndex:workoutIndex,currentExercise:currentExercise)
            setTimerText("6:00")
            entireCircle.strokeStart = 0
            entireCircle.strokeEnd = 1.0
        case 1:
            currentExercise = 6
            stopAnimation.loadRunOrWalkImage(6)
            setTimerText("0:00")
        case 2:
            currentExercise = 7
            stopAnimation.loadRunOrWalkImage(7)
            setTimerText("0:00")
        default:
            print("")
        }
        updateWorkoutName(currentExercise)
    }

    func confirmStopWorkout(sender:UISegmentedControl) {
        pauseTimerWithoutEndingWorkout()
        soundHelper.stopSoundIfItIsPlaying()
        let stopWorkoutAlert = UIAlertController(title: "Stop Exercise", message: "Switching exercises will stop your current exercise. Would you like to continue?", preferredStyle: UIAlertControllerStyle.Alert)
        (stopWorkoutAlert.view).tintColor = convertHexToUIColor(0x65, green: 0x7c, blue: 0x92)
        stopWorkoutAlert.popoverPresentationController?.sourceView = self.view
        stopWorkoutAlert.popoverPresentationController?.sourceRect = CGRectMake(0, 0, 1.0, 1.0)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler:{
            (UIAlertAction) -> Void in
            switch self.currentExercise {
            case 5:
                sender.selectedSegmentIndex = 0
            case 6:
                sender.selectedSegmentIndex = 1
            case 7:
                sender.selectedSegmentIndex = 2
            default:
                break
            }

        })
        let stopWorkoutAction = UIAlertAction(title: "Stop this Exercise", style: UIAlertActionStyle.Destructive, handler:{
            (UIAlertAction) -> Void in
            if(self.currentExercise == 5) {
                self.clock.elapsedTime = 0
                self.updateProgressCircleEndPoint(0)
                self.updateEntireCircleStartPoint(0)
            } else {
                self.countUpTimer.elapsedTime = 0
                self.updateEntireCircleStartPoint(0)
                self.entireCircle.strokeEnd = 1.0
            }
            self.updateToStartState(self.startStopButton)
            self.switchExerciseDataForSegmentedControl(sender)
        })
        stopWorkoutAlert.addAction(cancelAction)
        stopWorkoutAlert.addAction(stopWorkoutAction)
        presentViewController(stopWorkoutAlert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var playPauseImage: UIImageView!
    
    func updateToPauseState(button: UIButton) {
        button.tag = buttonPauseTag
        playPauseImage?.image = UIImage(named:"pause")
        if(currentExercise <= 5) {
            UIView.animateWithDuration(2, animations: {self.playPauseImage?.alpha = 0})
        }
    }
    
    func updateToStartState(button: UIButton) {
        button.tag = buttonStartTag
        UIView.animateWithDuration(1, animations: {})
        playPauseImage.alpha = 1
        playPauseImage?.image = UIImage(named:"play")
    }
    
    func startTicking() {
        soundHelper.startTicking()
    }
    
    func stopTicking() {
        soundHelper.stopTicking()
    }
   
    func startButtonTransitionHasFinished() {
        if(self.exerciseViewController == nil) {
            // start the timer unless the user has opened the exercise info popup during the animation
            // also, check that we haven't paused it in the meantime
            if(startStopButton.tag != self.buttonStartTag) {self.startTimer() }
        }
    }
    
    func flipStartStopButton(button: UIButton) {
        if(button.tag == buttonStartTag) {
            updateToPauseState(button)
            if(currentExercise <= 5) {
                stopAnimation.runAnimationOnExerciseImageWhenStartButtonPressed()
            } else {
                startTimer()
            }
        } else {
            updateToStartState(button)
            pauseTimer()
            soundHelper.stopSoundIfItIsPlaying()
            if(currentExercise <= 5) {
                stopAnimation.runAnimationOnExerciseImageWhenPauseButtonPressed()
            }
            
        }
    }
    
    func getElapsedTimeAsString(elapsedTime:Double) -> String{
        let minutes = Int(elapsedTime/60)
        let seconds = Int(elapsedTime - Double(minutes * 60))
        return minutes.description + ":" + (seconds > 9 ? String(seconds) : "0" + String(seconds))
    }
    
    func handleSegementedControlForAlternateExercises(exerciseToLoad:Int) {
        if(exerciseToLoad >= 5) {
            if(workoutIndex == 5 || workoutIndex == 6) {
                alternateExerciseSegmentedControl.removeSegmentAtIndex(2, animated: false)
            }
            alternateExerciseSegmentedControl.hidden = false
            if(exerciseToLoad == 6) {
                alternateExerciseSegmentedControl.selectedSegmentIndex = 1
            }
            if(exerciseToLoad == 7) {
                alternateExerciseSegmentedControl.selectedSegmentIndex = 2
            }
        }
    }

    func startTimer() {
        if(currentExercise <= 5) {
           clock.startTimer()
        } else {
            countUpTimer.startTimer()
        }
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    func pauseTimer() {
        if(currentExercise <= 5) {
            clock.pauseTimer()
        } else {
            countUpTimer.pauseTimer()
        }

    }
    
    func createCircleAndAddToView(circle:CAShapeLayer, view:UIView!, color:UIColor, lineWidth:CGFloat, strokeStart:CGFloat, strokeEnd:CGFloat) {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        let centerPoint = CGPoint(x:view.bounds.width/2,y:view.bounds.height/2)
        let radius:CGFloat = view.bounds.width/2 * 0.8
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(-0.5*M_PI), endAngle: CGFloat(1.5*M_PI), clockwise: true)
        circle.path = circlePath.CGPath
        circle.strokeColor = color.CGColor
        circle.fillColor = UIColor.clearColor().CGColor
        circle.lineWidth = lineWidth
        circle.strokeStart = strokeStart
        circle.strokeEnd = strokeEnd
        view.layer.addSublayer(circle)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let centerPoint = CGPoint(x:countDownTimerView!.bounds.width/2,y:countDownTimerView!.bounds.height/2)
        let radius:CGFloat = countDownTimerView!.bounds.width/2 * 0.8
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(-0.5*M_PI), endAngle: CGFloat(1.5*M_PI), clockwise: true)
        progressCircle.path = circlePath.CGPath
        entireCircle.path = circlePath.CGPath
    }
    
    func updateWorkoutName(exercise:Int) {
        workoutName?.text = ExerciseNames.pickExerciseName(workoutIndex, exercise:exercise)
    }
    func updateNextWorkoutName(exercise:Int) {
        if(exercise < 5) {
            upNextLabel?.text = "Up next: " + ExerciseNames.pickExerciseName(workoutIndex, exercise:exercise + 1)
        } else {
            upNextLabel?.text = ""
        }
    }
    
    func convertHexToUIColor(red:CGFloat, green:CGFloat, blue:CGFloat) -> UIColor {
        return UIColor(
            red: red / 255.0,
            green: green / 255.0,
            blue: blue / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func setTime() {
        if(currentExercise < 6) {
            clock.setTimerText(currentExercise)
        } else {
            setTimerText(getElapsedTimeAsString(countUpTimer.elapsedTime))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        soundHelper.setUpSounds()
        
        clock.delegate = self
        countUpTimer.delegate = self
        handleSegementedControlForAlternateExercises(currentExercise)
        createCircleAndAddToView(entireCircle, view: countDownTimerView!, color: convertHexToUIColor(0xbd, green: 0xaf, blue: 0xa2), lineWidth: 8, strokeStart: 0, strokeEnd: 1)
        createCircleAndAddToView(progressCircle, view: countDownTimerView!, color: convertHexToUIColor(0x65, green: 0x7c, blue: 0x92), lineWidth: 8, strokeStart: 0, strokeEnd: 0)
        setTime()
        stopAnimation.setUpExerciseImageAnimation(currentExercise,workoutIndex: workoutIndex)
        stopAnimation.loadExerciseImage(currentExercise,workoutIndex:workoutIndex,currentExercise:currentExercise)
        startStopButton.tag = 0
        updateWorkoutName(currentExercise)
        updateNextWorkoutName(currentExercise)
    }
    
    func getReadyForNextExercise(nextExerciseToLoad:Int) {
        handleSegementedControlForAlternateExercises(nextExerciseToLoad)
        clock.revertTimer(nextExerciseToLoad)
        updateNextWorkoutName(nextExerciseToLoad)
        stopAnimation.loadExerciseImage(nextExerciseToLoad,workoutIndex:workoutIndex,currentExercise:currentExercise)
        stopAnimation.setUpExerciseImageAnimation(nextExerciseToLoad,workoutIndex: workoutIndex)
        updateWorkoutName(nextExerciseToLoad)
        //new
        currentExercise = nextExerciseToLoad
    }
    
    func timerCompleted() {
        flipStartStopButton(startStopButton)
        UIApplication.sharedApplication().idleTimerDisabled = false
        if(!exiting) { performSegueWithIdentifier(SegueIdentifiers.recordResultsSegue, sender: self) }
    }
    
    func removeClockCircles() {
        entireCircle.strokeStart = 0
        progressCircle.strokeStart = 0
        progressCircle.strokeEnd = 0
        entireCircle.strokeEnd = 0
    }
    
    func updateEntireCircleStartPoint(strokeStart: CGFloat) {
       entireCircle.strokeStart = strokeStart
    }
    
    func updateProgressCircleEndPoint(strokeEnd: CGFloat) {
        progressCircle.strokeEnd = strokeEnd
    }
    func setTimerText(time: String) {
        timer.text = time
    }
    
    func resume() {
        if let alert = exerciseResumeHelper.sendAlertForResumeIfNeeded(currentExercise, workoutIndex: workoutIndex) {
            presentViewController(alert, animated: true,completion: {})
        } else {
            currentExercise = 1
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        exerciseResumeHelper.exerciseDatabaseDelegate = self
        if !exiting && !comingFromExerciseOverview { resume() }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        //exerciseImage.stopAnimating()
        stopAnimation.stopAnimating()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //new
    func getReadyForANewExercise(nextExercise:Int) {
        getReadyForNextExercise(nextExercise)
    }
    
}

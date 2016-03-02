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

class CountDownTimerViewController: UIViewController, ClockTimerDelegate, UIPopoverPresentationControllerDelegate, ExerciseDatabaseProtocol {
    // new stuff begins
    let exerciseResumeHelper = ExerciseResumeHelper()
    
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
    private var tickingSound:AVAudioPlayer?
    private var successSound = AVAudioPlayer()
    private var soundOn = true
    var exerciseViewController:ExerciseOverviewViewController? = nil
    private var displayedAsPopover = false
    private var exiting = false
    //private var haveCheckedForResume = false

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
    
    func setupAudioPlayer(fileName:String, fileExtension:String) -> AVAudioPlayer {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: fileExtension)
        let url = NSURL.fileURLWithPath(path!)
        //var error:NSError?'
        return try! AVAudioPlayer(contentsOfURL: url)
    }
    
    struct SegueIdentifiers {
        static let exerciseExplanationSegue = "show exercise overview"
        static let cancelWorkoutSegue = "cancel workout"
        static let recordResultsSegue = "record results"
        static let openPlaylistCreator = "open playlist creator"
    }
    
    struct SoundFiles {
        static let tickingSoundFile = "old-clock-ticking"
        static let tickingSoundExtension = "wav"
        static let successSoundFile = "success"
        static let successSoundExtension = "wav"
    }
    
    func getCurrentTime() -> Double{
        if(currentExercise <= 5) {
            return clock.elapsedTime
        } else {
            return countUpTimer.elapsedTime
        }
    }
    
    func stopSoundIfItIsPlaying() {
        if((tickingSound?.playing) != nil) {
            tickingSound!.stop()
        }
    }
    
    func pauseTimerWithoutEndingWorkout() {
        if(currentExercise <= 5) {
            clock.pauseTimer()
        } else {
            countUpTimer.pauseWithoutEndingWorkout()
        }
        updateToStartState(startStopButton)
        exerciseImage.stopAnimating()
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
                    stopSoundIfItIsPlaying()
                    exerciseOverviewController.chartIndex = workoutIndex
                    exerciseOverviewController.exerciseIndex = currentExercise
                    exerciseOverviewController.currentExerciseTime = getCurrentTime()
                    exerciseViewController = exerciseOverviewController
                }
            case SegueIdentifiers.cancelWorkoutSegue:
                exiting = true
                stopSoundIfItIsPlaying()
                soundOn = false // locally turn off sound, so it doesn't play while view controller is being removed from the view hierarchy
            case SegueIdentifiers.recordResultsSegue:
                if let resultsController = segue.destinationViewController as? RecordResultsViewController {
                    if(exerciseViewController != nil && exerciseViewController!.isViewLoaded()) { // close the overview controller if it is still open
                      exerciseViewController?.dismissViewControllerAnimated(true, completion: nil)
                    }
                    resultsController.currentExercise = currentExercise
                    resultsController.currentWorkout = workoutIndex
                    resultsController.alternateExerciseTime = countUpTimer.elapsedTime
                    resultsController.soundOn = soundOn
                    resultsController.successSound = successSound
                }
            case SegueIdentifiers.openPlaylistCreator:
                if let playlistController = segue.destinationViewController as? PlaylistViewController {
                    pauseTimerWithoutEndingWorkout()
                    stopSoundIfItIsPlaying()
                    playlistController.exerciseIndex = currentExercise
                    playlistController.currentExerciseTime = getCurrentTime()
                }
            default:
                break
            }
        }
    }
    
    private func setUpExerciseImageAnimation(exercise:Int) {
        var exerciseSteps = [UIImage]()
        var thisExerciseIndex = 1
        while(true) {
            let workoutName:String = "chart_" + String(workoutIndex) + "_exercise_" + String(exercise) + "_image_" + String(thisExerciseIndex)
            let nextImage = UIImage(named:workoutName)
            if((nextImage) != nil) {
                exerciseSteps.append(nextImage!)
            } else {
                break
            }
            thisExerciseIndex++
        }
        exerciseImage.animationImages = exerciseSteps
        exerciseImage.animationDuration = Double(thisExerciseIndex*2)
        exerciseImage.animationRepeatCount = 10000
    }
    
    @IBOutlet weak var alternateExerciseSegmentedControl: UISegmentedControl!
    @IBOutlet weak var countDownTimerView: UIView!
    @IBOutlet weak var exerciseImage: UIImageView! 
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
            loadExerciseImage(5)
            setTimerText("6:00")
            entireCircle.strokeStart = 0
            entireCircle.strokeEnd = 1.0
        case 1:
            currentExercise = 6
            loadRunOrWalkImage(6)
            setTimerText("0:00")
        case 2:
            currentExercise = 7
            loadRunOrWalkImage(7)
            setTimerText("0:00")
        default:
            print("")
        }
        updateWorkoutName(currentExercise)
    }

    func confirmStopWorkout(sender:UISegmentedControl) {
        pauseTimerWithoutEndingWorkout()
        stopSoundIfItIsPlaying()
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
        if(soundOn) {
            tickingSound!.play()
        }
    }
    
    func stopTicking() {
        if(soundOn) { tickingSound!.stop() }
    }
   
    func flipStartStopButton(button: UIButton) {
        if(button.tag == buttonStartTag) {
            updateToPauseState(button)
            if(currentExercise <= 5) {
                UIView.transitionWithView(exerciseImage, duration: 2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {self.exerciseImage.startAnimating() }, completion:{
                    (Bool) in
                    if(self.exerciseViewController == nil) {
                        // start the timer unless the user has opened the exercise info popup during the animation
                        // also, check that we haven't paused it in the meantime
                        if(button.tag != self.buttonStartTag) {self.startTimer() }
                    }
                })
            } else {
                startTimer()
            }
        } else {
            updateToStartState(button)
            pauseTimer()
            if((tickingSound?.playing) != nil) { stopTicking() }
            if(currentExercise <= 5) {
                UIView.transitionWithView(exerciseImage, duration: 2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {self.exerciseImage.stopAnimating() }, completion: nil)
            }
            
        }
    }

//    func save() {
//        do {
//            try managedObjectContext!.save()
//        } catch {
//            print("did not save")
//        }
//    }
    
    func getElapsedTimeAsString(elapsedTime:Double) -> String{
        //var time = elapsedTime
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
    
    private func loadRunOrWalkImage(exercise:Int) {
        let nextExerciseImage = exercise == 6 ? UIImage(named: RunAndWalkImageNames.runImageName) : UIImage(named: RunAndWalkImageNames.walkImageName)
        UIView.transitionWithView(exerciseImage, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {self.exerciseImage.image = nextExerciseImage }, completion: nil)
    }
    
    private func loadExerciseImage(exercise:Int) {
        switch currentExercise {
        case 1,2,3,4,5:
            let nextExerciseImage = UIImage(named: "chart_" + String(workoutIndex) + "_exercise_" + String(exercise))
            UIView.transitionWithView(exerciseImage, duration: 2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {self.exerciseImage.image = nextExerciseImage }, completion: nil)
        case 6:
            loadRunOrWalkImage(6)
        case 7:
            loadRunOrWalkImage(7)
        default:
            break
        }
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
    
    func setUpSounds() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let soundShouldBeOn = userDefaults.stringForKey("soundPreference") {
            if(soundShouldBeOn == "yes") {
                soundOn = true
                tickingSound = setupAudioPlayer(SoundFiles.tickingSoundFile,fileExtension:SoundFiles.tickingSoundExtension)
                tickingSound?.volume = 1.0
                successSound = setupAudioPlayer(SoundFiles.successSoundFile, fileExtension: SoundFiles.successSoundExtension)
            } else {
                soundOn = false
            }
        } else {
            userDefaults.setObject("yes", forKey: "soundPreference")
            soundOn = true
            tickingSound = setupAudioPlayer(SoundFiles.tickingSoundFile,fileExtension:SoundFiles.tickingSoundExtension)
            tickingSound?.volume = 1.0

            successSound = setupAudioPlayer(SoundFiles.successSoundFile, fileExtension: SoundFiles.successSoundExtension)
        }
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
        setUpSounds()
        
        clock.delegate = self
        countUpTimer.delegate = self
        handleSegementedControlForAlternateExercises(currentExercise)
        createCircleAndAddToView(entireCircle, view: countDownTimerView!, color: convertHexToUIColor(0xbd, green: 0xaf, blue: 0xa2), lineWidth: 8, strokeStart: 0, strokeEnd: 1)
        createCircleAndAddToView(progressCircle, view: countDownTimerView!, color: convertHexToUIColor(0x65, green: 0x7c, blue: 0x92), lineWidth: 8, strokeStart: 0, strokeEnd: 0)
        setTime()
        setUpExerciseImageAnimation(currentExercise)
        loadExerciseImage(currentExercise)
        startStopButton.tag = 0
        updateWorkoutName(currentExercise)
        updateNextWorkoutName(currentExercise)
    }
    
    // do an initial save of the workout index and date, to be used later by resume
//    func saveInitialWorkoutData() {
//        workoutDatabaseObject = NSEntityDescription.insertNewObjectForEntityForName("Workouts",inManagedObjectContext: self.managedObjectContext!) as? Workouts
//        workoutDatabaseObject!.date = NSDate()
//        workoutDatabaseObject!.workout_id = workoutIndex
//        workoutDatabaseObject!.completed = false
//        workoutDatabaseObject!.exercise_1_score = -1
//        workoutDatabaseObject!.exercise_2_score = -1
//        workoutDatabaseObject!.exercise_3_score = -1
//        workoutDatabaseObject!.exercise_4_score = -1
//        workoutDatabaseObject!.exercise_5_score = -1
//        workoutDatabaseObject!.exercise_run_score = -1
//        workoutDatabaseObject!.exercise_walk_score = -1
//        save()
//    }
    
//    func pickResumePlace(workout:Workouts) -> Int{
//        if(workout.exercise_1_score == -1) { return 1 }
//        if(workout.exercise_2_score == -1) { return 2 }
//        if(workout.exercise_3_score == -1) { return 3 }
//        if(workout.exercise_4_score == -1) { return 4 }
//        if(workout.exercise_5_score == -1) { return 5 }
//        if(workout.exercise_run_score == -1) { return 6 }
//        if(workout.exercise_walk_score == -1) { return 7 }
//        return 1
//    }
    
//    private func checkForAndHandleResume() {
//        let fetchRequest = NSFetchRequest(entityName: "Workouts")
//        fetchRequest.predicate = NSPredicate(format: "completed == false AND workout_id == %d",workoutIndex)
//        let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Workouts]
//        if(fetchResults?.count > 0) {
//            for workout in fetchResults! {
//                if(workout.workout_id.integerValue == workoutIndex && currentExercise == 1 && !exiting && !haveCheckedForResume) {
//                    if(workout.exercise_1_score != -1) { // if you have done at least the first exercise
//                        //Create an Alert for resume
//                        let title = "Resume?"
//                        let message = "Would you like to resume your last workout or start a new one? Starting a new workout will delete your uncompleted workout data."
//                        let alert = UIAlertController(title:title,message: message,preferredStyle: UIAlertControllerStyle.Alert)
//                        let newWorkoutAction = UIAlertAction(title: "Start a new workout", style: UIAlertActionStyle.Cancel, handler:{
//                            (UIAlertAction) -> Void in
//                            self.managedObjectContext!.deleteObject(workout)
//                            self.saveInitialWorkoutData()
//                        })
//                        let resumeAction = UIAlertAction(title: "Resume the old workout", style: UIAlertActionStyle.Default, handler:{
//                            (UIAlertAction) -> Void in
//                            workout.date = NSDate()
//                            self.currentExercise = self.pickResumePlace(workout)
//                            self.getReadyForNextExercise(self.currentExercise)
//                        })
//                        alert.addAction(newWorkoutAction)
//                        alert.addAction(resumeAction)
//                        
//                        presentViewController(alert, animated: true,completion: {})
//                        break
//                    } else {
//                        // you haven't even done the first exercise, so delete the old workout data gracefully and create new workout data
//                        self.managedObjectContext!.deleteObject(workout)
//                        self.saveInitialWorkoutData()
//                    }
//                }
//            }
//        } else {
//            saveInitialWorkoutData()
//        }
//        haveCheckedForResume = true
//    }
    
    func getReadyForNextExercise(nextExerciseToLoad:Int) {
        //print("\(nextExerciseToLoad)")
        handleSegementedControlForAlternateExercises(nextExerciseToLoad)
        clock.revertTimer(nextExerciseToLoad)
        updateNextWorkoutName(nextExerciseToLoad)
        loadExerciseImage(nextExerciseToLoad)
        setUpExerciseImageAnimation(nextExerciseToLoad)
        updateWorkoutName(nextExerciseToLoad)
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
        exerciseImage.stopAnimating()
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

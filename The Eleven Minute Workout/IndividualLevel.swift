//
//  PageItemController.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 4/14/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit
import StoreKit

class PageItemController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var userHasFullAccess:Bool = false
    var itemIndex:Int = 0
    var labelText:String = ""
    private var productID = "11MinuteWorkoutFullAccess"
    
    @IBOutlet weak var levelImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var workoutImage: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var exercise1: UILabel!
    @IBOutlet weak var exercise2: UILabel!
    @IBOutlet weak var exercise3: UILabel!
    @IBOutlet weak var exercise4: UILabel!
    @IBOutlet weak var exercise5: UILabel!
    
    @IBAction func beginWorkout(sender: UIButton) {
        if(userHasFullAccess || itemIndex == 0) {
            goToWorkout()
        } else {
            alertThatFullAccessIsNeeded()
        }
    }
    
    func goToWorkout() {
        performSegueWithIdentifier("startWorkoutSegue", sender:nil)
    }
    
    func restorePurchases() {
        if(SKPaymentQueue.canMakePayments()) {
            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        } else {
            alertUserThatPaymentsCannotBeMade()
        }
    }
    
    func alertUserThatPaymentsCannotBeMade() {
        let paymentsCannotBeMadeAlert = UIAlertController(title: "Payments cannot be made", message: "You do not have permission to make payments on this device. This can be due to parental controllers or not having a credit card on file.", preferredStyle:UIAlertControllerStyle.Alert)
        paymentsCannotBeMadeAlert.popoverPresentationController?.sourceView = self.view
        paymentsCannotBeMadeAlert.popoverPresentationController?.sourceRect = CGRectMake(0,0,1.0,1.0)
        paymentsCannotBeMadeAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(paymentsCannotBeMadeAlert, animated: true, completion: nil)
    }
    
    func alertUserThatThePaymentFailed() {
        let paymentsFailedAlert = UIAlertController(title: "Payment Failed", message: "Unfortunately, your payment has failed. Your credit card has not been charged. Please try again in a few minutes.", preferredStyle:UIAlertControllerStyle.Alert)
        paymentsFailedAlert.popoverPresentationController?.sourceView = self.view
        paymentsFailedAlert.popoverPresentationController?.sourceRect = CGRectMake(0,0,1.0,1.0)
        paymentsFailedAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(paymentsFailedAlert, animated: true, completion: nil)
    }
    
    func buyFullAccess() {
        if(SKPaymentQueue.canMakePayments()) {
            let productRequest = SKProductsRequest(productIdentifiers: NSSet(objects:productID) as! Set<String>) // as Set<NSObject>
            productRequest.delegate = self
            productRequest.start()
        } else {
            alertUserThatPaymentsCannotBeMade()
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if(response.products.count > 0) {
            let fullAccess = response.products[0] 
            SKPaymentQueue.defaultQueue().addPayment(SKPayment(product:fullAccess))
        } else {
            alertUserThatThePaymentFailed()
            print("no product information received from apple")
        }
    }
    
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch(transaction.transactionState) {
            case .Purchased, .Restored:
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "fullAccess")
                userHasFullAccess = true
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                goToWorkout()
            case .Failed:
                //alertUserThatThePaymentFailed()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func alertThatFullAccessIsNeeded() {
        let fullAccessAlert = UIAlertController(title:"Full Access Needed", message:"You need the full access pass for this workout. If you have already purchased the full access pass, click restore to activate it on this device.",preferredStyle:UIAlertControllerStyle.Alert)
        fullAccessAlert.popoverPresentationController?.sourceView = self.view
        fullAccessAlert.popoverPresentationController?.sourceRect = CGRectMake(0, 0, 1.0, 1.0)
        fullAccessAlert.addAction(UIAlertAction(title:"Restore",style:UIAlertActionStyle.Default,handler:{(Void)in
            self.restorePurchases()}))
        fullAccessAlert.addAction(UIAlertAction(title:"Get Full Access",style:UIAlertActionStyle.Default,handler:{(Void)in
            self.buyFullAccess()}))
        fullAccessAlert.addAction(UIAlertAction(title:"Cancel",style:UIAlertActionStyle.Cancel,handler:nil))
        self.presentViewController(fullAccessAlert, animated: true, completion:nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "startWorkoutSegue":
                if let countDownTimerController = segue.destinationViewController as? CountDownTimerViewController {
                    countDownTimerController.workoutIndex = itemIndex + 1
                    countDownTimerController.currentExercise = 1
                }
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentLabel?.text = labelText
        exercise1?.text = ExerciseNames.pickExerciseName(itemIndex + 1, exercise: 1)
        exercise2?.text = ExerciseNames.pickExerciseName(itemIndex + 1, exercise: 2)
        exercise3?.text = ExerciseNames.pickExerciseName(itemIndex + 1, exercise: 3)
        exercise4?.text = ExerciseNames.pickExerciseName(itemIndex + 1, exercise: 4)
        exercise5?.text = ExerciseNames.pickExerciseName(itemIndex + 1, exercise: 5)
        levelImage?.image = UIImage(named:"chart_"+String(itemIndex + 1)+"_exercise_5")
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //var workoutName:String = "chart_" + String(itemIndex + 1) + "_exercise_" + String(5)
        pageLabel.text = "\(itemIndex + 1)"+"/" + "6"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

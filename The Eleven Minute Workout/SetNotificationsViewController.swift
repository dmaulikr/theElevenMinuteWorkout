//
//  SetNotificationsViewController.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 5/19/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit

class SetNotificationsViewController: UIViewController {
    private var notificationsOff = true
    private var reminderLabel = "You have not set a daily reminder." {
        didSet {
            reminderSetLabel?.text = reminderLabel
        }
    }
    
    @IBOutlet weak var reminderSetLabel: UILabel! {
        didSet {
            reminderSetLabel.text = reminderLabel
        }
    }
    
    func getStringFromNotificationTimeDatePicker() -> String {
        let dateFormatter = NSDateFormatter()
        //dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return dateFormatter.stringFromDate(notificationTime.date)
    }
    
    @IBOutlet weak var notificationTime: UIDatePicker!
    @IBAction func changeNotificationTime(sender: UIDatePicker) {
        if(notificationsOff) {
            // alert that can't turn on
            displayNotificationsNotEnabledAlert()
        } else {
            if(dailyNotification.on) {
                setNotification()
            } else {
                dailyNotification.setOn(true, animated: true)
                setNotification()
            }
        }
    }
    
    func setNotification() {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        if(notifications.count > 0) {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        let notification = UILocalNotification()
        notification.fireDate = notificationTime.date
        notification.alertBody = "Consistency is key. It's time for your 11 minute workout!"
        notification.repeatInterval = NSCalendarUnit.Day
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        reminderLabel = "You have a daily reminder set for " + getStringFromNotificationTimeDatePicker()

    }
    
    @IBAction func dailyNotificationToggled(sender: UISwitch) {
        if(notificationsOff) {
            sender.setOn(false,animated: false)
            // alert that can't turn on
            displayNotificationsNotEnabledAlert()
        } else {
            if(sender.on) {
                setNotification()
            } else {
                // delete old notification
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                reminderLabel = "You do not have any reminders scheduled."

            }
        }
    }
    
    func setUpForCurrentNotificationSettings(currentNotificationSettings:UIUserNotificationSettings) {
        if(currentNotificationSettings.types != []) {
            notificationsOff = false
            // set current state for notification time and daily notification
            let notifications = UIApplication.sharedApplication().scheduledLocalNotifications!
            if(notifications.count > 0) {
                let notification = notifications[0]
                notificationTime.date = notification.fireDate!
                reminderLabel = "You have a daily reminder set for " + getStringFromNotificationTimeDatePicker()
                if(!dailyNotification.on) {
                    dailyNotification.setOn(true, animated: true)
                }
            } else {
                reminderLabel = "You have not set a daily reminder"
                if(dailyNotification.on) {
                    dailyNotification.setOn(false, animated: true)
                }
            }
            
        } else {
            reminderLabel = "You have not set a daily reminder"
            dailyNotification.setOn(false, animated: true)
            notificationsOff = true
        }

    }
    
    @objc private func notificationsCallback(notification:NSNotification) {
        setUpForCurrentNotificationSettings(notification.object as! UIUserNotificationSettings)
    }
    
    @IBOutlet weak var dailyNotification: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self,selector:"notificationsCallback:",name:"userHasSignedUpForNotifications",object:nil)
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        }
        setUpForCurrentNotificationSettings(UIApplication.sharedApplication().currentUserNotificationSettings()!)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayNotificationsNotEnabledAlert() {
        let title = "Notifications not enabled for this application"
        let message = "In order to use this feature you will need to enable notificiations for this application."
        let alert = UIAlertController(title:title,message: message,preferredStyle: UIAlertControllerStyle.Alert)
        let okayAction = UIAlertAction(title: "okay", style: UIAlertActionStyle.Default, handler:{
            (UIAlertAction) -> Void in
        })
        alert.addAction(okayAction)
        presentViewController(alert, animated: true,completion: {})
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

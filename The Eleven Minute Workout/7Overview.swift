//
//  SevenMinuteWorkoutOverviewViewController.swift
//  The Elven Minute Workout
//
//  Created by Whitney Powell on 2/11/16.
//  Copyright © 2016 Whitney Powell. All rights reserved.
//

import UIKit

class SevenMinuteWorkoutOverviewViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        //let cell = tableView.dequeueReusableCellWithIdentifier(")
//    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier! {
        case "workout 1":
            if let workout1 = sender?.destinationViewController as? SevenMinuteWorkoutViewController {
                workout1.id = (workout:1,exercise:1)
            }
        default:
            break
        }
    }
    

}

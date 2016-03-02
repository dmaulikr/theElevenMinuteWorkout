//
//  MainTableViewController.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 4/8/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    @IBOutlet weak var soundTableViewCell: UITableViewCell!
    
    struct SoundImageNames {
        static let soundOnImageName = "sound_on"
        static let soundOffImageName = "sound_off"
    }
    
    struct SoundTexts {
        static let soundOnText = "Sound effects on"
        static let soundOffText = "Sound effects off"
    }
    
    struct UserDefaultsStrings {
        static let soundUserDefault = "soundPreference"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let soundOn = userDefaults.stringForKey(UserDefaultsStrings.soundUserDefault){
            setSoundEffectsCell(soundOn)
        } else {
            userDefaults.setObject("yes", forKey: UserDefaultsStrings.soundUserDefault)
            setSoundEffectsTableViewCellForSoundBoolean(true)
        }
    }

    func setSoundEffectsCell(soundOn:String) {
        if(soundOn == "yes") {
            setSoundEffectsTableViewCellForSoundBoolean(true)
        } else {
            setSoundEffectsTableViewCellForSoundBoolean(false)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.section) {
        case 0:
            if(indexPath.row == 1) {
                toggleSound()
            }
        default:break
        }
    }
    
    func setImageAndTextOfTableViewCell(tableViewCell:UITableViewCell,newText:String,newImageName:String) {
        tableViewCell.textLabel?.text = newText
        tableViewCell.imageView?.image = UIImage(named:newImageName)
    }

    func setSoundEffectsTableViewCellForSoundBoolean(sound:Bool) {
        if(sound) {
            setImageAndTextOfTableViewCell(soundTableViewCell, newText: SoundTexts.soundOnText, newImageName: SoundImageNames.soundOnImageName)
        } else {
            setImageAndTextOfTableViewCell(soundTableViewCell, newText: SoundTexts.soundOffText, newImageName: SoundImageNames.soundOffImageName)
        }

    }
    
    func toggleSound() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        // check sound and react appropriately
        //if let soundOn = userDefaults.boolForKey(UserDefaultsStrings.soundUserDefault) as Bool? {
        if let soundOn = userDefaults.stringForKey(UserDefaultsStrings.soundUserDefault) {
            if(soundOn == "yes") {
                setSoundEffectsCell("no")
                userDefaults.setObject("no", forKey: UserDefaultsStrings.soundUserDefault)
            } else {
                setSoundEffectsCell("yes")
                userDefaults.setObject("yes", forKey: UserDefaultsStrings.soundUserDefault)
            }
            //setSoundEffectsTableViewCellForSoundBoolean(!soundOn)
            //userDefaults.setBool(!soundOn, forKey: UserDefaultsStrings.soundUserDefault)
        } else {
            if(soundTableViewCell.textLabel!.text == SoundTexts.soundOnText) {
                //userDefaults.setBool(false, forKey: UserDefaultsStrings.soundUserDefault)
                userDefaults.setObject("no", forKey: UserDefaultsStrings.soundUserDefault)
                setSoundEffectsTableViewCellForSoundBoolean(false)
            } else {
                userDefaults.setObject("yes", forKey: UserDefaultsStrings.soundUserDefault)
                setSoundEffectsTableViewCellForSoundBoolean(true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    @IBAction func goBackFromHelp(segue: UIStoryboardSegue) {}
    @IBAction func goBackFromProgress(segue: UIStoryboardSegue) {}

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 0
        }
    }
}

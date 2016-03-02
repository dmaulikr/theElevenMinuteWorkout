//
//  PlaylistViewController.swift
//  The Elven Minute Workout
//
//  Created by Whitney Powell on 9/10/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistViewController: UIViewController, MPMediaPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    var songs:[MPMediaItem] = [] {
        didSet {
            let persistentIds = self.songs.map{($0.valueForProperty(MPMediaItemPropertyPersistentID) as! NSNumber)}
            standardUserDefaults.setObject(persistentIds,forKey: persistentIdsUserDefaultsKey)
            songListTableView.reloadData()
        }
    }
    
//    @IBAction func shufflePlaylist(sender: UIButton) {
//        sender.selected = !sender.selected
//        if(MPMusicPlayerController.applicationMusicPlayer().shuffleMode == MPMusicShuffleMode.Default) {
//            MPMusicPlayerController.applicationMusicPlayer().shuffleMode = MPMusicShuffleMode.Songs
//        } else if(MPMusicPlayerController.applicationMusicPlayer().shuffleMode == MPMusicShuffleMode.Songs){
//            MPMusicPlayerController.applicationMusicPlayer().shuffleMode = MPMusicShuffleMode.Default
//        }
//    }
    @IBAction func editPlaylist(sender: UIButton) {
        sender.selected = !sender.selected
        if(songListTableView.editing) {
            songListTableView.setEditing(false, animated: true)
        } else {
            songListTableView.setEditing(true, animated: true)
        }
    }
    private let buttonPlayTag = 0
    private let buttonPauseTag = 1
    let songCellIdentifier = "song"
    let persistentIdsUserDefaultsKey = "persistentIds"
    let standardUserDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var PlayPauseButton: UIButton! {
        didSet {
            if(MPMusicPlayerController.applicationMusicPlayer().playbackState == MPMusicPlaybackState.Playing) {
                setButtonImageToPauseState(self.PlayPauseButton)
            } else {
                setButtonImageToPlayState(self.PlayPauseButton)
            }
        }
    }
    
    func setButtonImageToPauseState(button:UIButton) {
        button.setImage(UIImage(named:"pause"), forState: UIControlState.Normal)
    }
    
    func setButtonImageToPlayState(button:UIButton) {
        button.setImage(UIImage(named:"play"), forState: UIControlState.Normal)
    }
    
    
    @IBAction func PressedPlayPauseButton(button: UIButton) {
        let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
        if(musicPlayer.playbackState == MPMusicPlaybackState.Playing) {
            setButtonImageToPlayState(button)
            musicPlayer.pause()
        } else {
            setButtonImageToPauseState(button)
            musicPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: songs))
            musicPlayer.play()
        }
    }
    
    @IBOutlet weak var songListTableView: UITableView!
    @IBAction func addSong(sender: UIButton) {
        let mediaPickerController:MPMediaPickerController = MPMediaPickerController()
        mediaPickerController.delegate = self
        mediaPickerController.allowsPickingMultipleItems = false
        mediaPickerController.prompt = "Add a song to your playlist"
        mediaPickerController.showsCloudItems = false
        presentViewController(mediaPickerController, animated: true, completion: nil)
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        if(mediaItemCollection.count > 0) {
            let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
            musicPlayer.setQueueWithItemCollection(mediaItemCollection)
            let song = mediaItemCollection.items[0] 
            //let persistentID:NSNumber = song.valueForProperty(MPMediaItemPropertyPersistentID) as! NSNumber
            //let playbackDuration = song.valueForProperty(MPMediaItemPropertyPlaybackDuration) as! NSNumber
            songs.append(song)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getSongsFromPersistentIds(persistentIds:[NSNumber]) -> [MPMediaItem] {
        var songsFromIds:[MPMediaItem] = []
        for persistentId in persistentIds {
            let persistentIDPredicate = MPMediaPropertyPredicate(value:persistentId, forProperty:MPMediaItemPropertyPersistentID)
            let songsQuery = MPMediaQuery.songsQuery()
            songsQuery.addFilterPredicate(persistentIDPredicate)
            for song in songsQuery.items! {
                songsFromIds.append(song)
            }
        }
        return songsFromIds
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songListTableView.delegate = self
        songListTableView.dataSource = self
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let persistentIds = standardUserDefaults.objectForKey(persistentIdsUserDefaultsKey) as? [NSNumber]{
            songs = getSongsFromPersistentIds(persistentIds)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: - table view stuff
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = songListTableView.dequeueReusableCellWithIdentifier(songCellIdentifier, forIndexPath: indexPath) 
        cell.textLabel?.text = ((songs[indexPath.row]).valueForProperty(MPMediaItemPropertyTitle) as! String)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            songs.removeAtIndex(indexPath.row)
        } 
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let songToMove = songs[sourceIndexPath.row]
        songs.removeAtIndex(sourceIndexPath.row)
        songs.insert(songToMove, atIndex: destinationIndexPath.row)
        songListTableView.reloadData()
    }
    

    
    

    // MARK: - Navigation
    // A couple of variables to help us set everything back up when we return. I don't love this. I have to do the same thing for the exercise overview
    var exerciseIndex = 0
    var currentExerciseTime:Double = 0
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let workoutController = segue.destinationViewController as? CountDownTimerViewController {
            if(exerciseIndex <= 5) {
                workoutController.clock.elapsedTime = currentExerciseTime
            } else {
                workoutController.countUpTimer.elapsedTime = currentExerciseTime
            }
        }
    }

    
    
    

}

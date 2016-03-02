//
//  Workout.swift
//  The Elven Minute Workout
//
//  Created by Whitney Powell on 2/8/16.
//  Copyright © 2016 Whitney Powell. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

struct ElevenMinuteWorkoutPlistKeys {
    static let exerciseName:String = "Name"
    static let exerciseInstructions = "Instructions"
    static let length = "LengthInSeconds"
    static let minimumScoreForGrade = "MinimumScoreForGrade"
}

enum Errors : ErrorType {
    case PListFileNotFound
}

class Exercise {
    let groupId:Int
    let workoutId:Int
    let exerciseId:Int
    let name:String
    let instructions:String
    
    init(groupId:Int, workoutId:Int, exerciseId:Int) throws {
        self.groupId = groupId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        let sourceFilePath = NSBundle.mainBundle().pathForResource("G\(groupId)_W\(workoutId)_E\(exerciseId)", ofType: "plist")
        guard (NSFileManager.defaultManager()).fileExistsAtPath(sourceFilePath!) else {
            name = ""
            instructions = ""
            throw Errors.PListFileNotFound
        }
        let exerciseDataDictionary = NSDictionary(contentsOfFile: sourceFilePath!)
        self.name = exerciseDataDictionary!.valueForKey(ElevenMinuteWorkoutPlistKeys.exerciseName) as! String
        self.instructions = exerciseDataDictionary!.valueForKey(ElevenMinuteWorkoutPlistKeys.exerciseInstructions) as! String
    }
}


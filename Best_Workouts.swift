//
//  Best_Workouts.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 5/15/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import Foundation
import CoreData

class Best_Workouts: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var exercise_1_score: NSNumber
    @NSManaged var exercise_1_grade: String
    @NSManaged var exercise_2_score: NSNumber
    @NSManaged var exercise_2_grade: String
    @NSManaged var exercise_3_score: NSNumber
    @NSManaged var exercise_4_score: NSNumber
    @NSManaged var exercise_4_grade: String
    @NSManaged var exercise_3_grade: String
    @NSManaged var exercise_5_score: NSNumber
    @NSManaged var exercise_5_grade: String
    @NSManaged var exercise_run_grade: String
    @NSManaged var exercise_walk_grade: String
    @NSManaged var exercise_walk_score: NSNumber
    @NSManaged var exercise_run_score: NSNumber
    @NSManaged var date: NSDate

}

//
//  HowToUse.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 6/22/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit

class HowToUse: UIViewController {
    @IBOutlet weak var howToUseText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        howToUseText.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

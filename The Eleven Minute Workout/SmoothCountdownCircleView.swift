//
//  SmoothCountdownCircleView.swift
//  The Elven Minute Workout
//
//  Created by Whitney Powell on 2/17/16.
//  Copyright © 2016 Whitney Powell. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class SmoothCountdownCircleView:UIView {
    var workoutUsage:[Float] = [1,1,2,10,20,1]
    var colors = [UIColor.blueColor(),UIColor.redColor(),UIColor.greenColor(),UIColor.orangeColor(),UIColor.brownColor(),UIColor.blackColor()]

    override func drawRect(rect: CGRect) {
        let centerPoint = CGPoint(x:self.bounds.width/2, y:self.bounds.height/2)
        let decimalOfViewToFill:CGFloat = 0.8
        let radius:CGFloat = min(self.bounds.height/2, self.bounds.width/2) * decimalOfViewToFill
        
       
            let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle:0, endAngle:CGFloat(2*M_PI), clockwise: true)
            colors[0].setStroke()
            circlePath.lineWidth = 15
            circlePath.stroke()
        
        
       
//        let square = CAShapeLayer()
//        square.frame = CGRect(x: centerPoint.x, y: centerPoint.y, width: 20, height: 20)
//        square.backgroundColor = UIColor.greenColor().CGColor
//        square.dr

        
    }
}
//
//  CirclePercentageChart.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 5/6/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit

@IBDesignable class CirclePercentageChart: UIView {
    var workoutUsage:[Float] = [1,1,2,10,20,1]
    var colors = [UIColor.blueColor(),UIColor.redColor(),UIColor.greenColor(),UIColor.orangeColor(),UIColor.brownColor(),UIColor.blackColor()]
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let workoutTotal = workoutUsage.reduce(0, combine: +)
        let centerPoint = CGPoint(x:self.bounds.width/2, y:self.bounds.height/2)
        let decimalOfViewToFill:CGFloat = 0.8
        let radius:CGFloat = min(self.bounds.height/2, self.bounds.width/2) * decimalOfViewToFill

        if(workoutTotal > 0) {
            var lastEnd:CGFloat = 3.0 * CGFloat(M_PI/2)
            for (index,usage) in workoutUsage.enumerate() {
                if(usage != 0) {
                    let nextEnd = lastEnd + CGFloat(Float(M_PI)*2.0*Float((usage/workoutTotal)))
                    let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: lastEnd, endAngle: nextEnd, clockwise: true)
                    colors[index].setStroke()
                    circlePath.lineWidth = 15
                    lastEnd = nextEnd
                    circlePath.stroke()
                }
            }
        } else {
            let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle:0, endAngle:CGFloat(2*M_PI), clockwise: true)
            colors[0].setStroke()
            circlePath.lineWidth = 15
            circlePath.stroke()

        }
    }
}

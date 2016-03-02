//
//  VerticalBarChart.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 5/6/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit

@IBDesignable class VerticalBarChart: UIView {
    var scores:[Int] = [1,2,5,0,12]
    var yLabels = ["D-","D ","D+","C-","C ","C+","B-","B ","B+","A-","A ","A+"]
    var colors = [UIColor.blueColor(),UIColor.redColor(),UIColor.greenColor(),UIColor.orangeColor(),UIColor.brownColor(),UIColor.blackColor(),UIColor.yellowColor()]
    var dates = false
    var edgesColor = UIColor.brownColor()
    var edgeWidth:CGFloat = 4.0

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        clearSubviews()
        let chartHeight = self.bounds.height
        let chartWidth = self.bounds.width
        var textWidth:CGFloat = 0
        let maxPercentageOfGraphHeightToUse:CGFloat = 0.95
        let dashDistance = (chartHeight) * maxPercentageOfGraphHeightToUse
        let dash = UIBezierPath()
        let spaceBetweenDashes:CGFloat = dashDistance/CGFloat(yLabels.count)
        let dashLength:CGFloat = 4
        var nextDashYPosition = dashDistance - spaceBetweenDashes/2
        var greatestLabelWidth:CGFloat = 0
        let label = UILabel()
        label.text = yLabels[0]
        label.sizeToFit()
        let numberToShow:Int = Int(dashDistance/(label.frame.height*1.5))
        var everySo = 1
        if(numberToShow < 12) {
            everySo = 12/numberToShow
        }
        var counter:Int = 0
        for spot in 1...12 {
            counter++
            if(counter == everySo) {
                let label = UILabel()
                label.textAlignment = NSTextAlignment.Left
                label.text = yLabels[spot - 1]
                label.sizeToFit()
                label.center = CGPointMake(label.frame.width/2, nextDashYPosition)
                label.textColor = edgesColor
                textWidth = label.frame.width
                if(greatestLabelWidth < textWidth) { greatestLabelWidth = textWidth }
                self.addSubview(label)
                counter = 0
            }
            nextDashYPosition -= spaceBetweenDashes
        }
        let chartStart = greatestLabelWidth + 11
        nextDashYPosition = dashDistance - spaceBetweenDashes/2
        for _ in 1...12 {
            dash.moveToPoint(CGPoint(x: chartStart + dashLength, y: nextDashYPosition))
            dash.addLineToPoint(CGPoint(x:chartStart - dashLength,y: nextDashYPosition))
            nextDashYPosition -= spaceBetweenDashes
        }
        
        dash.lineWidth = 2.0
        edgesColor.setStroke()
        dash.stroke()
        let barWidth = (self.bounds.width - chartStart)/CGFloat((scores.count * 2) + 1)
        var barBottomLeftPoint = chartStart + barWidth
        for (index,score) in scores.enumerate() {
            var barHeight:CGFloat = 0.15 * spaceBetweenDashes // if score is 0, peak
            if(score != 0) {
                barHeight = CGFloat(score) * spaceBetweenDashes
            }
            let barRectangle:CGRect = CGRect(x:barBottomLeftPoint,y:chartHeight - barHeight - edgeWidth/2,width:barWidth,height:barHeight)
            let bar = UIBezierPath(rect: barRectangle)
            colors[index].setFill()
            bar.fill()
            barBottomLeftPoint += barWidth * 2
        }
        let edge = UIBezierPath()
        edge.moveToPoint(CGPoint(x:chartStart,y:0))
        edge.addLineToPoint(CGPoint(x:chartStart,y:chartHeight))
        edge.moveToPoint(CGPoint(x:chartStart,y:chartHeight))
        edge.addLineToPoint(CGPoint(x:chartWidth,y:chartHeight))
        edgesColor.setStroke()
        edge.lineWidth = edgeWidth
        edge.stroke()
    }
    
    func clearSubviews() {
        let subViews = self.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
    }

}

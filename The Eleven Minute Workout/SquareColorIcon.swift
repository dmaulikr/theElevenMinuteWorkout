//
//  SquareColorIcon.swift
//  The Eleven Minute Workout
//
//  Created by Whitney Powell on 5/6/15.
//  Copyright (c) 2015 Whitney Powell. All rights reserved.
//

import UIKit

@IBDesignable class SquareColorIcon: UIView {
    var cornerRadiiWidth = 4
    var cornerRadiiHeight = 4
    var color:UIColor = UIColor.orangeColor()
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let iconRectangle:CGRect = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        let iconPath = UIBezierPath(roundedRect: iconRectangle, byRoundingCorners: [.BottomLeft, .TopRight], cornerRadii: CGSize(width: cornerRadiiWidth, height:cornerRadiiHeight))
        color.setFill()
        iconPath.fill()
    }
}

//
//  BubbleView.swift
//  Workapp
//
//  Created by migueldiazrubio on 10/5/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit

enum BubbleViewDirection {
    case Up
    case Down
    case Left
    case Right
}

class BubbleView: UIView {
    
    var background : UIView = UIView()
    var arrowView : UIView = UIView()
    var label : UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }

    init(forFrame: CGRect, center: CGPoint, onView: UIView, text: String, color: UIColor, direction: BubbleViewDirection, arrow: Bool) {
        
        super.init(frame: CGRectZero)
        
        // Getting UILabel height for text
        let labelFont = UIFont(name: "Helvetica", size: 14.0)
        let labelHeight = heightForView(text, font: labelFont!, width: onView.frame.size.width)

        // Origin object info
        let objY = forFrame.origin.y
        let objHeight : CGFloat = forFrame.size.height
        
        // Frame info
        let frmWidth : CGFloat = onView.frame.width
        
        // Bubble info
        let alpha : CGFloat = 1.0
        let padding : CGFloat = 10
        let bubbleHeight = labelHeight + (padding * 2)
        let bubbleWidth = CGFloat(Int(frmWidth) - (Int(padding) * 2))
        let bubbleX : CGFloat = padding
        var bubbleY : CGFloat = 0

        var arrowY : CGFloat = 0
        let arrowSize : CGFloat = 10
        
        switch (direction) {

            case BubbleViewDirection.Up:
            
                bubbleY = CGFloat(objY + objHeight + padding )
                arrowY = bubbleY - 5
            
            case BubbleViewDirection.Down:
                
                bubbleY = CGFloat(objY - bubbleHeight - padding )
                arrowY = bubbleY + bubbleHeight - 5
            
            default:
            
                bubbleY = CGFloat()
        }

        background = UIView(frame: CGRectMake(bubbleX, bubbleY, bubbleWidth, bubbleHeight))
        background.backgroundColor = color
        background.layer.cornerRadius = (bubbleHeight / 8)
        background.hidden = false
        background.alpha = alpha
        
        self.frame = CGRectMake(0, 0, onView.frame.size.width, onView.frame.size.height)
        
        self.addSubview(background)
        
        if (arrow) {
            arrowView = UIView(frame: CGRectMake((center.x - 5), arrowY, arrowSize, arrowSize))
            arrowView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2/2));
            arrowView.backgroundColor = UIColor.whiteColor()
            arrowView.hidden = false
            arrowView.alpha = alpha
            
            self.addSubview(arrowView)
        }
        
        label = UILabel(frame: CGRectMake(bubbleX + (padding / 2), bubbleY + (padding / 2), bubbleWidth - padding, bubbleHeight - padding))
        label.font = labelFont
        label.textColor = UIColor.blackColor()
        label.numberOfLines = 3
        label.textAlignment = NSTextAlignment.Center
        label.text = text
        label.alpha = 1
        label.hidden = false
        
        self.addSubview(label)

    }
    
}

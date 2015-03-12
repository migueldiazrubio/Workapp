//
//  FirstViewController.swift
//  Workapp
//
//  Created by migueldiazrubio on 2/3/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet var titleConstraint : NSLayoutConstraint!
    @IBOutlet var descriptionContraint : NSLayoutConstraint!
    @IBOutlet var imageConstraint : NSLayoutConstraint!
    
    var stepTitle : String?
    var stepSubtitle : String?
    var stepImage : UIImage?
    
    var stepNumber : Int?
    
    var animate : Bool = true
    
    var parentPageViewController : DemoViewController!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let titulo = stepTitle {
            self.titleLabel.text = titulo
        }
        if let subtitulo = stepSubtitle {
            self.subtitleLabel.text = subtitulo
        }
        if let imagen = stepImage {
            self.imageView.image = imagen
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("nextView:"))
        
        self.view.addGestureRecognizer(tapGesture)
        
        if (self.animate) {
            self.titleLabel.alpha = 0.0
            self.subtitleLabel.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear(animated)
        
        if (self.animate) {
            self.titleLabel.alpha = 0.0
            self.subtitleLabel.alpha = 0.0
            self.imageConstraint.constant = -170
            self.view.layoutIfNeeded()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        parentPageViewController.currentPage = stepNumber!
    
        if (self.animate) {
            
            UIView.animateWithDuration(2.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                
                self.imageConstraint.constant = 0
                
                self.view.layoutIfNeeded()
                
                
            }, completion: { (Bool) -> Void in

                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    
                    self.titleLabel.alpha = 1.0
                    self.subtitleLabel.alpha = 1.0
                    
                    self.view.layoutIfNeeded()
                    
                    self.animate = false
                    
                    }, completion: nil)
            
            })
            
        }
        
    }
    
    func nextView(gesture: UITapGestureRecognizer) {
        parentPageViewController.nextView()
    }
        
}

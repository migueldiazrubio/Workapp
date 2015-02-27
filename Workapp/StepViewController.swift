//
//  StepViewController.swift
//  Workapp
//
//  Created by migueldiazrubio on 1/2/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit

class StepViewController: UIViewController {

    @IBOutlet var titleConstraint : NSLayoutConstraint!
    @IBOutlet var descriptionContraint : NSLayoutConstraint!
    @IBOutlet var imageConstraint : NSLayoutConstraint!
    
    var stepTitle : String?
    var stepSubtitle : String?
    var stepImage : UIImage?
    
    var stepNumber : Int?
    
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
        
        self.titleLabel.alpha = 0.0
        self.imageView.alpha = 0.0
        self.subtitleLabel.alpha = 0.0

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("viewWillAppear")
        
        self.titleLabel.alpha = 0.0
        self.imageView.alpha = 0.0
        self.subtitleLabel.alpha = 0.0
        
        if (stepNumber == 1 || stepNumber == 3) {
            self.titleConstraint.constant -= self.view.bounds.size.width
            self.descriptionContraint.constant += self.view.bounds.size.width
            self.imageConstraint.constant -= self.view.bounds.size.width
        } else {
            self.titleConstraint.constant += self.view.bounds.size.width
            self.descriptionContraint.constant -= self.view.bounds.size.width
            self.imageConstraint.constant += self.view.bounds.size.width
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {

        super.viewDidAppear(animated)
        
        println("viewDidAppear")
        
        parentPageViewController.currentPage = stepNumber!
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: nil, animations: { () -> Void in

            self.titleLabel.alpha = 1.0
            self.subtitleLabel.alpha = 1.0
            self.imageView.alpha = 1.0
            
            self.titleConstraint.constant = 0
            self.descriptionContraint.constant = 0
            self.imageConstraint.constant = 0
            
            self.view.layoutIfNeeded()
            
            }, completion: {
                (Bool) -> Void in
                
        })
        
    }
    
    func nextView(gesture: UITapGestureRecognizer) {
        parentPageViewController.nextView()
    }
    
    // Forzamos la orientación en vertical para el tutorial
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientation.Portrait.rawValue)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
}

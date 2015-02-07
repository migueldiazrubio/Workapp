//
//  FirstViewController.swift
//  Workapp
//
//  Created by migueldiazrubio on 1/2/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    var page = 2
    var parentPageViewController : DemoViewController!

    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapped (gesture :UITapGestureRecognizer) {
        parentPageViewController.navigateTo(page)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        parentPageViewController.currentPage = page
        
        println("viewDidAppear")
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            
            
        }, completion: nil)
        
    }
    
    // Forzamos la orientación en vertical para el tutorial
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientation.Portrait.rawValue)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

}

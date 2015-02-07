//
//  ExitViewController.swift
//  Workapp
//
//  Created by migueldiazrubio on 1/2/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit

class ExitViewController: UIViewController {

    var page = 5
    var parentPageViewController : DemoViewController!

    @IBAction func exit() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(false, forKey: "showTutorial")
        userDefaults.synchronize()
        
        dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapped (gesture :UITapGestureRecognizer) {
        exit()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        parentPageViewController.currentPage = page
    }
    
    // Forzamos la orientación en vertical para el tutorial
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientation.Portrait.rawValue)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

}

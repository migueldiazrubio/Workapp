//
//  MyStatsViewController.swift
//  Workapp
//
//  Created by migueldiazrubio on 9/5/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit

class MyStatsViewController: UIViewController {
    
    @IBOutlet weak var lblValueToday: UILabel!
    @IBOutlet weak var lblValueThisWeek: UILabel!
    @IBOutlet weak var lblValueLastWeek: UILabel!
    
    @IBOutlet weak var lblToday: UILabel!
    @IBOutlet weak var lblThisWeek: UILabel!
    @IBOutlet weak var lblLastWeek: UILabel!
    
    var color : UIColor = UIColor()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = color
    }
    
    @IBAction func closeStats() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        lblToday.text = NSLocalizedString("stats_today", comment: "")
        lblThisWeek.text = NSLocalizedString("stats_thisweek", comment: "")
        lblLastWeek.text = NSLocalizedString("stats_lastweek", comment: "")
        
        lblValueToday.text = String(PomodoroManager.sharedInstance.todayPomodoros())
        
    }

}

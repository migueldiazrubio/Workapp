//
//  AppDelegate.swift
//  Workapp
//
//  Created by migueldiazrubio on 11/1/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let pomodoroManager = PomodoroManager.sharedInstance
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        pomodoroManager.promptForNotificationPermissions()
        loadData()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
        
        showDemoViewController()
        
        return true
    }
    
    func showMainViewController() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewControllerWithIdentifier("viewController") as! ViewController
        
        self.window?.rootViewController = mainVC
        
    }
    
    func showDemoViewController() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var showTutorial : Bool?
        
        if let flagValue = userDefaults.objectForKey("showTutorial") as? Bool {
            showTutorial = flagValue
        } else {
            showTutorial = true
        }
        
        if (showTutorial!) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let demoVC = storyboard.instantiateViewControllerWithIdentifier("demoViewController") as! DemoViewController
            
            self.window?.rootViewController = demoVC
        }
        
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        saveData()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        saveData()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        saveData()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        loadData()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        loadData()
        showDemoViewController()
    }
    
    // Save and restore methods
    
    func saveData() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(pomodoroManager.pomodoroMinutes, forKey: "pomodoroMinutes")
        
        userDefaults.setObject(pomodoroManager.breakMinutes, forKey: "breakMinutes")
        
        userDefaults.setObject(pomodoroManager.pomodoroColor, forKey: "pomodoroColor")
        userDefaults.setObject(pomodoroManager.breakColor, forKey: "breakColor")
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    
    func loadData() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        var pomodoroMins : Int? = userDefaults.objectForKey("pomodoroMinutes") as! Int?
        var breakMins : Int? = userDefaults.objectForKey("breakMinutes") as! Int?
        var pomodoroColor : Int? = userDefaults.objectForKey("pomodoroColor") as! Int?
        var breakColor : Int? = userDefaults.objectForKey("breakColor") as! Int?
        
        if (pomodoroMins == nil || breakMins == nil || pomodoroColor == nil || breakColor == nil) {
            pomodoroManager.pomodoroMinutes = 25
            pomodoroManager.breakMinutes = 5
            pomodoroManager.pomodoroColor = 3
            pomodoroManager.breakColor = 6
            saveData()
        } else {
            pomodoroManager.pomodoroMinutes = pomodoroMins!
            pomodoroManager.breakMinutes = breakMins!
            pomodoroManager.pomodoroColor = pomodoroColor!
            pomodoroManager.breakColor = breakColor!
        }
        
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        // Antes de ejecutar la acción seleccionada
        // contabilizo el pomodoro o break
        if let type = notification.userInfo?["type"] as? String {
            if (type == "pomodoro") {
                pomodoroManager.pomodoroFinished()
            } else {
                pomodoroManager.breakFinished()
            }
        }
        
        if notification.category == "POMODORO_CATEGORY" {
            
            if identifier == "POMODORO_ACTION" {
                pomodoroManager.breakTime = false
            }
            
            if identifier == "BREAK_ACTION" {
                pomodoroManager.breakTime = true
            }
            
            pomodoroManager.stop()
            pomodoroManager.start()
        }
        
        completionHandler()
        
    }
    
}


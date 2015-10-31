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
        
        if #available(iOS 9.0, *) {
            configureQuickActions()
        }
        
        return true
    }
    
    func showMainViewController() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewControllerWithIdentifier("viewController") as! ViewController
        
        self.window?.rootViewController = mainVC
        
    }
    
    func showDemoViewController() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var showWalkThrough : Bool?
        
        if let flagValue = userDefaults.objectForKey("showWalkThrough") as? Bool {
            showWalkThrough = flagValue
        } else {
            showWalkThrough = true
        }
        
        if (showWalkThrough!) {
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
        
        pomodoroManager.timer.invalidate()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(pomodoroManager.pomodoroMinutes, forKey: "pomodoroMinutes")
        
        userDefaults.setObject(pomodoroManager.breakMinutes, forKey: "breakMinutes")
        
        userDefaults.setObject(pomodoroManager.pomodoroColor, forKey: "pomodoroColor")
        userDefaults.setObject(pomodoroManager.breakColor, forKey: "breakColor")
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
        if #available(iOS 9.0, *) {
            configureQuickActions()
        }
    }
    
    func loadData() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let pomodoroMins : Int? = userDefaults.objectForKey("pomodoroMinutes") as! Int?
        let breakMins : Int? = userDefaults.objectForKey("breakMinutes") as! Int?
        let pomodoroColor : Int? = userDefaults.objectForKey("pomodoroColor") as! Int?
        let breakColor : Int? = userDefaults.objectForKey("breakColor") as! Int?
        
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
                startPomodoro()
            }
            
            if identifier == "BREAK_ACTION" {
                startBreaktime()
            }
            
        }
        completionHandler()
    }
    
    func startPomodoro() {
        pomodoroManager.breakTime = false
        pomodoroManager.stop()
        pomodoroManager.start()
    }
    func startBreaktime() {
        pomodoroManager.breakTime = true
        pomodoroManager.stop()
        pomodoroManager.start()
    }
    
    // Quick Actions for 3D Touch
    @available(iOS 9.0, *)
    func configureQuickActions() {

        // New normal pomodoro
        let newPomodoro25ShortcutType = "com.migueldiazrubio.Workapp.newPomodoro25"
        let newPomodoro25ShortcutItem = UIApplicationShortcutItem(
            type: newPomodoro25ShortcutType,
            localizedTitle: NSLocalizedString("quickactions_newpomodoro", comment: ""),
            localizedSubtitle: NSLocalizedString("quickactions_newpomodoro_subtitle25", comment: ""),
            icon: UIApplicationShortcutIcon(templateImageName: "pomodoro_25"),
            userInfo: nil)
        
        // New short pomodoro
        let newPomodoro15ShortcutType = "com.migueldiazrubio.Workapp.newPomodoro15"
        let newPomodoro15ShortcutItem = UIApplicationShortcutItem(
                type: newPomodoro15ShortcutType,
                localizedTitle: NSLocalizedString("quickactions_newpomodoro", comment: ""),
                localizedSubtitle: NSLocalizedString("quickactions_newpomodoro_subtitle15", comment: ""),
                icon: UIApplicationShortcutIcon(templateImageName: "pomodoro_15"),
                userInfo: nil)

        // Change to breaktime / pomodoro
        
        var shortcutTitle = ""
        var shortcutSubtitle = ""
        
        if (pomodoroManager.breakTime) {
            shortcutTitle = NSLocalizedString("quickactions_cancel_break", comment: "")
            shortcutSubtitle = NSLocalizedString("quickactions_cancel_break_subtitle", comment: "")
        } else {
            shortcutTitle = NSLocalizedString("quickactions_cancel_pomodoro", comment: "")
            shortcutSubtitle = NSLocalizedString("quickactions_cancel_pomodoro_subtitle", comment: "")
        }

        let changeShortcutType = "com.migueldiazrubio.Workapp.changeMode"
        let changeShortcutItem = UIApplicationShortcutItem(
                    type: changeShortcutType,
                    localizedTitle: shortcutTitle,
                    localizedSubtitle: shortcutSubtitle,
                    icon: UIApplicationShortcutIcon(templateImageName: "changemode"),
                    userInfo: nil)
        
        UIApplication.sharedApplication().shortcutItems =
            [ newPomodoro25ShortcutItem, newPomodoro15ShortcutItem]
        
        if pomodoroManager.counting {
            UIApplication.sharedApplication().shortcutItems?.append(changeShortcutItem)
        }
        
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication,
        performActionForShortcutItem
        shortcutItem: UIApplicationShortcutItem,
        completionHandler: (Bool) -> Void) {

        switch shortcutItem.type {
        case "com.migueldiazrubio.Workapp.newPomodoro25":
            pomodoroManager.pomodoroMinutes = 25
            saveData()
            startPomodoro()
        case "com.migueldiazrubio.Workapp.newPomodoro15":
            pomodoroManager.pomodoroMinutes = 15
            saveData()
            startPomodoro()
        case "com.migueldiazrubio.Workapp.changeMode":
            if pomodoroManager.breakTime {
                startPomodoro()
                    } else {
                        startBreaktime()
            }
        default: break
        }
        
        completionHandler(true)
    }
    
    
}


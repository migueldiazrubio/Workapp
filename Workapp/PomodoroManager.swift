//
//  PomodoroManager.swift
//  Workapp
//
//  Created by migueldiazrubio on 15/1/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox
import AVFoundation
import GameKit

class PomodoroManager {
    
    var pomodoroMinutes : Int!
    var breakMinutes : Int!
    var breakLongMinutes : Int!
    
    var pomodoroColor : Int?
    var breakColor : Int?
    
    var breakTime : Bool = false
    var counting : Bool = false
    
    let managedObjectContext = CoreDataStack().context
    
    var timer = NSTimer()
    var remainSeconds : Int = 0
    
    var audioPlayer = AVAudioPlayer()
    
    class var sharedInstance: PomodoroManager {
        struct Static {
            static var instance: PomodoroManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = PomodoroManager()
        }
        
        return Static.instance!
    }
    
    // Timer methods
    func start() {
        counting = true
        registerLocalNotification()
    }
    
    func stop() {
        // Paramos el Timer
        timer.invalidate()
        
        counting = false
        
        if breakTime {
            remainSeconds = breakMinutes * 60
        } else {
            remainSeconds = pomodoroMinutes * 60
        }
        
        // Cancelamos todas las notificaciones locales
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    // Model methods
    func thisWeekPomodoros() -> Int {
        
//        let today = NSDate()
//        let gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)
//        gregorian?.locale = NSLocale.currentLocale()
//        
//        let nowComponents =
//        nowComponents.weekday = 1
//        nowComponents.hour = 0
//        nowComponents.minute = 0
//        nowComponents.second = 0
//        
//        let monday = gregorian?.dateFromComponents(nowComponents)
//        
//        nowComponents.weekday = 7
//        
//        let sunday = gregorian?.dateFromComponents(nowComponents)
//        
//        let beginDate = monday
//        
//        let endDate = sunday
//        
//        let fetchRequest = NSFetchRequest(entityName: "Pomodoro")
//        
//        let predicate = NSPredicate(format: "date >= %@ and date <= %@", beginDate, endDate)
//        fetchRequest.predicate = predicate
//        
//        var error : NSError?
//        
//        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
//        
//        if let results = fetchedResults {
//            return results.count
//        } else {
//            println("Could not find recors for Pomodoros entity")
//            return 0
//        }
        return 0
    }
    
    func lastWeekPomodoros() -> Int {
        
        let cal: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let beginTodayDate: NSDate = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())!
        
        let endTodayDate: NSDate = cal.dateBySettingHour(23, minute: 59, second: 59, ofDate: NSDate(), options: NSCalendarOptions())!
        
        let fetchRequest = NSFetchRequest(entityName: "Pomodoro")
        
        let predicate = NSPredicate(format: "date >= %@ and date <= %@", beginTodayDate, endTodayDate)
        fetchRequest.predicate = predicate
        
        var error : NSError?
        
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            return results.count
        } else {
            println("Could not find recors for Pomodoros entity")
            return 0
        }
    }
    
    func todayPomodoros() -> Int {
        
        let cal: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let beginTodayDate: NSDate = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())!
        
        let endTodayDate: NSDate = cal.dateBySettingHour(23, minute: 59, second: 59, ofDate: NSDate(), options: NSCalendarOptions())!
        
        let fetchRequest = NSFetchRequest(entityName: "Pomodoro")
        
        let predicate = NSPredicate(format: "date >= %@ and date <= %@", beginTodayDate, endTodayDate)
        fetchRequest.predicate = predicate
        
        var error : NSError?
        
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            return results.count
        } else {
            println("Could not find recors for Pomodoros entity")
            return 0
        }
    }
    
    func breakFinished() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func remainNextLocalNotification() {
        
        let notificationsArray = UIApplication.sharedApplication().scheduledLocalNotifications
        
        if (notificationsArray.count > 0) {
            
            let notification : UILocalNotification = notificationsArray.first as! UILocalNotification
            
            // Calculamos los segundos que quedan para que se dispare
            if let notificationRemainSeconds = notification.fireDate?.timeIntervalSinceNow {
                
                self.remainSeconds = Int(notificationRemainSeconds)
            }
            
        }
        
    }
    
    func pomodoroFinished() {
        
        // Insert pomodoro with pomodoroMinutes and NSDate
        let entity = NSEntityDescription.entityForName("Pomodoro", inManagedObjectContext: managedObjectContext)
        
        var pomodoro = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        
        pomodoro.setValue(pomodoroMinutes, forKey: "length")
        pomodoro.setValue(NSDate(), forKey: "date")
        
        var error : NSError?
        if !managedObjectContext.save(&error) {
            println("Error saving Core Data model")
        } else {
            
            var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("workapp", ofType: "mp3")!)
            
            var error:NSError?
            audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            reportCurrentPomodorosGameCenter()
        }
        
        updateBadgeIcon()
    }
    
    func updateBadgeIcon() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = todayPomodoros()
    }
    
    // Local Notification methods
    func promptForNotificationPermissions() {
        
        // Creamos las acciones para las notificaciones
        var breakAction = UIMutableUserNotificationAction()
        breakAction.identifier = "BREAK_ACTION"
        breakAction.title = NSLocalizedString("breakAction", comment: "")
        breakAction.activationMode = UIUserNotificationActivationMode.Background
        breakAction.destructive = false
        breakAction.authenticationRequired = false
        
        var pomodoroAction = UIMutableUserNotificationAction()
        pomodoroAction.identifier = "POMODORO_ACTION"
        pomodoroAction.title = NSLocalizedString("pomodoroAction", comment: "")
        pomodoroAction.activationMode = UIUserNotificationActivationMode.Background
        pomodoroAction.destructive = false
        pomodoroAction.authenticationRequired = false
        
        var notificationCategory = UIMutableUserNotificationCategory()
        notificationCategory.identifier = "POMODORO_CATEGORY"
        
        notificationCategory.setActions([breakAction,pomodoroAction], forContext: UIUserNotificationActionContext.Default)
        
        var categories = NSSet(objects: notificationCategory)
        
        let types = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
        
        let mySettings = UIUserNotificationSettings(forTypes: types, categories: categories as Set)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        
    }
    
    func registerLocalNotification() {
        
        let notification = UILocalNotification()
        
        notification.fireDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(remainSeconds))
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.applicationIconBadgeNumber = 0;
        notification.soundName = "workapp.mp3"
        
        notification.category = "POMODORO_CATEGORY"
        
        if (breakTime) {
            notification.alertBody = NSLocalizedString("breakBody", comment: "")
            notification.userInfo = ["type": "break"]
        } else {
            notification.alertBody = NSLocalizedString("pomodoroBody", comment: "")
            notification.userInfo = ["type": "pomodoro"]
        }
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        // TODO: Aqui habría que guardar en disco el fireDate
        
    }
    
    func reportCurrentPomodorosGameCenter() {
        
        let score : GKScore = GKScore(leaderboardIdentifier: "losmasproductivos")
        score.value = (Int64)(self.todayTotalMinutes())
        score.context = 0
        
        GKScore.reportScores([score], withCompletionHandler: { (error) -> Void in
            println("Enviado el record a Game Center")
        })
        
    }
    
    func deleteTodayData() {
        
        let cal: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let beginTodayDate: NSDate = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())!
        
        let endTodayDate: NSDate = cal.dateBySettingHour(23, minute: 59, second: 59, ofDate: NSDate(), options: NSCalendarOptions())!
        
        let fetchRequest = NSFetchRequest(entityName: "Pomodoro")
        
        let predicate = NSPredicate(format: "date >= %@ and date <= %@", beginTodayDate, endTodayDate)
        
        fetchRequest.predicate = predicate
        
        var error : NSError?
        
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            
            for elem in results {
                managedObjectContext.deleteObject(elem as NSManagedObject)
            }
            
            managedObjectContext.save(nil)

        } else {
            println("Could not delete recors for Pomodoros entity")
        }

        updateBadgeIcon()
        
    }
    
    func deleteAllData() {

        let fetchRequest = NSFetchRequest(entityName: "Pomodoro")
        
        var error : NSError?
        
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            
            for elem in results {
                managedObjectContext.deleteObject(elem as NSManagedObject)
            }
            managedObjectContext.save(nil)
            
        } else {
            println("Could not delete recors for Pomodoros entity")
        }
        
        updateBadgeIcon()
        
    }
    
    func todayTotalMinutes() -> Int {
        
        let cal: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let beginTodayDate: NSDate = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: NSCalendarOptions())!
        
        let endTodayDate: NSDate = cal.dateBySettingHour(23, minute: 59, second: 59, ofDate: NSDate(), options: NSCalendarOptions())!
        
        let fetchRequest = NSFetchRequest(entityName: "Pomodoro")
        
        let predicate = NSPredicate(format: "date >= %@ and date <= %@", beginTodayDate, endTodayDate)
        
        fetchRequest.predicate = predicate
        
        var error : NSError?
        
        let fetchedResults = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            
            var totalMinutes : Int = 0
            
            for elem in results {
                totalMinutes += elem.valueForKey("length") as! Int
            }
            
            return totalMinutes
            
        } else {
            println("Could not retrieve recors for today work minutes")
        }
        
        return 0
        
    }

}

//
//  ViewController.swift
//  Workapp
//
//  Created by migueldiazrubio on 11/1/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController, GKGameCenterControllerDelegate {
    
    // Animation
    var animator:UIDynamicAnimator!
    var snapBehaviour:UISnapBehavior!
    var tutorialBackgroundView : UIView!
    var tutorialView : UIView!
    
    var colours : NSArray!
    var originalMinutes = 0
    var pomodoroManager = PomodoroManager.sharedInstance
    var clockTimer : NSTimer?
    
    var gameCenterEnabled : Bool = false
    
    var tutorial : Bool = false
    var tutorialStep : Int = 0
    
    @IBOutlet weak var gameCenterButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var todayButton: UIButton!
    
    func startStop(gesture : UITapGestureRecognizer) {
        
        if (pomodoroManager.counting) {
            
            resetTimer()
            pomodoroManager.stop()
            pomodoroManager.counting = false
            
        } else {
            
            pomodoroManager.start()
            pomodoroManager.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimer:"), userInfo: nil, repeats: true)
            pomodoroManager.counting = true

        }
        
    }
    
    func resetTimer() {
        
        var strPomodoroMinutes = ""
        if (pomodoroManager.breakTime) {
            strPomodoroMinutes = String(format: "%02d", pomodoroManager.breakMinutes)
        } else {
            strPomodoroMinutes = String(format: "%02d", pomodoroManager.pomodoroMinutes)
        }
        
        timerLabel.text = "\(strPomodoroMinutes):00"
        pomodoroManager.stop()
        pomodoroManager.counting = false
        
    }
    
    func updateLeaderboard() {
        var todayPomodoros = pomodoroManager.todayPomodoros()
        
        if (todayPomodoros > 0) {
            var label = "\(todayPomodoros) "

            if (todayPomodoros == 1) {
                label = label.stringByAppendingString(NSLocalizedString("today_session", comment: ""))
            } else {
                label = label.stringByAppendingString(NSLocalizedString("today_sessions", comment: ""))
            }
            
            label = label.stringByAppendingString(timeElapsedString())
            todayButton.setTitle(label, forState: UIControlState.Normal)
        } else {
            todayButton.setTitle(NSLocalizedString("today_nothing", comment: ""), forState: UIControlState.Normal)
        }
    }
    
    func timeElapsedString() -> String {
        let todayTotalMinutes = pomodoroManager.todayTotalMinutes()

        var hours : String = String(todayTotalMinutes / 60)
        var minutes : String = String(format: "%02d", (todayTotalMinutes % 60))
        
        return " (\(hours):\(minutes))"
    }
    
    func updateTimer(timer: NSTimer) {
        
        pomodoroManager.remainSeconds -= 1
        
        if (pomodoroManager.remainSeconds == 0) {
            
            if (pomodoroManager.breakTime) {
                
                // Se ha completado el descanso
                pomodoroManager.breakFinished()
                switchToPomodoro(true)
                
            } else {
                
                // Se ha completado correctamente un pomodoro
                pomodoroManager.pomodoroFinished()
                switchToBreakTime(true)
                
            }
            
            resetTimer()
            
        }
        
        let minutes : Int = pomodoroManager.remainSeconds / 60
        let seconds : Int = pomodoroManager.remainSeconds % 60
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        timerLabel.text = "\(strMinutes):\(strSeconds)"
        
    }
    
    func switchToPomodoro(animation: Bool) {
        
        modeButton.setTitle(NSLocalizedString("mode_working", comment: ""), forState: UIControlState.Normal)

        pomodoroManager.breakTime = false
        
        if (animation) {
            UIView.animateWithDuration(1, animations: { () -> Void in
                if let color = self.pomodoroManager.pomodoroColor {
                    self.view.backgroundColor = self.colours[color] as? UIColor
                }
            })
        } else {
            if let color = self.pomodoroManager.pomodoroColor {
                self.view.backgroundColor = self.colours[color] as? UIColor
            }
        }
        
        updateLeaderboard()
        
    }
    
    func switchToBreakTime(animation: Bool) {

        modeButton.setTitle(NSLocalizedString("mode_resting", comment: ""), forState: UIControlState.Normal)

        pomodoroManager.breakTime = true
        
        if (animation) {
            UIView.animateWithDuration(1, animations: { () -> Void in
                if let color = self.pomodoroManager.breakColor {
                    self.view.backgroundColor = self.colours[color] as? UIColor
                }
            })
        } else {
            if let color = self.pomodoroManager.breakColor {
                self.view.backgroundColor = self.colours[color] as? UIColor
            }
        }
        
        updateLeaderboard()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
        clockLabel.hidden = true
        if let timer = clockTimer {
            timer.invalidate()
        }
        clockTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateClock:"), userInfo: nil, repeats: true)
        
        pomodoroManager.updateBadgeIcon()
        
        updateLeaderboard()
        
        showHideControls()
        
        connectToGameKit()
        
    }
    
    override func viewDidLoad() {
        
        // Animator
        animator = UIDynamicAnimator(referenceView: self.view)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        resetTimer()
        
        updateLeaderboard()
        
        // Colours
        colours = [
            UIColor(red: 149.0/255.0, green: 165.0/255.0, blue: 166.0/255.0, alpha: 1.0),
            UIColor(red: 241.0/255.0, green: 196.0/255.0, blue: 15.0/255.0,  alpha: 1.0),
            UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0,  alpha: 1.0),
            UIColor(red: 231.0/255.0, green: 76.0/255.0,  blue: 60.0/255.0,  alpha: 1.0),
            UIColor(red: 26.0/255.0,  green: 188.0/255.0, blue: 156.0/255.0, alpha: 1.0),
            UIColor(red: 46.0/255.0,  green: 204.0/255.0, blue: 113.0/255.0, alpha: 1.0),
            UIColor(red: 52.0/255.0,  green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0),
            UIColor(red: 155.0/255.0, green: 89.0/255.0,  blue: 182.0/255.0, alpha: 1.0),
            UIColor(red: 52.0/255.0,  green: 73.0/255.0,  blue: 94.0/255.0,  alpha: 1.0),
            UIColor(red: 149.0/255.0, green: 165.0/255.0, blue: 166.0/255.0, alpha: 1.0)]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("appActive:"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("appActive:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        let colorGesture = UIPanGestureRecognizer(target: self, action: Selector("colorGesture:"))
        self.view.addGestureRecognizer(colorGesture)
        
        let timerGesture = UIPanGestureRecognizer(target: self, action: Selector("timerGesture:"))
        self.timerLabel.addGestureRecognizer(timerGesture)
        
        //TODO: Hacer que el gesto de cambiar los minutos solo funcione sobre el UILabel
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("startStop:"))
        self.timerLabel.addGestureRecognizer(tapGesture)
        
        if let color = self.pomodoroManager.pomodoroColor {
            self.view.backgroundColor = self.colours[color] as? UIColor
        }
        
        pomodoroManager.updateBadgeIcon()

        modeButton.setTitle(NSLocalizedString("mode_working", comment: ""), forState: UIControlState.Normal)
        
        // Configuramos las dos acciones del Today Button
        let gameCenterTapGesture = UITapGestureRecognizer(target: self, action: Selector("gameCenterTap:"))
        let todayTapGesture = UITapGestureRecognizer(target: self, action: Selector("todayTap:"))
        gameCenterButton.addGestureRecognizer(gameCenterTapGesture)
        todayButton.addGestureRecognizer(todayTapGesture)
        
    }
    
    func gameCenterTap(gesture : UITapGestureRecognizer) {
        
        // Abrimos el Game Center

        var gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        
        self.presentViewController(gcViewController, animated: true, completion: nil)
        
    }
    func todayTap(gesture : UITapGestureRecognizer) {
        
        // Abrimos un menu contextual para borrar el histórico de hoy o de siempre
        let optionMenu = UIAlertController(title: nil, message: NSLocalizedString("history_label", comment: ""), preferredStyle: .ActionSheet)

        let deleteTodayAction = UIAlertAction(title: NSLocalizedString("history_delete_today", comment: ""), style: UIAlertActionStyle.Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.pomodoroManager.deleteTodayData()
            self.updateLeaderboard()
        })
        
        let deleteAlltimeAction = UIAlertAction(title: NSLocalizedString("history_delete_all", comment: ""), style: UIAlertActionStyle.Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.pomodoroManager.deleteAllData()
            self.updateLeaderboard()
        })

        let cancelAction = UIAlertAction(title: NSLocalizedString("history_cancel", comment: ""), style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(deleteTodayAction)
        optionMenu.addAction(deleteAlltimeAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    
    func appActive(notification : NSNotification) {
        
        // TODO: Aqui habría que recuperar de disco el fireDate
        // y actualizar el contador en consecuencia
        if (pomodoroManager.breakTime) {
            switchToBreakTime(false)
        } else {
            switchToPomodoro(false)
        }
        
        let scheduledLocalNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
        
        // Si no hay notificaciones programadas en curso
        if (scheduledLocalNotifications.isEmpty) {
            // Si el cronometro tiene el contador activado
            if (pomodoroManager.counting) {
                
                // Ha llegado la notificación pero se ha
                // abierto la app sin utilizarla. Contabilizamos
                // el pomodoro o break según corresponda
                pomodoroManager.counting = false
                if (pomodoroManager.breakTime) {
                    pomodoroManager.breakFinished()
                    switchToPomodoro(true)
                } else {
                    pomodoroManager.pomodoroFinished()
                    switchToBreakTime(true)
                }
            } else {
                
                // Si el cronometro estaba parado
                resetTimer()
                if (pomodoroManager.breakTime) {
                    switchToBreakTime(true)
                } else {
                    switchToPomodoro(true)
                }
            }
        } else {
            
            // Actualizamos el timer en base a la notificación
            if let fireDate = scheduledLocalNotifications.last?.fireDate {
                pomodoroManager.remainSeconds = Int(fireDate.timeIntervalSinceNow)
            }
            
            if (pomodoroManager.counting) {
                pomodoroManager.timer.invalidate()
                updateTimer(pomodoroManager.timer)
                pomodoroManager.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimer:"), userInfo: nil, repeats: true)
            }
            
        }
        
        pomodoroManager.updateBadgeIcon()
        updateLeaderboard()
        
    }
    
    // Touches methods
    func colorGesture (gesture : UIPanGestureRecognizer) {
        
        if (gesture.numberOfTouches() == 2) {
            
            if (!pomodoroManager.counting) {
                
                // Changing background color
                let position = gesture.locationInView(self.view).y
                let maxHeight = self.view.frame.size.height
                var percentage = Int((position / maxHeight) * 10)
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.view.backgroundColor = self.colours[percentage] as? UIColor
                })
                
                if (pomodoroManager.breakTime) {
                    pomodoroManager.breakColor = percentage
                } else {
                    pomodoroManager.pomodoroColor = percentage
                }
                
            }
            
        }
    }
    
    func timerGesture (gesture : UIPanGestureRecognizer) {
        
        if (gesture.state == UIGestureRecognizerState.Began) {
            if (!pomodoroManager.counting) {
                if (gesture.numberOfTouches() == 1) {
                    if (pomodoroManager.breakTime) {
                        originalMinutes = pomodoroManager.breakMinutes
                    } else {
                        originalMinutes = pomodoroManager.pomodoroMinutes
                    }
                }
            }
        }
        
        if (gesture.state == UIGestureRecognizerState.Changed) {
            
            if (gesture.numberOfTouches() == 1) {
                
                // Changing pomodoro or break minutes
                
                if (!pomodoroManager.counting) {
                    
                    var point = gesture.translationInView(self.view)
                    let maxWidth = self.view.frame.size.width
                    let percentage : Float = Float(point.x / (maxWidth * 2))
                    var move : Int = 0
                    
                    if (pomodoroManager.breakTime) {
                        
                        move = Int(30 * percentage)
                        
                        if (originalMinutes + move <= 30) {
                            if (originalMinutes + move >= 1) {
                                pomodoroManager.breakMinutes = originalMinutes + move
                            } else {
                                pomodoroManager.breakMinutes = 1
                            }
                        } else {
                            pomodoroManager.breakMinutes = 30
                        }
                        
                    } else {
                        
                        move = Int(60 * percentage)
                        
                        if (originalMinutes + move <= 60) {
                            if (originalMinutes + move >= 1) {
                                pomodoroManager.pomodoroMinutes = originalMinutes + move
                            } else {
                                pomodoroManager.pomodoroMinutes = 1
                            }
                        } else {
                            pomodoroManager.pomodoroMinutes = 60
                        }
                        
                    }
                    
                    resetTimer()
                    
                }
                
            }
            
        }
        if (gesture.state == UIGestureRecognizerState.Ended) {
            if (!pomodoroManager.counting) {
                if (gesture.numberOfTouches() == 1) {
                    if (pomodoroManager.breakTime) {
                        originalMinutes = pomodoroManager.breakMinutes
                    } else {
                        originalMinutes = pomodoroManager.pomodoroMinutes
                    }
                }
            }
        }
        
    }
    
    func updateClock(timer: NSTimer) {
                
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        let now : String = formatter.stringFromDate(NSDate())
        clockLabel.text = now
        
    }
    
    // Shake methods
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if (motion == UIEventSubtype.MotionShake) {
            if (!pomodoroManager.counting) {
                switchMode()
            }
        }
    }
    
    func switchMode() {
        
        if (pomodoroManager.breakTime) {
            
            modeButton.setTitle(NSLocalizedString("mode_working", comment: ""), forState: UIControlState.Normal)

            pomodoroManager.breakTime = false
            
            resetTimer()
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                if let color = self.pomodoroManager.pomodoroColor {
                    self.view.backgroundColor = self.colours[color] as? UIColor
                }
            })
            
        } else {
            
            modeButton.setTitle(NSLocalizedString("mode_resting", comment: ""), forState: UIControlState.Normal)

            pomodoroManager.breakTime = true
            
            resetTimer()
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                if let color = self.pomodoroManager.breakColor {
                    self.view.backgroundColor = self.colours[color] as? UIColor
                }
            })
            
        }
        
    }
    
    /* Game Center */
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func connectToGameKit() {
        
        println("Connecting to Game Center...")
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(var gameCenterVC:UIViewController!,
            
            var gameCenterError:NSError!) -> Void in
            
            if gameCenterVC != nil {
                
                println("Not logged. Present login screen")
                
                self.presentViewController(gameCenterVC, animated: true, completion:nil)
                
            } else {
                
                if localPlayer.authenticated {
                    println("Game Center enabled")
                    self.gameCenterEnabled = true
                } else {
                    println("Game Center disabled")
                    self.gameCenterEnabled = false
                }
                
            }
        }
        
    }
    
    func showHideControls() {
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
        {
            self.clockLabel.hidden = true
            self.modeButton.hidden = true
            self.infoButton.hidden = true
            self.gameCenterButton.hidden = true
            self.todayButton.hidden = true
        }
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
        {
            self.clockLabel.hidden = false
            self.todayButton.hidden = false
            self.infoButton.hidden = false
            self.gameCenterButton.hidden = false
            self.modeButton.hidden = false
        }
    }
    
    @IBAction func modeChangePressed() {
        switchMode()
    }
    
    func rotated()
    {
        showHideControls()
    }
    
    @IBAction func showTutorialInfoButton() {
        
//        let userDefaults = NSUserDefaults.standardUserDefaults()
//        userDefaults.setObject(true, forKey: "showTutorial")
//
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.showDemoViewController()
        onScreenHelp()
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        clockTimer?.invalidate()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    var bubbleView : BubbleView?
    
    func animateBubble() {
        
        if (tutorial) {
            
            self.bubbleView?.removeFromSuperview()
            
            if (tutorialStep == 0) {
                bubbleView = BubbleView(forFrame: self.modeButton.frame, center: self.modeButton.center, onView: self.view, text: "Cambia de modo entre trabajo y descanso", color: UIColor.whiteColor(), direction: BubbleViewDirection.Up, arrow: true)
            }
            
            if (tutorialStep == 1) {
                bubbleView = BubbleView(forFrame: self.timerLabel.frame, center: self.timerLabel.center, onView: self.view, text: "Cambia la duración del modo seleccionado deslizando un dedo de izquierda a derecha sobre el temporizador", color: UIColor.whiteColor(), direction: BubbleViewDirection.Down, arrow: true)
            }

            if (tutorialStep == 2) {
                bubbleView = BubbleView(forFrame: self.clockLabel.frame, center: self.clockLabel.center, onView: self.view, text: "Configura el color de fondo del modo seleccionado deslizando arriba y abajo dos dedos", color: UIColor.whiteColor(), direction: BubbleViewDirection.Up, arrow: false)
            }

            if (tutorialStep == 3) {
                bubbleView = BubbleView(forFrame: self.gameCenterButton.frame, center: self.gameCenterButton.center, onView: self.view, text: "Accede a Game Center para ver tus puntuaciones frente a las de tus amigos", color: UIColor.whiteColor(), direction: BubbleViewDirection.Down, arrow: true)
            }
            
            if (tutorialStep == 3) {
                bubbleView = BubbleView(forFrame: self.gameCenterButton.frame, center: self.gameCenterButton.center, onView: self.view, text: "Accede a Game Center para ver tus puntuaciones frente a las de tus amigos", color: UIColor.whiteColor(), direction: BubbleViewDirection.Down, arrow: true)
            }
            
            if (tutorialStep == 4) {
                bubbleView = BubbleView(forFrame: self.todayButton.frame, center: self.todayButton.center, onView: self.view, text: "Visualiza las sesiones y su duración total en el día de hoy. Pulsa para acceder al menu de Estadísticas", color: UIColor.whiteColor(), direction: BubbleViewDirection.Down, arrow: true)
            }
            
            if (tutorialStep == 5) {
                bubbleView = BubbleView(forFrame: self.infoButton.frame, center: self.infoButton.center, onView: self.view, text: "Accede de nuevo a esta ayuda en cualquier momento", color: UIColor.whiteColor(), direction: BubbleViewDirection.Down, arrow: true)
            }

            if (tutorialStep == 6) {
                
                tutorialStep = 0
                tutorial = false
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self.tutorialBackgroundView.alpha = 0.0
                    }) { (finished) -> Void in
                        self.tutorialView.removeFromSuperview()
                        self.tutorialBackgroundView.removeFromSuperview()
                }
                
            } else {
                
                var originalPosition : CGPoint = bubbleView!.center
                bubbleView?.frame.origin.x = -100
                bubbleView?.frame.origin.y = -100
                
                if (tutorialStep < 6) {
                    tutorialView.addSubview(bubbleView!)
                }
                
                if snapBehaviour != nil {
                    animator.removeBehavior(snapBehaviour)
                }
                
                snapBehaviour = UISnapBehavior(item: bubbleView!, snapToPoint: originalPosition)
                snapBehaviour.damping = 0.3
                animator.addBehavior(snapBehaviour)
                
                tutorialStep++
            }
            
        }
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        animateBubble()
    }
    
    func onScreenHelp() {

        tutorial = true
        
        // Dark layer for tutorial
        tutorialBackgroundView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        tutorialBackgroundView.backgroundColor = UIColor.blackColor()
        tutorialBackgroundView.alpha = 0.0
        
        tutorialView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        
        self.view.addSubview(tutorialBackgroundView)
        self.view.addSubview(tutorialView)
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.tutorialBackgroundView.alpha = 0.5
        }) { (finished) -> Void in
            self.animateBubble()
        }
        
    }
}



//
//  ViewController.swift
//  Workapp
//
//  Created by migueldiazrubio on 11/1/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var colours : NSArray!
    var originalMinutes = 0
    var pomodoroManager = PomodoroManager.sharedInstance
    var clockTimer : NSTimer?
    
    // Comentario de prueba
    
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    
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
            todayLabel.text = todayStringFromNumber(todayPomodoros)
        } else {
            todayLabel.text = ""
        }
    }
    
    func todayStringFromNumber(value: Int) -> String {
        
        let full = value / 5
        let resto = value % 5
        var retorno = ""
        
        for (var i = 0 ; i < full ; i++) {
            retorno += "5 "
        }
        if (resto != 0) {
            retorno += String(resto)
        }
        
        return retorno
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
        
    }
    
    override func viewDidLoad() {
        
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
        
        // Setting custom font for counter
        todayLabel.font = UIFont(name: "MiguelToPalote-Regular", size: 25)
        
        pomodoroManager.updateBadgeIcon()
        
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
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.clockLabel.hidden = false
        })
        
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
            
            pomodoroManager.breakTime = false
            
            resetTimer()
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                if let color = self.pomodoroManager.pomodoroColor {
                    self.view.backgroundColor = self.colours[color] as? UIColor
                }
            })
            
        } else {
            
            pomodoroManager.breakTime = true
            
            resetTimer()
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                if let color = self.pomodoroManager.breakColor {
                    self.view.backgroundColor = self.colours[color] as? UIColor
                }
            })
            
        }
        
    }
        
}


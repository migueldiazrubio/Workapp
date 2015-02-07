//
//  Pomodoro.swift
//  Workapp
//
//  Created by migueldiazrubio on 15/1/15.
//  Copyright (c) 2015 Miguel Díaz Rubio. All rights reserved.
//

import Foundation
import CoreData

@objc(Pomodoro)
class Pomodoro: NSManagedObject {

    @NSManaged var length: NSNumber
    @NSManaged var date: NSDate

}

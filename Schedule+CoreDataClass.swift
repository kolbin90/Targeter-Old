//
//  Schedule+CoreDataClass.swift
//  Targeter
//
//  Created by mac on 3/8/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation
import CoreData

@objc(Schedule)
public class Schedule: NSManagedObject {

    convenience init(monday:Bool, tuesday:Bool, wednesday:Bool, thursday:Bool, friday:Bool, saturday:Bool, sunday:Bool, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Schedule", in: context) {
            self.init(entity: ent, insertInto: context)
            self.monday = monday
            self.tuesday = tuesday
            self.wednesday = wednesday
            self.thursday = thursday
            self.friday = friday
            self.saturday = saturday
            self.sunday = sunday
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

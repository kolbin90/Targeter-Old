//
//  Success+CoreDataClass.swift
//  Targeter
//
//  Created by mac on 3/8/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation
import CoreData

@objc(Success)
public class Success: NSManagedObject {

    convenience init(date:Date, success:Bool, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Success", in: context) {
            self.init(entity: ent, insertInto: context)
            self.date = date
            self.success = success
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

//
//  Target+CoreDataClass.swift
//  Targeter
//
//  Created by mac on 3/8/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation
import CoreData

@objc(Target)
public class Target: NSManagedObject {

    convenience init(title: String, descriptionCompletion: String, dayBeginning: Date, dayEnding: Date?,  picture: Data?, active: Bool, completed: Bool, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Target", in: context) {
            self.init(entity: ent, insertInto: context)
            self.creationDate = Date()
            self.title = title
            self.descriptionCompletion = descriptionCompletion
            self.dayBeginning = dayBeginning
            if let dayEnding = dayEnding {
                self.dayEnding = dayEnding
            }
            if let picture = picture {
                self.picture = picture
            }
            self.completed = completed
            self.active = active
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

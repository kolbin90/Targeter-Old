//
//  Target+CoreDataProperties.swift
//  Targeter
//
//  Created by mac on 3/8/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation
import CoreData


extension Target {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Target> {
        return NSFetchRequest<Target>(entityName: "Target");
    }

    @NSManaged public var creationDate: Date
    @NSManaged public var title: String
    @NSManaged public var descriptionCompletion: String
    @NSManaged public var dayBeginning: Date
    @NSManaged public var dayEnding: Date?
    @NSManaged public var picture: Data?
    @NSManaged public var active: Bool
    @NSManaged public var completed: Bool
    @NSManaged public var schedule: Schedule
    @NSManaged public var successList: NSSet?

}

// MARK: Generated accessors for successList
extension Target {

    @objc(addSuccessListObject:)
    @NSManaged public func addToSuccessList(_ value: Success)

    @objc(removeSuccessListObject:)
    @NSManaged public func removeFromSuccessList(_ value: Success)

    @objc(addSuccessList:)
    @NSManaged public func addToSuccessList(_ values: NSSet)

    @objc(removeSuccessList:)
    @NSManaged public func removeFromSuccessList(_ values: NSSet)

}

//
//  Success+CoreDataProperties.swift
//  Targeter
//
//  Created by mac on 3/8/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation
import CoreData


extension Success {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Success> {
        return NSFetchRequest<Success>(entityName: "Success");
    }

    @NSManaged public var date: Date
    @NSManaged public var success: Bool
    @NSManaged public var target: Target

}

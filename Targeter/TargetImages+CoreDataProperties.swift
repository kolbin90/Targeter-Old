//
//  TargetImages+CoreDataProperties.swift
//  Targeter
//
//  Created by mac on 5/3/18.
//  Copyright © 2018 Alder. All rights reserved.
//
//

import Foundation
import CoreData


extension TargetImages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TargetImages> {
        return NSFetchRequest<TargetImages>(entityName: "TargetImages")
    }

    @NSManaged public var cellImage: Data
    @NSManaged public var targetID: String
    @NSManaged public var fullImage: Data
    @NSManaged public var imageURL: String

}

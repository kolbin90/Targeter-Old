//
//  TargetImages+CoreDataClass.swift
//  Targeter
//
//  Created by mac on 5/3/18.
//  Copyright © 2018 Alder. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TargetImages)
public class TargetImages: NSManagedObject {
    convenience init(targetID:String, cellImage:Data, fullImage:Data, imageURL: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "TargetImages", in: context) {
            self.init(entity: ent, insertInto: context)
            self.targetID = targetID
            self.cellImage = cellImage
            self.fullImage = fullImage
            self.imageURL = imageURL
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}

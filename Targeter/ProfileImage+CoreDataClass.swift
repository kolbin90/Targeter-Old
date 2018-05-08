//
//  ProfileImage+CoreDataClass.swift
//  Targeter
//
//  Created by mac on 5/7/18.
//  Copyright © 2018 Alder. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ProfileImage)
public class ProfileImage: NSManagedObject {
    convenience init(userID:String, imageData:Data, imageURL: String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "ProfileImage", in: context) {
            self.init(entity: ent, insertInto: context)
            self.userID = userID
            self.imageData = imageData
            self.imageURL = imageURL
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

//
//  ProfileImage+CoreDataProperties.swift
//  Targeter
//
//  Created by mac on 5/7/18.
//  Copyright © 2018 Alder. All rights reserved.
//
//

import Foundation
import CoreData


extension ProfileImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProfileImage> {
        return NSFetchRequest<ProfileImage>(entityName: "ProfileImage")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var userID: String?
    @NSManaged public var imageURL: String?

}

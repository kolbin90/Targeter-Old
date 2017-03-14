//
//  ImageSearch+CoreDataProperties.swift
//  Targeter
//
//  Created by mac on 3/14/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation
import CoreData


extension ImageSearch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageSearch> {
        return NSFetchRequest<ImageSearch>(entityName: "ImageSearch");
    }

    @NSManaged public var searchTitle: String?
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for images
extension ImageSearch {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: Image)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Image)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

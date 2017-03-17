//
//  ImageSearch+CoreDataClass.swift
//  Targeter
//
//  Created by mac on 3/14/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import Foundation
import CoreData

@objc(ImageSearch)
public class ImageSearch: NSManagedObject {
    convenience init(searchTitle:String?, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "ImageSearch", in: context) {
            self.init(entity: ent, insertInto: context)
            if let searchTitle = searchTitle {
                self.searchTitle = searchTitle
            }
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}

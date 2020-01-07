//
//  TargetModel.swift
//  Targeter
//
//  Created by Apple User on 1/6/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation

class TargetModel {
    var title: String?
    var imageURLString: String?
    var start: Int?
    var id: String?
}
extension TargetModel {
//    static func transformFaceBookDataToUser(dict: [String:Any]) -> TargetModel {
//        let target = TargetModel()
//        user.email = dict[Constants.UserData.Email] as? String
//        user.name = dict[Constants.UserData.Name] as? String
//        if let pictureDictionary = dict["picture"] as? [String:Any] {
//            print(pictureDictionary)
//            if let dataDictionary = pictureDictionary["data"] as? [String:Any] {
//                print(dataDictionary)
//                if let imageURLString = dataDictionary["url"] as? String {
//                    user.imageURLString = imageURLString
//                }
//            }
//        }
//        return target
//    }
    
    static func transformDataToTarget(dict: [String:Any], id: String) -> TargetModel {
        let target = TargetModel()
        
        target.title = dict[Constants.Target.Title] as? String
        target.imageURLString = dict[Constants.Target.ImageUrlString] as? String
        target.start = dict[Constants.Target.Start] as? Int
        target.id = id
        
        return target
    }
}

//
//  UserModel.swift
//  Targeter
//
//  Created by Apple User on 12/6/19.
//  Copyright © 2019 Alder. All rights reserved.
//

import Foundation
class UserModel {
    var name: String?
    var imageURLString: String?
    var username: String?
    var usernameLowercased: String?
    var email: String?
    var id: String?
}
extension UserModel {
    static func transformFaceBookDataToUser(dict: [String:Any]) -> UserModel {
        let user = UserModel()
        user.email = dict[Constants.UserData.Email] as? String
        user.name = dict[Constants.UserData.Name] as? String
        if let pictureDictionary = dict["picture"] as? [String:Any] {
            print(pictureDictionary)
            if let dataDictionary = pictureDictionary["data"] as? [String:Any] {
                print(dataDictionary)
                if let imageURLString = dataDictionary["url"] as? String {
                    user.imageURLString = imageURLString
                }
            }
        }
        return user
    }
    
    static func transformDataToUser(dict: [String:Any], id: String) -> UserModel {
        let user = UserModel()
        user.email = dict[Constants.UserData.Email] as? String
        user.username = dict[Constants.UserData.Username] as? String
        user.usernameLowercased = dict[Constants.UserData.UsernameLowercased] as? String
        user.id = id

        user.name = dict[Constants.UserData.Name] as? String
        user.imageURLString = dict[Constants.UserData.ImageURL] as? String
        return user
    }
}

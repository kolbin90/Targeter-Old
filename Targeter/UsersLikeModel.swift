//
//  UsersLikeModel.swift
//  Targeter
//
//  Created by Alexander Kolbin on 6/25/21.
//  Copyright © 2021 Alder. All rights reserved.
//

import Foundation

class UsersLikeModel {
    var likesCount: Int?
    var uid: String?
    var timestamp: Int?
}

extension UsersLikeModel {
    static func transformToLikeModel(dict: [String:Any], uid: String) -> UsersLikeModel {
        let like = UsersLikeModel()
        like.likesCount = dict[Constants.Like.likesCount] as? Int
        like.uid = dict[Constants.Like.uid] as? String
        like.timestamp = dict[Constants.Like.lastLikeTimestamp] as? Int

        return like
    }
}

//
//  CommentModel.swift
//  Targeter
//
//  Created by Alexander Kolbin on 12/9/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation

class CommentModel {
    var commentText: String?
    var uid: String?
    var timestamp: Int?
}
extension CommentModel {
    static func transformToImagePost(dict: [String:Any]) -> CommentModel {
        let comment = CommentModel()
        comment.commentText = dict[Constants.Comment.CommentText] as? String
        comment.uid = dict[Constants.Comment.Uid] as? String
        comment.timestamp = dict[Constants.Comment.timestamp] as? Int
        return comment
    }
}

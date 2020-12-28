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
    var uid: String?
    var timestamp: Int?
    var checkIns: [CheckInModel]?
    var lastAction: String?
    var lastActionTimeStamp: Int?
    var commentsCount: Int?
    var likesCount: Int?
}

extension TargetModel {    
    static func transformDataToTarget(dict: [String:Any], id: String) -> TargetModel {
        let target = TargetModel()
        
        target.title = dict[Constants.Target.Title] as? String
        target.imageURLString = dict[Constants.Target.ImageUrlString] as? String
        target.start = dict[Constants.Target.Start] as? Int
        target.id = id
        target.uid = dict[Constants.Target.Uid] as? String
        target.timestamp = dict[Constants.Target.Timestamp] as? Int
        target.lastAction = dict[Constants.Target.LastAction] as? String
        target.lastActionTimeStamp = dict[Constants.Target.LastActionTimestamp] as? Int
        target.commentsCount = dict[Constants.Target.commentsCount] as? Int ?? 0
        target.likesCount = dict[Constants.Target.likesCount] as? Int ?? 0
        return target
    }
}

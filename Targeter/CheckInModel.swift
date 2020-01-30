//
//  CheckInModel.swift
//  Targeter
//
//  Created by Apple User on 1/15/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import Foundation

class CheckInModel {
    var result: CheckInResult?
    var timestamp: Int?
    var id: String?
}

extension CheckInModel {
    static func transformDataToCheckIn(dict: [String:Any], id: String) -> CheckInModel {
        
        let checkIn = CheckInModel()
        if let resultString = dict[Constants.CheckIn.Result] as? String {
            if resultString == Constants.CheckIn.SucceedResult {
                checkIn.result = CheckInResult.succeed
            } else if resultString == Constants.CheckIn.FailedResult {
                checkIn.result = CheckInResult.failed
            }
        }
        
        checkIn.id = id
        checkIn.timestamp = dict[Constants.CheckIn.Timestamp] as? Int

        return checkIn
    }
    
    enum CheckInResult {
        case succeed
        case failed
        case noResult
    }
}

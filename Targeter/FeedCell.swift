//
//  FeedCell.swift
//  Targeter
//
//  Created by Alexander Kolbin on 9/28/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit

// MARK: - FeedCell

class FeedCell: UITableViewCell {

    
    // MARK: Outlets
//    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var todayMark: UILabel!
//    @IBOutlet weak var rightArror: UILabel!
//    @IBOutlet weak var leftArrow: UILabel!
    @IBOutlet var marks: [UIView]!
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var likesView: UIView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: Variables
    var cellPost: PostModel! {
        didSet {
            updateView()
        }
    }
    
    var todaysCheckInResult: CheckInModel.CheckInResult? {
        didSet {
            updateViewForTodaysCheckIn()
        }
    }
    var todaysCheckIn: CheckInModel?
    
    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
    
    func updateView() {
        cellBackgroundView.backgroundColor = UIColor.random()
        if let title = cellPost.target.title {
            titleLabel.text = " \(title) "
        }

        if let imageUrlString = cellPost.target.imageURLString {
            targetImageView?.sd_setImage(with: URL(string: imageUrlString)) { (image, error, cacheType, url) in
                // TODO: Save image to core data
            }
        }
        fillCheckInsHistory()
    }
    
    func updateViewForTodaysCheckIn() {
        if let todaysCheckInResult = todaysCheckInResult {
            switch todaysCheckInResult {
            case .noResult:
                todayMark.backgroundColor = .white
                todayMark.textColor = .black                
                
            case .failed:
                todayMark.backgroundColor = UIColor.redColor()
                todayMark.textColor = .white
                
            case .succeed:
                todayMark.backgroundColor = UIColor.greenColor()
                todayMark.textColor = .white
            }
        }
    }
    
    func fillCheckInsHistory() {
        guard let checkIns = cellPost.target.checkIns else {
            return
        }
        let dateStart = Date(timeIntervalSince1970: Double(cellPost.target.start!))
        if Calendar.current.compare(Date(), to: dateStart, toGranularity: .day).rawValue >= 0  {
            todaysCheckIn = getTodaysCheckIn(checkIns: checkIns)
            todaysCheckInResult = todaysCheckIn?.result ?? .noResult
        }
        for (index, mark) in marks.reversed().enumerated() {
            let dateToCheck = Calendar.current.date(byAdding: .day, value: -(index + 1), to: Date())!
            // findCheckInResultFor(date: dateToCheck, checkIns: checkIns)
            
            //let checkIn = checkIns[index]
            if Calendar.current.compare(dateToCheck, to: dateStart, toGranularity: .day).rawValue >= 0 {
                let checkInResult = findCheckInResultFor(date: dateToCheck, checkIns: checkIns)
                switch checkInResult {
                case .succeed:
                    mark.backgroundColor = .greenColor()
                    mark.alpha = 1
                case .failed:
                    mark.backgroundColor = .redColor()
                    mark.alpha = 1
                case .noResult:
                    mark.backgroundColor = .redColor()
                    mark.alpha = 1
                }
            } else {
                mark.alpha = 0
            }
        }
    }
    
    func findCheckInResultFor(date date: Date, checkIns: [CheckInModel] ) -> CheckInModel.CheckInResult {
        for checkIn in checkIns {
            guard let timestamp = checkIn.timestamp else {
                return CheckInModel.CheckInResult.noResult
            }
            let dateFromTimestamp = Date(timeIntervalSince1970: Double(timestamp))
            if Calendar.current.isDate(date, inSameDayAs: dateFromTimestamp ) {
                guard let result = checkIn.result else {
                    return CheckInModel.CheckInResult.noResult
                }
                return result
            }
        }
        return CheckInModel.CheckInResult.noResult
    }
    
    func getTodaysCheckIn(checkIns: [CheckInModel]) -> CheckInModel? {
        for checkIn in checkIns {
            guard let timestamp = checkIn.timestamp else {
                return nil
            }
            let dateFromTimestamp = Date(timeIntervalSince1970: Double(timestamp))
            if Calendar.current.isDate(Date(), inSameDayAs: dateFromTimestamp ) {
                return checkIn
            }
        }
        return nil
    }
    
}

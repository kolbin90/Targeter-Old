//
//  FeedCell.swift
//  Targeter
//
//  Created by Alexander Kolbin on 9/28/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit

// MARK: - FeedCell

protocol FeedCellDelegate: class {
    func goToCommentsVC(withTargetId id: String)
    func updateLikes(withTargetId id: String, isLiked: Bool)
}

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
    @IBOutlet weak var commentsImageView: UIImageView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastActionLabel: UILabel!
    @IBOutlet weak var lastActionTimestampLabel: UILabel!
    
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
    weak var delegate: FeedCellDelegate?

    
    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.layer.cornerRadius = 10
        titleLabel.layer.masksToBounds = true
        todayMark.layer.cornerRadius = 10
        todayMark.layer.masksToBounds = true
        for mark in marks {
            mark.layer.cornerRadius = 5
            mark.layer.masksToBounds = true
            
        }
        profileImageView.layer.cornerRadius = 15
        
        let tapGestureForComments = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TchUpIns))
        commentsImageView.addGestureRecognizer(tapGestureForComments)
        commentsImageView.isUserInteractionEnabled = true
        
        let tapGestureForLike = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TchUpIns))
        likeImageView.addGestureRecognizer(tapGestureForLike)
        likeImageView.isUserInteractionEnabled = true
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
            titleLabel.text = "  \(title)  "
        }

        if let imageUrlString = cellPost.target.imageURLString {
            targetImageView.sd_setImage(with: URL(string: imageUrlString)) { (image, error, cacheType, url) in
                // TODO: Save image to core data
            }
        }
        
        if let username = cellPost.user.username {
            usernameLabel.text = username
        }
        
        if let profileImageUrlString = cellPost.user.imageURLString {
            profileImageView.sd_setImage(with: URL(string: profileImageUrlString)) { (image, error, cacheType, url) in
                // TODO: Save image to core data
            }
        }
        if let lastAction = cellPost.target.lastAction {
            lastActionLabel.text = lastAction
        }
        
        if let commentsCount = cellPost.target.commentsCount {
            commentsLabel.text = String(commentsCount)
        } else {
            commentsLabel.text = "0"
        }
        
        if let likesCount = cellPost.target.likesCount {
            likesLabel.text = String(likesCount)
        }
        
        if let isLiked = cellPost.target.isLiked {
            if isLiked {
                likeImageView.image = UIImage(imageLiteralResourceName: "likeSelected")
            } else {
                likeImageView.image = UIImage(imageLiteralResourceName: "like")
            }
        }
        
        if let timestamp = cellPost.target.lastActionTimeStamp {
            let now = Date()
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth, .month, .year])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            
            if let second = diff.second, second <= 0, let minute = diff.minute, minute == 0 {
                timeText = "Now"
            }
            if let second = diff.second, second > 0, let minute = diff.minute, minute == 0  {
                timeText = (second == 1) ? "\(second) second ago" : "\(second) seconds ago"
            }
            if let minute = diff.minute, minute > 0, let hour = diff.hour, hour == 0 {
                timeText = (minute == 1) ? "\(minute) minute ago" : "\(minute) minutes ago"
            }
            if let hour = diff.hour, hour > 0, let day = diff.day, day == 0 {
                timeText = (hour == 1) ? "\(hour) hour ago" : "\(hour) hours ago"
            }
            if let day = diff.day, day > 0, let week = diff.weekOfMonth, week == 0 {
                timeText = (day == 1) ? "\(day) day ago" : "\(day) days ago"
            }
            
            if let week = diff.weekOfMonth, week > 0, let month = diff.month, month == 0 {
                timeText = (week == 1) ? "\(week) week ago" : "\(week) weeks ago"
            }
            if let month = diff.month, month > 0, let year = diff.year, year == 0 {
                timeText = (month == 1) ? "\(month) month ago" : "\(month) monthes ago"
            }
            if let year = diff.year, year > 0{
                timeText = (year == 1) ? "\(year) year ago" : "\(year) years ago"
            }
            
            lastActionTimestampLabel.text = timeText
        }
        
        fillCheckInsHistory()
    }
    
    func updateViewForTodaysCheckIn() {
        if let todaysCheckInResult = todaysCheckInResult {
            switch todaysCheckInResult {
            case .noResult:
                todayMark.backgroundColor = .white
                todayMark.textColor = .black
                todayMark.text = "  Today?  "
                
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
    
    @objc func commentImageView_TchUpIns() {
        if let id = cellPost.target.id {
          //  let commentsVC =
            delegate?.goToCommentsVC(withTargetId: id)
        }
    }
    
    @objc func likeImageView_TchUpIns() {
        if let id = cellPost.target.id {
          //  let commentsVC =
            if cellPost.target.isLiked! {
                likeImageView.image = UIImage(imageLiteralResourceName: "like")
                cellPost.target.isLiked = false
                delegate?.updateLikes(withTargetId: id, isLiked: false)
            } else {
                likeImageView.image = UIImage(imageLiteralResourceName: "likeSelected")
                cellPost.target.isLiked = true
                delegate?.updateLikes(withTargetId: id, isLiked: true)
            }
            
        }
    }
    
}

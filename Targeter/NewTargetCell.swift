//
//  NewTargetCell.swift
//  Targeter
//
//  Created by mac on 12/1/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit
import SDWebImage
import SwipeCellKit

// MARK: - NewTargetCell

class NewTargetCell: SwipeTableViewCell {
    // MARK: Outlets
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var todayMark: UILabel!
    @IBOutlet weak var rightArror: UILabel!
    @IBOutlet weak var leftArrow: UILabel!
    @IBOutlet var marks: [UIView]!
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var likesView: UIView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    
    // MARK: Variables
    var cellTarget: TargetModel! {
        didSet {
            updateView()
        }
    }
    
    var todaysCheckInResult: CheckInModel.CheckInResult? {
        didSet {
            updateViewForTodaysCheckIn()
        }
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        leftArrow.backgroundColor = UIColor.greenColor()
        rightArror.backgroundColor = UIColor.redColor()

        // Initialization code
    }
    override func prepareForReuse() {
        targetImageView.image = nil
        for mark in marks {
            mark.alpha = 0
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
    
    
    
    
    func updateView() {
        percentage.isHidden = true
        self.backgroundColor = UIColor.random()
        if let title = cellTarget.title {
            titleLabel.text = " \(title) "
        }

        if let imageUrlString = cellTarget.imageURLString {
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
                leftArrow.isHidden = false
                rightArror.isHidden = false
                todayMark.backgroundColor = .white
                todayMark.textColor = .black
            case .failed:
                leftArrow.isHidden = true
                rightArror.isHidden = true
                todayMark.backgroundColor = UIColor.redColor()
                todayMark.textColor = .white
            case .succeed:
                leftArrow.isHidden = true
                rightArror.isHidden = true
                todayMark.backgroundColor = UIColor.greenColor()
                todayMark.textColor = .white
            }
        }
    }
    
    func fillCheckInsHistory() {
        guard let checkIns = cellTarget.checkIns else {
            return
        }
        for (index, mark) in marks.reversed().enumerated() {
            if checkIns.count >= (index + 1) {
                let checkIn = checkIns[index]
                guard let checkInResult = checkIn.result else {return}
                switch checkInResult {
                case .succeed:
                    mark.backgroundColor = .greenColor()
                    mark.alpha = 1
                case .failed:
                    mark.backgroundColor = .redColor()
                    mark.alpha = 1
                case .noResult:
                    mark.alpha = 0
                }
            }
        }
    }
}

extension NewTargetCell: TargetsViewControllerDelegate {
    func cellSwiped(withResult result: CheckInModel.CheckInResult) {
        todaysCheckInResult = result
    }
}


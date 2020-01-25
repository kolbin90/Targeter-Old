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


class NewTargetCell: SwipeTableViewCell {

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        leftArrow.backgroundColor = UIColor.greenColor()
        rightArror.backgroundColor = UIColor.redColor()

        // Initialization code
    }
    
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
    
    override func prepareForReuse() {
        targetImageView.image = nil
        for mark in marks {
            mark.alpha = 0
        }
    }
    
    
    func updateView() {
        percentage.isHidden = true
        self.backgroundColor = UIColor.random()
        if let title = cellTarget.title {
            titleLabel.text = " \(title) "
        }
        if let start = cellTarget.start {
            
        }
        if let imageUrlString = cellTarget.imageURLString {
            targetImageView?.sd_setImage(with: URL(string: imageUrlString)) { (image, error, cacheType, url) in
                
            }
        }
        
        
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
    
    
}

extension NewTargetCell: TargetsViewControllerDelegate {
    func cellSwiped(withResult result: CheckInModel.CheckInResult) {
        todaysCheckInResult = result
    }
}


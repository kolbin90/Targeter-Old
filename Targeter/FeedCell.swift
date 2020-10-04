//
//  FeedCell.swift
//  Targeter
//
//  Created by Alexander Kolbin on 9/28/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit

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
//        self.backgroundColor = UIColor.random()
//        if let title = cellTarget.title {
//            titleLabel.text = " \(title) "
//        }
//
//        if let imageUrlString = cellTarget.imageURLString {
//            targetImageView?.sd_setImage(with: URL(string: imageUrlString)) { (image, error, cacheType, url) in
//                // TODO: Save image to core data
//            }
//        }
//        fillCheckInsHistory()
    }
    
}

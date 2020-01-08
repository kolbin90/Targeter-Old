//
//  NewTargetCell.swift
//  Targeter
//
//  Created by mac on 12/1/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit
import SDWebImage


class NewTargetCell: UITableViewCell {

    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var todayMark: UILabel!
    @IBOutlet weak var rightArror: UILabel!
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
        // Initialization code
    }
    
    var cellTarget: TargetModel! {
        didSet {
            //updateView()
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
        if let title = cellTarget.title {
            titleLabel.text = cellTarget.title
        }
        if let start = cellTarget.start {
            
        }
        if let imageUrlString = cellTarget.imageURLString {
            //targetImageView!.sd_setImage(with: imageUrlString, placeholderImage: nil, options: [:]) { (image, error, imageCacheType, url) in
            targetImageView?.sd_setImage(with: URL(string: imageUrlString)) { (image, error, cacheType, url) in
                
            }
            
        }
        
    }
    
}


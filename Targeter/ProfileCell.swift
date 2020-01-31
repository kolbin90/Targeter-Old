//
//  ProfileCell.swift
//  Targeter
//
//  Created by Apple User on 1/31/20.
//  Copyright © 2020 Alder. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

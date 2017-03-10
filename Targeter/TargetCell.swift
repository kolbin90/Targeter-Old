//
//  TargetCell.swift
//  Targeter
//
//  Created by mac on 3/9/17.
//  Copyright © 2017 Alder. All rights reserved.
//

import UIKit

class TargetCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dot1: UIImageView!
    @IBOutlet weak var dot2: UIImageView!
    @IBOutlet weak var dot3: UIImageView!
    @IBOutlet weak var dot4: UIImageView!
    @IBOutlet weak var dot5: UIImageView!
    @IBOutlet weak var dot6: UIImageView!
    @IBOutlet weak var dot7: UIImageView!
    @IBOutlet weak var dot8: UIImageView!
    @IBOutlet weak var dot9: UIImageView!
    @IBOutlet weak var dot10: UIImageView!
    @IBOutlet weak var dot11: UIImageView!
    @IBOutlet weak var dot12: UIImageView!
    @IBOutlet weak var dot13: UIImageView!
    @IBOutlet weak var dot14: UIImageView!
    
    @IBOutlet weak var day1: UILabel!
    @IBOutlet weak var day2: UILabel!
    @IBOutlet weak var day3: UILabel!
    @IBOutlet weak var day4: UILabel!
    @IBOutlet weak var day5: UILabel!
    @IBOutlet weak var day6: UILabel!
    @IBOutlet weak var day7: UILabel!
    @IBOutlet weak var day8: UILabel!
    @IBOutlet weak var day9: UILabel!
    @IBOutlet weak var day10: UILabel!
    @IBOutlet weak var day11: UILabel!
    @IBOutlet weak var day12: UILabel!
    @IBOutlet weak var day13: UILabel!
    @IBOutlet weak var day14: UILabel!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let dotsArray:[UIImageView] = [dot1, dot2, dot3, dot4, dot5, dot6, dot7, dot8, dot9, dot10, dot11, dot12, dot13, dot14]
        let daysArray:[UILabel] = [day1, day2, day3, day4, day5, day6, day7, day8, day9, day10, day11, day12, day13, day14]
        //let vodnik = "vodnik"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
    }
}

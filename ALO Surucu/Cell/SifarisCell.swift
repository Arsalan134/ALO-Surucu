//
//  SifarisCell.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 21.04.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit

class SifarisCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        titleLabel.adjustsFontSizeToFitWidth = true
        dateLabel.adjustsFontSizeToFitWidth = true
        timeLabel.adjustsFontSizeToFitWidth = true

        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
}

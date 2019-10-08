//
//  ParkTableViewCell.swift
//  StatePark
//
//  Created by Jiaxing Han on 10/1/19.
//  Copyright © 2019 Jiaxing Han. All rights reserved.
//

import Foundation

import UIKit

class ParkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var ParkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}

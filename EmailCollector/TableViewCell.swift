//
//  TableViewCell.swift
//  EmailCollector
//
//  Created by Tayal, Rishabh on 12/8/15.
//  Copyright © 2015 Rishabh Tayal. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

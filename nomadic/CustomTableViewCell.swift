//
//  CustomTableViewCell.swift
//  nomadic
//
//  Created by 濱田 一 on 2017/11/06.
//  Copyright © 2017年 濱田 一. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var myTnameLabel: UILabel!
    @IBOutlet weak var myJnameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

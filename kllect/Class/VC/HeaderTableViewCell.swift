//
//  HeaderTableViewCell.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-10-19.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  TopicCell.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-07.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit

class TopicCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badge: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.badge.layer.cornerRadius = 7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        let anims = { self.badge.alpha = selected ? 1:0 }
        if animated { UIView.animate(withDuration: 0.2, animations: anims) }
        else { anims() }
    }
    
}

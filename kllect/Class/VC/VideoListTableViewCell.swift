//
//  VideoListTableViewCell.swift
//  kllect
//
//  Created by topmobile on 5/21/16.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit

class VideoListTableViewCell: UITableViewCell {

    @IBOutlet weak var lblSiteName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var ivPicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
         // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

//
//  TopicCollectionViewCell.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-06.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit

class TopicCollectionViewCell: UICollectionViewCell {

    static let font = UIFont(name: "Colfax-Regular", size: 17)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var badge: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            addLabel.isHidden = isSelected
            badge.isHidden = !isSelected
            layer.borderColor = isSelected ? Color.KLPurple.cgColor:Color.KLLightGray.cgColor
            titleLabel.textColor = isSelected ? UIColor.black:Color.KLGray
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleLabel.font = TopicCollectionViewCell.font
        self.badge.layer.cornerRadius = 6
        self.badge.backgroundColor = Color.KLDarkPurple
        
        self.layer.borderWidth = 1
        self.layer.borderColor = Color.KLLightGray.cgColor
        self.layer.cornerRadius = 2
    }
    
    func setTopic(topic:Topic) {
        self.titleLabel.text = topic.displayName
    }

}

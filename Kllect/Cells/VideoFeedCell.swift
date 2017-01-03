//
//  VideoFeedCell.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-07.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit
import SDWebImage
import youtube_ios_player_helper

protocol VideoFeedCellDelegate {
    func videoCellDidTapMore(_ cell:VideoFeedCell)
}

class VideoFeedCell: UITableViewCell, YTPlayerViewDelegate {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoDurationLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var playerView: YTPlayerView!
    
    var backgroundGradientLayer:CAGradientLayer!
    
    var video:Video!
    var delegate:VideoFeedCellDelegate?
    
    var pendingPlay = false
    var ready = false
    
    static let playerVars = [
        "controls":0,
        "modestbranding":1,
        "playsinline":1,
        "showinfo":0,
        "mute":1
    ]
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutSubviews()
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: thumbnailImageView.bounds, cornerRadius: 8).cgPath
        backgroundGradientLayer?.bounds = self.bounds
        backgroundGradientLayer?.position = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pendingPlay = false
        ready = false
        
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.layer.masksToBounds = true
        
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowOpacity = 0.2
        
        playerView.layer.cornerRadius = 8
        playerView.layer.masksToBounds = true
        playerView.delegate = self
        playerView.isUserInteractionEnabled = false
        
        createBackgroundGradient()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func createBackgroundGradient() {
        backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.colors = [UIColor.white.cgColor, UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0).cgColor]
        backgroundGradientLayer.locations = [0.01, 0.99]
        backgroundGradientLayer.bounds = self.bounds
        backgroundGradientLayer.position = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        self.layer.insertSublayer(backgroundGradientLayer, at: 0)
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        ready = true
        if pendingPlay {
            playerView.playVideo()
            playerView.isHidden = false
        }
    }
    
    func configureWithVideo(video:Video, delegate:VideoFeedCellDelegate?, showOptions:Bool) {
        self.video = video
        
        self.playerView.isHidden = true
        
        self.channelLabel.text = video.publisher
        self.videoTitleLabel.text = video.title
        self.videoDurationLabel.text = video.formattedDuration
        self.moreButton.isHidden = !showOptions
        self.delegate = delegate
        
        if let youtubeId = video.youtubeId {
            self.playerView.load(withVideoId: youtubeId, playerVars: VideoFeedCell.playerVars)
        }
        
        self.thumbnailImageView.sd_setImage(with: video.thumbnailURL)
    }
    
    func playVideo() {
        if ready {
            playerView.playVideo()
            playerView.isHidden = false
        }
        else {
            pendingPlay = true
        }
    }
    func pauseVideo() {
        playerView.pauseVideo()
        if pendingPlay {
            pendingPlay = false
        }
    }
    
    @IBAction func more() {
        self.delegate?.videoCellDidTapMore(self)
    }
}

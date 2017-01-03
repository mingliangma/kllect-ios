//
//  PlayerController.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-12.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class PlayerController: UIViewController, YTPlayerViewDelegate {

    @IBOutlet weak var playerCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var progressBarWidth: NSLayoutConstraint!
    
    var scrubBeginTime:Float? = nil
    var currentState:YTPlayerState = .unknown
    var video:Video!
    
    var dismissing = false
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playerView.isUserInteractionEnabled = false
        
        if let id = video.youtubeId {
            self.playerView.delegate = self
            
            let playerVars = [
                "controls":0,
                "modestbranding":1,
                "playsinline":1,
                "showinfo":0
            ]
            
            self.playerView.load(withVideoId: id, playerVars: playerVars)
        }
        
        addGestures()
    }

    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        activityIndicator.stopAnimating()
        playerView.isHidden = false
        playerView.playVideo()
        
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        self.currentState = state
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        updateProgressBar()
    }
    
    
    
    func updateProgressBar() {
        let duration = Float(playerView.duration())
        let p = CGFloat(playerView.currentTime() / duration)
        self.progressBarWidth.constant = p * self.view.bounds.width
        self.view.layoutIfNeeded()
    }
    
    func addGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(sender:)))
        self.view.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        self.view.addGestureRecognizer(tap)
    }
    
    func handlePan(sender:UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        let velocity = sender.velocity(in: self.view)
        switch sender.state {
        case .began:
            playerView.pauseVideo()
            if abs(velocity.x) > abs(velocity.y) {
                scrubBeginTime = playerView.currentTime()
            }
            else {
                dismissing = true
            }
        case .changed:
            if !dismissing {
                let offset = sender.translation(in: self.view).x
                let multiplier = Float(offset / abs(offset)) // will be -1 if offset is < 0, 1 when offset > 0
                var newTime = (scrubBeginTime ?? 0) + multiplier * (pow(Float(offset), 2) / 1000)
                newTime = max(0.5, min(newTime, Float(playerView.duration() - 1))) // prevent scrubbing to 0% or 100%
                playerView.seek(toSeconds: newTime, allowSeekAhead: true)
                updateProgressBar()
            }
            else {
                playerCenterConstraint.constant = translation.y
                let p = translation.y / self.view.bounds.height
                self.view.backgroundColor = UIColor.black.withAlphaComponent(1 - abs(p))
                self.view.layoutIfNeeded()
            }
            
        default:
            if dismissing {
                let p = abs(translation.y) / self.view.bounds.height
                if p > 0.33 || abs(velocity.y) > 700 {
                    // dismiss
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseOut, animations: { 
                        self.playerCenterConstraint.constant = 0
                        self.view.backgroundColor = UIColor.black
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                    self.dismissing = false
                    playerView.playVideo()
                }
            }
            else {
                playerView.playVideo()
                scrubBeginTime = nil
            }
            
        }
    }
    
    func handleTap(sender:UITapGestureRecognizer) {
        if currentState == .paused {
            playerView.playVideo()
        }
        else if currentState == .playing {
            playerView.pauseVideo()
        }
    }
    
    

}














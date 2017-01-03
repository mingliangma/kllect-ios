//
//  FeedController.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-07.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit
import SVProgressHUD

class FeedController: UIViewController, UITableViewDataSource, UITableViewDelegate, VideoFeedCellDelegate {
    
    @IBOutlet weak var selectedTopicLabel: UILabel!
    @IBOutlet weak var topicSelectionWrapper: UIView!
    @IBOutlet weak var topicSelectionShadowView: UIView!
    @IBOutlet weak var topicSelectionChevron: UIImageView!
    @IBOutlet weak var topicSelectionUnfoldControl: UIView!
    @IBOutlet weak var topicSelectionTop: NSLayoutConstraint!
    @IBOutlet weak var topicsTableView: UITableView!
    
    @IBOutlet weak var overlayView: UIView!
    
    @IBOutlet weak var videosTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    var topicSelectionFolded = true
    
    var loading = false {
        didSet {
            if loading {
                activityIndicator.startAnimating()
            }
            else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    var topics:[Topic] = []
    var videos:[Video] = []
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if self.presentedViewController != nil {
            return .allButUpsideDown
        }
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTopicSelectionUI()
        setupTableViews()
        setupGestures()
        loadTopics()
        foldTopicSelection(animated: false)
        loadFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = videosTableView.indexPathForSelectedRow {
            videosTableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topicSelectionShadowView.layer.shadowPath = UIBezierPath(roundedRect: topicSelectionWrapper.bounds, cornerRadius: topicSelectionWrapper.layer.cornerRadius).cgPath
    }
    
    
    // MARK: Gestures

    func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(sender:)))
        topicSelectionUnfoldControl.addGestureRecognizer(pan)
        let drawerTap = UITapGestureRecognizer(target: self, action: #selector(self.toggleTopicSelection))
        topicSelectionUnfoldControl.addGestureRecognizer(drawerTap)
    }
    
    func handlePan(sender:UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            let t = sender.translation(in: self.view).y
            sender.setTranslation(CGPoint.zero, in: self.view)
            topicSelectionTop.constant += t
            self.view.layoutIfNeeded()
        default:
            let v = sender.velocity(in: self.view).y
            if v < -800 { unfoldTopicSelection(animated: true) }
            else if v > 800 { foldTopicSelection(animated: true) }
            else {
                let y = sender.location(in: self.view).y
                if y > self.view.bounds.height / 2 { foldTopicSelection(animated: true) }
                else { unfoldTopicSelection(animated: true) }
            }
        }
    }
    
    // MARK: Data
    
    func loadTopics() {
        KllectAPI.shared.getTopics { (objects) in
            self.topics = objects ?? []
            self.topicsTableView.reloadData()
            self.topicsTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    func loadFeed(loadMore:Bool = false) {
        if !loadMore { self.videos = []; videosTableView.reloadData() }
        loading = true
        KllectAPI.shared.getVideoFeed(offset: loadMore ? videos.count:0) { feedVideos in
            self.loading = false
            if loadMore && feedVideos != nil {
                self.videos.append(contentsOf: feedVideos!)
            }
            else {
                self.videos = feedVideos ?? []
            }
            self.videosTableView.reloadData()
            if !loadMore {
                self.scrollViewDidScroll(self.videosTableView)
            }
        }
    }
    
    func loadFeedFor(topic:Topic, loadMore:Bool = false) {
        if !loadMore { self.videos = []; videosTableView.reloadData() }
        loading = true
        KllectAPI.shared.getVideoFeed(for: topic, offset: loadMore ? videos.count:0) { feedVideos in
            self.loading = false
            if loadMore && feedVideos != nil {
                self.videos.append(contentsOf: feedVideos!)
            }
            else {
                self.videos = feedVideos ?? []
            }
            self.videosTableView.reloadData()
            if !loadMore {
                self.scrollViewDidScroll(self.videosTableView)
            }
        }
    }
    
    
    // MARK: Topic Selection UI
    
    func setupTopicSelectionUI() {
        topicSelectionWrapper.layer.cornerRadius = 20
        topicSelectionWrapper.layer.masksToBounds = true
        topicSelectionShadowView.backgroundColor = UIColor.clear
        topicSelectionShadowView.layer.shadowColor = UIColor.black.cgColor
        topicSelectionShadowView.layer.shadowRadius = 2
        topicSelectionShadowView.layer.shadowOpacity = 0.1
    }
    
    func toggleTopicSelection() {
        if topicSelectionFolded {
            unfoldTopicSelection(animated: true)
        }
        else {
            foldTopicSelection(animated: true)
        }
    }
    
    func unfoldTopicSelection(animated:Bool) {
        topicSelectionFolded = false
        let anims = {
            self.topicSelectionChevron.transform = CGAffineTransform(scaleX: 1, y: -1)
            self.topicSelectionTop.constant = 40
            self.overlayView.alpha = 1
            self.topicsTableView.setContentOffset(CGPoint.zero, animated: animated)
            self.view.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.curveEaseOut, animations: anims, completion: nil)
        }
        else {
            anims()
        }
    }
    
    func foldTopicSelection(animated:Bool) {
        self.topicSelectionFolded = true
        let anims = {
            self.topicSelectionChevron.transform = CGAffineTransform.identity
            self.topicSelectionTop.constant = self.view.bounds.height - self.topicSelectionUnfoldControl.bounds.height
            self.overlayView.alpha = 0
            self.topicsTableView.setContentOffset(CGPoint.zero, animated: animated)
            self.view.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.curveEaseOut, animations: anims, completion: nil)
        }
        else {
            anims()
        }
    }
    
    
    // MARK: Table Views
    
    func updateCurrentTopicTitle() {
        if let selectedIndexPath = topicsTableView.indexPathForSelectedRow {
            if selectedIndexPath.section == 0 {
                selectedTopicLabel.text = "Your Kllect"
            }
            else {
                selectedTopicLabel.text = topics[selectedIndexPath.row].displayName
            }
        }
    }
    
    func setupTableViews() {
        // Topics
        topicsTableView.register(UINib(nibName:"TopicCell", bundle:nil), forCellReuseIdentifier: "TopicCell")
        topicsTableView.register(UINib(nibName:"BasicSectionHeader", bundle:nil), forHeaderFooterViewReuseIdentifier: "BasicSectionHeader")
        //topicsTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        topicsTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 10))
        topicsTableView.showsVerticalScrollIndicator = false
        topicsTableView.tableFooterView = UIView()
        topicsTableView.separatorStyle = .none
        topicsTableView.dataSource = self
        topicsTableView.delegate = self
        
        // Videos
        videosTableView.register(UINib(nibName:"VideoFeedCell", bundle: nil), forCellReuseIdentifier: "VideoFeedCell")
        videosTableView.contentInset = UIEdgeInsetsMake(0, 0, 68, 0)
        videosTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 68, 0)
        videosTableView.separatorStyle = .none
        videosTableView.dataSource = self
        videosTableView.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == topicsTableView {
            return 2
        }
        else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == topicsTableView {
            if section == 0 {
                return 1
            }
            else {
                return topics.count
            }
        }
        else {
            return videos.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == topicsTableView {
            let cell = topicsTableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as! TopicCell
            if indexPath.section == 0 {
                cell.titleLabel.text = "Your Kllect"
            }
            else {
                cell.titleLabel.text = topics[indexPath.row].displayName
            }
            
            return cell
        }
        else {
            let cell = videosTableView.dequeueReusableCell(withIdentifier: "VideoFeedCell", for: indexPath) as! VideoFeedCell
            let video = videos[indexPath.row]
            cell.configureWithVideo(video: video, delegate: self, showOptions: true)
            return cell
        }
    }

    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == topicsTableView {
            return 60
        }
        else {
            let w = self.view.bounds.width
            let r = CGFloat(9) / CGFloat(16)
            let h = r * w + 130
            return h
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == topicsTableView {
            if section == 1 {
                let view = topicsTableView.dequeueReusableHeaderFooterView(withIdentifier: "BasicSectionHeader") as! BasicSectionHeader
                view.titleLabel.text = "CATEGORIES"
                return view
            }
        }
        
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == topicsTableView {
            if section == 1 {
                return 40
            }
        }
        return .leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == topicsTableView {
            self.foldTopicSelection(animated: true)
            updateCurrentTopicTitle()
            if indexPath.section == 0 {
                loadFeed()
            }
            else {
                let topic = topics[indexPath.row]
                loadFeedFor(topic: topic)
            }
        }
        else {
            if let cell = tableView.cellForRow(at: indexPath) as? VideoFeedCell {
                self.performSegue(withIdentifier: "PlayVideo", sender: cell)
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == topicsTableView {
            let y = scrollView.contentOffset.y
            if y < -150 {
                self.foldTopicSelection(animated: true)
            }
        }
        else {
            // support for infinite scrolling
            let realSize = scrollView.contentSize.height - scrollView.bounds.height - scrollView.contentInset.top - scrollView.contentInset.bottom
            if !loading && scrollView.contentOffset.y > realSize {
                if let indexPath = topicsTableView.indexPathForSelectedRow {
                    if indexPath.section == 0 {
                        loadFeed(loadMore: true)
                    }
                    else {
                        let topic = topics[indexPath.row]
                        loadFeedFor(topic: topic, loadMore: true)
                    }
                }
            }
            
            
            if let ips = videosTableView.indexPathsForVisibleRows {
                let cells = ips.flatMap({ self.videosTableView.cellForRow(at: $0) as? VideoFeedCell })
                
                if videosTableView.contentOffset.y + videosTableView.contentInset.top <= 30 {
                    for aCell in cells {
                        if aCell == cells.first {
                            aCell.playVideo()
                        }
                        else {
                            aCell.pauseVideo()
                        }
                    }
                }
                else if cells.count > 1 {
                    for aCell in cells {
                        if aCell == cells[1] {
                            aCell.playVideo()
                        }
                        else {
                            aCell.pauseVideo()
                        }
                    }
                }
            }
        }
    }
    
    
    
    // MARK: Actions
    
    func videoCellDidTapMore(_ cell: VideoFeedCell) {
        if let indexPath = topicsTableView.indexPathForSelectedRow, indexPath.section == 1 {
            let video = cell.video!
            let topic = topics[indexPath.row]
            promptForRelevancyWithVideo(video: video, topic: topic)
        }
        else {
            let video = cell.video!
            promptShareFor(video: video)
        }
    }
    
    func promptForRelevancyWithVideo(video:Video, topic:Topic) {
        let actionSheet = KLActionSheet()
        let relevantAction = KLSheetAction(title: "This video is relevant", icon: UIImage(named: "checked"), color: nil, block: {
            KllectAPI.shared.recordRelevancy(video: video, topic: topic, relevant: true, callback: { (success:Bool, error:NSError?) in
                SVProgressHUD.showSuccess(withStatus: "Thanks for your feedback!")
            })
        })
        let notRelevant = KLSheetAction(title: "This video is not relevant", icon: UIImage(named: "forbidden"), color: nil, block: {
            KllectAPI.shared.recordRelevancy(video: video, topic: topic, relevant: false, callback: { (success:Bool, error:NSError?) in
                SVProgressHUD.showSuccess(withStatus: "Thanks for your feedback!")
            })
        })
        let shareAction = KLSheetAction(title: "Share this video", icon: UIImage(named: "share"), color: nil, block: {
            let items = [NSURL(string: video.youtubeUrl)!]
            let shareVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            // need to delay this because action sheet is not dismissed yet
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.present(shareVC, animated: true, completion: nil)
            })
        })
        actionSheet.addAction(action: relevantAction)
        actionSheet.addAction(action: notRelevant)
        actionSheet.addAction(action: shareAction)
        self.present(actionSheet, animated: false, completion: nil)
    }
    
    func promptShareFor(video:Video) {
        let actionSheet = KLActionSheet()

        let shareAction = KLSheetAction(title: "Share this video", icon: UIImage(named: "share"), color: nil, block: {
            let items = [NSURL(string: video.youtubeUrl)!]
            let shareVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            // need to delay this because action sheet is not dismissed yet
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { 
                self.present(shareVC, animated: true, completion: nil)
            })
        })
        
        actionSheet.addAction(action: shareAction)
        self.present(actionSheet, animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? PlayerController, let cell = sender as? VideoFeedCell {
            destVC.video = cell.video
        }
    }
    
}




























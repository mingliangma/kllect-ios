//
//  VideoTableViewController.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-08-20.
//  Copyright © 2016 Kllect Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Kingfisher
import Crashlytics
import ObjectMapper
import SafariServices
import XCGLogger

class VideoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var overlayView: CategoryOverlayView!
	
	// TODO: This is hardcoded for now until interest selection is built
	private var interest: String = "Smartphones"
	
	var articles = [Video]() {
		didSet {
			if let tableView = self.tableView {
				DispatchQueue.main.async {
					tableView.reloadData()
				}
			}
		}
	}
	
	private var nextPage: URL?
	private var taskInProgress = false
	
	// MARK: - UIView
	
	override func viewDidLoad() {
		// TODO: This is hardcoded for now until interest selection is built
		self.showTag(tag: "smartphones")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.isNavigationBarHidden = true
		self.navigationController?.hidesBarsOnSwipe = false
		self.navigationController?.isToolbarHidden = true
		self.automaticallyAdjustsScrollViewInsets = false
		
		NotificationCenter.default.addObserver(self, selector: #selector(VideoTableViewController.showVideosForTag(notification:)), name: NSNotification.Name(rawValue: "ShowVideosForTag"), object: nil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		// Setup overlay view
		self.overlayView.frame = self.view.bounds
		self.overlayView.alpha = 1
		
		self.view.addSubview(self.overlayView)
		self.overlayView.category = self.interest
		
		// Animate fade out of overlay view
		UIView.animateKeyframes(withDuration: 2.0, delay: 0.0, options: .calculationModeCubic, animations: {
			
			UIView.addKeyframe(withRelativeStartTime: 1.0/2.0, relativeDuration: 1.0/2.0, animations: {
				self.overlayView.alpha = 0
			})
			
			}, completion: { _ in
				self.overlayView.removeFromSuperview()
		})
		
	}

	
    // MARK: - Table view data source/delegate
	
	func numberOfSections(in tableView: UITableView) -> Int {
		// First section is for the header cell
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		} else {
			return self.articles.count
		}
    }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		if indexPath.section == 0 {
			let tempCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderTableViewCell
			
			tempCell.titleLabel.text = self.interest.replacingOccurrences(of: "_", with: " ").capitalized
			tempCell.backgroundColor = UIColor.white
			
			cell = tempCell
		} else {
			let tempCell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoTableViewCell
			
			let video = self.articles[indexPath.row]
			tempCell.backgroundImage.kf.setImage(with: video.imageUrl)
			
			// Set image rounded corners
			tempCell.backgroundImage.layer.cornerRadius = 6
			
			// Set drop shadow on image
			let layer = tempCell.backingView.layer
			layer.masksToBounds = false
			layer.shadowColor = UIColor.black.cgColor
			layer.shadowOffset = CGSize(width: 0, height: 0)
			layer.shadowOpacity = 0.25
			
			// Set cell gradient
			let gradientLayer = CAGradientLayer()
			gradientLayer.frame = tempCell.bounds
			gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1).cgColor]
			gradientLayer.locations = [0.0, 1.0]
			
			tempCell.contentView.layer.insertSublayer(gradientLayer, at: 0)
			
			// Set cell data
			tempCell.titleLabel.text = video.title.capitalized
			tempCell.sourceLabel.text = "\(video.publisher.uppercased())"
			tempCell.timeLabel.text = self.secondsToPreciseTime(seconds: Double(video.secondsLength))
			
			cell = tempCell
		}
		
		return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let article = self.articles[indexPath.row]
		
		self.selected(article: article)
		
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let ipadAddition: CGFloat = SDiOSVersion.deviceSize() == .Screen5Dot5inch ? 20 : 0
		if indexPath.section == 0 {
			return 40
		} else if indexPath.row < self.articles.count - 1 {
			return 303 + ipadAddition
		} else {
			// Last cell has extra height to show above drawer
			return 371 + ipadAddition
		}
	}
	
	// MARK: - UIScrollViewDelegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		let actualPosition = scrollView.contentOffset.y + scrollView.frame.size.height
		let contentHeight = scrollView.contentSize.height - self.tableView.frame.size.height
		
		if actualPosition >= contentHeight {
			self.loadNext()
		}
	}
	
	// MARK: - Tag/Video Helper
	
	func showVideosForTag(notification: Notification) {
		log.debug("notification userInfo \(notification.userInfo)")
		guard let userInfo = notification.userInfo, let tag = userInfo["Tag"] as? Tag else {
			return
		}
		
		self.interest = tag.tagName
		self.nextPage = nil
		self.articles = [Video]()
		
		self.showTag(tag: tag.tagName)
	}
	
	func showTag(tag: TagName) {
		// Only allow a new tag loading task if there isn't one currently waiting
		// This allows only a single page load at a time so that infinite scroll doesn't load multiple
		guard !self.taskInProgress else {
			log.debug("There is already a task in process, cancelling new creation attempt")
			return
		}
		
		// Load either the next page (if same tag) or the first page of new tag
		let url = self.nextPage ?? URL(string: Remote.baseUrlString().appending("articles/tag/\(tag)"))!
		
		let future = Remote.getVideosForPage(url: url)
		
		self.taskInProgress = true
		
		future.onComplete { response in
			guard let page = response.value else {
				// TODO: This error handling can be broken up to handle the specific errors better
				log.error("Didn't receive a page from the API")
				return
			}
			
			// Calculate the indexPaths for the video that were just
			// loaded so we can reload those cells
			let count = self.articles.count
			self.articles.append(contentsOf: page.articles)
			let indexPaths = (count..<self.articles.count).map { return IndexPath(row: $0, section: 1) }
			self.nextPage = URL(string: Remote.baseUrlString().appending("\(page.nextPagePath.absoluteString)"))!
			
			// Only reload cells if we've received new videos
			if page.articleCount > 0 {
				DispatchQueue.main.async {
					// Reload the calculated cells on the main thread
					self.tableView.reloadRows(at: indexPaths, with: .automatic)
				}
			}
			
			self.taskInProgress = false
			
		}
	}
	
	func loadNext() {
		self.showTag(tag: self.interest)
	}
	
	func selected(article: Video) {
		if let youtubeURL = article.youtubeUrl {
			log.info("Video is Youtube Video type")
			
			let youtubeID = self.getYoutubeID(youtubeURL.absoluteString)
			let youtubeVideoUrl = Remote.youtubeBaseUrlString().appending(youtubeID)
			
			log.debug("Youtube Video Url \(youtubeVideoUrl)")
			
			SHYouTube.youtubeInBackground(withYouTubeURL: URL(string: youtubeVideoUrl), completion: { (youtube) in
				
				guard let youtube = youtube, let youtubeMediumURL = youtube.mediumURLPath, youtubeMediumURL != "" else {
					log.error("Youtube medium quality video url not found.")
					return
				}
				
				// Create AVPlayer to show video
				let avPlayerController = AVPlayerViewController()
				let playerItem = AVPlayerItem(url: URL(string: youtubeMediumURL)!)
				let player = AVPlayer(playerItem: playerItem)
				avPlayerController.player = player
				// Allow picture in picture if available
				if #available(iOS 9.0, *) {
					avPlayerController.allowsPictureInPicturePlayback = true
				}
				
				Answers.logCustomEvent(withName: "WatchVideo", customAttributes: ["Interest": self.interest, "Title": article.title, "Url": youtubeURL.absoluteString])
				
				self.present(avPlayerController, animated: true, completion: nil)
				player.play()
				
			}) { (error) in
				log.error("Couldn't parse Youtube URL")
			}
			
		} else if let articleURL = article.articleUrl {
			log.info("Video is Article type")
			
			var vc: UIViewController?
			if #available(iOS 9.0, *) {
				vc = SFSafariViewController(url: articleURL)
			} else {
				// TODO: Fallback
			}
			
			Answers.logCustomEvent(withName: "WatchVideo", customAttributes: ["Interest": self.interest, "Title": article.title, "Url": articleURL.absoluteString])
			
			self.navigationController?.pushViewController(vc!, animated: true)
		} else {
			log.error("Video not a Youtube video or an article")
		}
	}
	
	// MARK: - Youtube Helpers
	
	// Get the youtube ID from the url
	// Can be two types of url formats
	
	/// Get the youtube ID from the URL
	/// URL can be one of two styles
	///
	/// - parameter youtubeUrl: The URL of the youtube video
	///
	/// - returns: A Youtube ID String
	func getYoutubeID(_ youtubeUrl : String) -> String{
		var youtubeID : String = ""
		
		let youtubeUrlFormat1 = "https://www.youtube.com/embed/"
		let youtubeUrlFormat2 = "https://youtu.be/"
		
		if ((youtubeUrl.contains(youtubeUrlFormat1)) == true) {
			youtubeID = (youtubeUrl.components(separatedBy: youtubeUrlFormat1).last?.components(separatedBy: "?").first)!
		} else if((youtubeUrl.contains(youtubeUrlFormat2)) == true) {
			youtubeID = (youtubeUrl.components(separatedBy: youtubeUrlFormat2).last?.components(separatedBy: "/").first)!
		}
		
		return youtubeID
	}
	
	// MARK: - Other
	
	/// Convert a seconds interval to a precise time String
	///
	/// - parameter seconds: The time interval in seconds
	///
	/// - returns: A String describing the time interval precisely in [Hours:]Minutes:Seconds format
	func secondsToPreciseTime(seconds: Double) -> String {
		let formatter = DateComponentsFormatter()
		formatter.zeroFormattingBehavior = .pad
		// if there will be an hour component then process it also
		if seconds >= 3600 {
			formatter.allowedUnits = [.hour, .minute, .second]
		} else {
			formatter.allowedUnits = [.minute, .second]
		}
		formatter.unitsStyle = .positional
		return formatter.string(from: seconds)!
	}
	
}

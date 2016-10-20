//
//  VideoTableViewController.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-08-20.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Kingfisher
import Crashlytics
import ObjectMapper

class VideoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var overlayView: CategoryOverlayView!
	
	override var prefersStatusBarHidden: Bool {
		get {
			return true
		}
	}
	
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
	private var task: URLSessionDataTask?
	
	override func viewDidLoad() {
		self.view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 68, right: 0)
		self.showTag(tag: "others")
	}
	
    // MARK: - Table view data source
	
	func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles.count
    }
	
//	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//		return 60.0
//	}
//		
//	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		let blur = UIBlurEffect(style: .light)
//		
//		let effectView = UIVisualEffectView(effect: blur)
//		effectView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60.0)
//		
//		let label = UILabel(frame: UIEdgeInsetsInsetRect(effectView.frame, UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)))
//		label.text = self.interest.replacingOccurrences(of: "_", with: " ").capitalized
//		label.font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline), size: 30.0)
//		
//		effectView.addSubview(label)
//		
//		return effectView
//	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		if indexPath.row == 0 {
			let tempCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderTableViewCell
			
			tempCell.titleLabel.text = self.interest.replacingOccurrences(of: "_", with: " ").capitalized
			tempCell.backgroundColor = UIColor.white
			
			cell = tempCell
		} else {
			let tempCell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoTableViewCell
			
			let video = self.articles[indexPath.row]
			tempCell.backgroundImage.kf.setImage(with: video.imageUrl)
			
			tempCell.backgroundImage.layer.cornerRadius = 6
			let layer = tempCell.backgroundImage.layer
			
			layer.masksToBounds = false
			layer.shadowColor = UIColor.black.cgColor
			layer.shadowOffset = CGSize(width: 0, height: 0)
			layer.shadowOpacity = 0.4
			
			tempCell.titleLabel.text = video.title.capitalized
			tempCell.sourceLabel.text = "\(video.publisher.uppercased())"
			tempCell.timeLabel.text = self.secondsToPreciseTime(seconds: Double(video.secondsLength))
			
			cell = tempCell
		}
		
		return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("selected: \(indexPath)")
		
		let object = self.articles[indexPath.row]
		
		var trackingURL: URL!
		
		
		if let youtubeURL = object.youtubeUrl {
			
			let youtubeID = self.getYoutubeID(youtubeURL.absoluteString)
			let youtubeVideoUrl = "https://www.youtube.com/embed/" + youtubeID
			
			SHYouTube.youtubeInBackground(withYouTubeURL: URL(string: youtubeVideoUrl), completion: { (youtube) in
				
				guard let youtube = youtube, let youtubeMediumURL = youtube.mediumURLPath, youtubeMediumURL != "" else {
					return
				}
				
				let avPlayerController = AVPlayerViewController()
				let playerItem = AVPlayerItem(url: URL(string: youtubeMediumURL)!)
				let player = AVPlayer(playerItem: playerItem)
				avPlayerController.player = player
				if #available(iOS 9.0, *) {
					avPlayerController.allowsPictureInPicturePlayback = true
				}
				
				Answers.logCustomEvent(withName: "WatchVideo", customAttributes: ["Interest": self.interest, "Title": object.title, "Url": youtubeURL.absoluteString])
				
				self.present(avPlayerController, animated: true, completion: nil)
				player.play()
				
			}) { (error) in
				print("can't parse url")
			}
			
		} else if let articleURL = object.articleUrl {
			//TODO: Do article stuff
			trackingURL = articleURL
			let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
			let articleViewController = storyBoard.instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
			articleViewController.url = articleURL
			Answers.logCustomEvent(withName: "WatchVideo", customAttributes: ["Interest": self.interest, "Title": object.title, "Url": trackingURL.absoluteString])

			self.navigationController?.pushViewController(articleViewController, animated: true)
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 80
		} else if indexPath.row < self.articles.count - 1 {
			return 288
		} else {
			return 356
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.isNavigationBarHidden = true
		self.navigationController?.hidesBarsOnSwipe = false
		self.navigationController?.isToolbarHidden = true
		self.automaticallyAdjustsScrollViewInsets = false
		
		NotificationCenter.default.addObserver(self, selector: #selector(VideoTableViewController.showVideosForTag(notification:)), name: NSNotification.Name(rawValue: "ShowVideosForTag"), object: nil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.overlayView.frame = self.view.bounds
		self.overlayView.alpha = 0
		
		self.view.addSubview(self.overlayView)
		self.overlayView.category = self.interest
		
		UIView.animateKeyframes(withDuration: 4.0, delay: 0.0, options: .calculationModeCubic, animations: {
			
			UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0/4.0, animations: {
				self.overlayView.alpha = 1
			})
			
			UIView.addKeyframe(withRelativeStartTime: 3.0/4.0, relativeDuration: 1.0/4.0, animations: {
				self.overlayView.alpha = 0
			})
			
		}, completion: { _ in
			self.overlayView.removeFromSuperview()
		})
		
	}
	
	func showVideosForTag(notification: Notification) {
		print(notification.userInfo)
		guard let userInfo = notification.userInfo, let tag = userInfo["Tag"] as? Tag else {
			return
		}
		
		self.interest = tag.tagName
		self.nextPage = nil
		self.articles = [Video]()
		
		self.showTag(tag: tag.tagName)
	}
	
	func showTag(tag: TagName) {
		let url = self.nextPage ?? URL(string: "http://api.app.kllect.com/articles/tag/\(tag)")
		
		if let _ = self.task {
			return
		}

		let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
			
			if error == nil {
				do {
					let jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
					let page = Mapper<Page>().map(JSON: jsonData)!

					let count = self.articles.count
					self.articles.append(contentsOf: page.articles)
					let indexPaths = (count..<self.articles.count).map { return IndexPath(row: $0, section: 0) }
					self.nextPage = URL(string: "http://api.app.kllect.com/\(page.nextPagePath.absoluteString)")!
					
					if page.articleCount > 0 {
						DispatchQueue.main.async {
							self.tableView.reloadRows(at: indexPaths, with: .automatic)
						}
					}
					
				} catch {
					// handle error
					
				}
			}
			self.task = nil
		}
		self.task = task
		task.resume()
	}
	
	func loadNext() {
		self.showTag(tag: self.interest)
	}
	
	func getYoutubeID(_ youtubeUrl : String) -> String{
		
		var youtubeID : String = ""
		
		let youtubeUrlFormat1 = "https://www.youtube.com/embed/"
		let youtubeUrlFormat2 = "https://youtu.be/"
		
		if ((youtubeUrl.contains(youtubeUrlFormat1)) == true)
		{
			youtubeID = (youtubeUrl.components(separatedBy: youtubeUrlFormat1).last?.components(separatedBy: "?").first)!
			
		}
		else if((youtubeUrl.contains(youtubeUrlFormat2)) == true)
		{
			youtubeID = (youtubeUrl.components(separatedBy: youtubeUrlFormat2).last?.components(separatedBy: "/").first)!
			
		}
		
		return youtubeID
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		let actualPosition = scrollView.contentOffset.y + scrollView.frame.size.height
		let contentHeight = scrollView.contentSize.height - self.tableView.frame.size.height
		
		if actualPosition >= contentHeight {
			self.loadNext()
		}
	}
	
	func secondsToPreciseTime(seconds: Double) -> String {
		let formatter = DateComponentsFormatter()
		formatter.zeroFormattingBehavior = .pad
		if seconds >= 3600 {
			formatter.allowedUnits = [.hour, .minute, .second]
		} else {
			formatter.allowedUnits = [.minute, .second]
		}
		formatter.unitsStyle = .positional
		return formatter.string(from: seconds)!
	}

}

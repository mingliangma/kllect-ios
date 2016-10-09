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

class VideoTableViewController: UITableViewController {
	
	override var prefersStatusBarHidden: Bool {
		get {
			return true
		}
	}
	
	private let interest: String = "Smartphones"
	
	var articles = [Video]() {
		didSet {
			if let tableView = self.tableView {
				DispatchQueue.main.async {
					tableView.reloadData()
				}
			}
		}
	}
	
	override func viewDidLoad() {
		self.view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 68, right: 0)
		self.showTag(tag: "others")
	}
	
    // MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		print(self.articles.count)
        return self.articles.count
    }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	    let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoTableViewCell
		
		let video = self.articles[indexPath.row]
//		let object = self.articles[indexPath.row] as! NSDictionary
//		let strTitle = object["title"] as! String
//		let strSiteName = object["siteNeme"] as! String
//		let imageurl = object["imageUrl"] as! String
		
//		let imageURL = URL(string: video.imageUrl)!
		cell.backgroundImage.kf.setImage(with: video.imageUrl, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cache, url) in
			if let image = image {
				print(image)
				print(image.size)
			}
		}
		
		cell.backgroundImage.layer.cornerRadius = 6
		
//		cell.backgroundImage.kf.setImage(with: URL(string: video.imageUrl.absoluteString.replacingOccurrences(of: "mqdefault", with: "hqdefault"))!)
//		cell.backgroundImage.kf_setImageWithURL(imageURL)
		cell.titleLabel.text = video.title.capitalized
		cell.sourceLabel.text = video.siteName.uppercased()
		
		print(cell)

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("selected: \(indexPath)")
		
//		let object = self.articles[indexPath.row] as! NSDictionary
		let object = self.articles[indexPath.row]
		
		var trackingURL: URL!
		
		if let youtubeURL = object.youtubeUrl {
			//TODO: Do youtube stuff
			let youtubeID = getYoutubeID(youtubeURL.absoluteString)
			let youtubeVideoUrl = "https://www.youtube.com/embed/" + youtubeID
			
			SHYouTube.youtubeInBackground(withYouTubeURL: URL(string: youtubeVideoUrl), completion: { (youtube) in
				
				guard let youtube = youtube, let youtubeMediumURL = youtube.mediumURLPath, youtubeMediumURL != "" else {
					return
				}
				
				trackingURL = URL(string: youtubeMediumURL)!
				
				let avPlayerController = AVPlayerViewController()
				let playerItem = AVPlayerItem(url: NSURL(string: youtubeMediumURL)! as URL)
				let player = AVPlayer(playerItem: playerItem)
				avPlayerController.player = player
				if #available(iOS 9.0, *) {
					avPlayerController.allowsPictureInPicturePlayback = true
				}
				
				Answers.logCustomEvent(withName: "WatchVideo", customAttributes: ["Interest": self.interest, "Title": object.title, "Url": trackingURL.absoluteString])

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
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row < self.articles.count - 1 {
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
	
	func showVideosForTag(notification: Notification) {
		print(notification.userInfo)
		guard let userInfo = notification.userInfo, let tag = userInfo["Tag"] as? Tag else {
			return
		}
		
		self.showTag(tag: tag.tagName)
	}
	
	func showTag(tag: TagName) {
		let url = URL(string: "http://api.app.kllect.com/articles/tag/\(tag)")
		let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
			
			if error == nil {
				do {
					let jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
					self.articles.replaceSubrange(self.articles.startIndex..<self.articles.endIndex, with: Mapper<Video>().mapArray(JSONObject: jsonData["articles"])!)
					DispatchQueue.main.async {
						self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: .automatic)
					}
					print(self.articles.map{return $0.tags})
					
				} catch {
					// handle error
					
				}
			}
		}
		task.resume()
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

}

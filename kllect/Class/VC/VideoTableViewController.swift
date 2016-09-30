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

class VideoTableViewController: UITableViewController {
	
	private let interest: String = "Smartphones"
	
	var articles = [AnyObject]() {
		didSet {
			if let tableView = self.tableView {
				tableView.reloadData()
			}
		}
	}
	
	override func viewDidLoad() {
		self.view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 68, right: 0)
		self.getNews()
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
		
		let object = self.articles[indexPath.row] as! NSDictionary
		let strTitle = object["title"] as! String
		let strSiteName = object["siteNeme"] as! String
		let imageurl = object["imageUrl"] as! String
		
		let imageURL = URL(string: imageurl)!
		cell.backgroundImage.kf.setImage(with: imageURL)
//		cell.backgroundImage.kf_setImageWithURL(imageURL)
		cell.titleLabel.text = strTitle
		cell.sourceLabel.text = strSiteName
		
		print(cell)

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("selected: \(indexPath)")
		
		let object = self.articles[indexPath.row] as! NSDictionary
		
		var trackingURL: URL!
		
		if let youtubeURL = object["youtubeUrl"] as? String, youtubeURL != "" {
			//TODO: Do youtube stuff
			let youtubeID = getYoutubeID(youtubeURL)
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
				
				self.present(avPlayerController, animated: true, completion: nil)
				
			}) { (error) in
				print("can't parse url")
			}
		} else if let articleURL = object["articleUrl"] as? String, articleURL != "" {
			//TODO: Do article stuff
			trackingURL = URL(string: articleURL)!
			let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
			let articleViewController = storyBoard.instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
			articleViewController.url = URL(string: articleURL)!
//			self.presentViewController(articleViewController, animated: true, completion: nil)
			self.navigationController?.pushViewController(articleViewController, animated: true)
		}
		
		Answers.logCustomEvent(withName: "WatchVideo", customAttributes: ["Interest": self.interest, "Title": object["title"] as! String, "Url": trackingURL.absoluteString])
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row < self.articles.count - 1 {
			return 200
		} else {
			return 268
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.isNavigationBarHidden = true
		self.navigationController?.hidesBarsOnSwipe = false
		self.navigationController?.isToolbarHidden = true
	}
	
	func getNews() {
		print("getting stuff")
		let url = URL(string: "http://api.app.kllect.com/articles/tag/smartphones")
		let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
			
			if error == nil {
				do {
					print("success")
					let jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [AnyObject]
					self.articles.replaceSubrange(self.articles.startIndex..<self.articles.endIndex, with: jsonData)
					DispatchQueue.main.async {
						self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: .automatic)
					}
					
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

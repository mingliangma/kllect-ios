//
//  VideoListViewController.swift
//  kllect
//
//  Created by topmobile on 5/19/16.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit
import MediaPlayer
//import MBProgressHUD
//import Infinity
//import YouTubePlayer

class VideoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{


    @IBOutlet weak var viewTopBar: UIView!
    @IBOutlet weak var tblView: UITableView!

    @IBOutlet weak var ivDefault: UIImageView!
    
    var viewUnderline : UIView! = nil
    var arrayData : NSMutableArray! = nil
    var thumbDict : NSMutableDictionary = NSMutableDictionary()
    var nID: NSInteger!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayData = NSMutableArray()
        
        viewUnderline = UIView(frame: CGRect(x: 0, y: viewTopBar.frame.size.height - 3 , width: viewTopBar.frame.size.width/3, height: 3))
        viewUnderline?.backgroundColor = UIColor(white: 1, alpha: 0.8)
        self.view.addSubview(viewUnderline)
        let url = URL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/news_website")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error == nil {
                do {
                
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                    self.arrayData =  NSMutableArray(array:jsonData)
                    self.updateTbl()
                    } catch {
                // handle error
                }
            }
         }
        task.resume()
        nID = 1
        addPullToRefresh()
        addInfiniteScroll()
        // Do any additional setup after loading the view.
    }
    deinit {
        self.tblView.removePullToRefresh()
        self.tblView.removeInfiniteScroll()
    }

    // MARK: - Add PullToRefresh
    func addPullToRefresh() {
        let animator = DefaultRefreshAnimator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        addPullToRefreshWithAnimator(animator)
    }
    func addPullToRefreshWithAnimator(_ animator: CustomPullToRefreshAnimator) {
        tblView.addPullToRefresh(animator: animator, action: { [weak self] () -> Void in
//            let delayTime = DispatchTime.now() + DispatchTime(uptimeNanoseconds: UInt64(2.0 * Double(NSEC_PER_SEC) / Double(NSEC_PER_SEC)))
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 * Double(NSEC_PER_SEC) / Double(NSEC_PER_SEC)) {
                print("end refreshing")
                self!.refresh()
                self?.tblView?.endRefreshing()
            }
        })
    }
    // MARK: - Add InfiniteScroll
    func addInfiniteScroll() {
        let animator = DefaultInfiniteAnimator(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        addInfiniteScrollWithAnimator(animator)
        
    }
    func addInfiniteScrollWithAnimator(_ animator: CustomInfiniteScrollAnimator) {
        self.tblView.addInfiniteScroll(animator: animator, action: { [weak self] () -> Void in
//            let delayTime = DispatchTime.now() + DispatchTime(uptimeNanoseconds: UInt64(2.0 * Double(NSEC_PER_SEC) / Double(NSEC_PER_SEC)))
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 * Double(NSEC_PER_SEC) / Double(NSEC_PER_SEC)) {
                print("end Infinite scrolling")
                self!.refresh()
                self?.tblView?.endInfiniteScrolling()
            }
        })
    }
    func refresh() {
        // Code to refresh table view
        var url:URL!
        
        if nID == 1 {
            url = URL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/news_website")
        }
        if nID == 2 {
            url = URL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/search_movie")
        }
        if nID == 3 {
            url = URL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/search_music")
        }
        arrayData.removeAllObjects()
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error == nil {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                    self.arrayData.addObjects(from: jsonData as [AnyObject])
                    self.updateTbl()
                } catch {
                    // handle error
                    
                }
                
            }
        }
        task.resume()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateTbl()
    {
		DispatchQueue.main.async {
            self.ivDefault.isHidden = true
            self.tblView.reloadData()
        }
    }
    @IBAction func clickBtnScience(_ sender: AnyObject) {
        viewUnderline.frame = CGRect(x: 0, y: viewTopBar.frame.size.height - 3 , width: viewTopBar.frame.size.width/3, height: 3)

        arrayData.removeAllObjects()
        self.ivDefault.isHidden = false
        let url = URL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/news_website")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            if error == nil {
                do {
                    
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                    self.arrayData.addObjects(from: jsonData as [AnyObject])
                    self.updateTbl()
                    
                } catch {
                    // handle error
                    
                }
            }
         }
        task.resume()
         nID = 1
    }
    @IBAction func clickBtnMovie(_ sender: AnyObject) {
        viewUnderline.frame = CGRect(x: viewTopBar.frame.size.width/3, y: viewTopBar.frame.size.height - 3 , width: viewTopBar.frame.size.width/3, height: 3)
        
        arrayData.removeAllObjects()
        self.ivDefault.isHidden = false
        let url = URL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/search_movie")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
        if error == nil {
                do {
                    
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                    self.arrayData.addObjects(from: jsonData as [AnyObject])
                    self.updateTbl()
                    
                } catch {
                    // handle error
                    
                }
                
            }
            
        }
        task.resume()
        nID = 2
    }
    @IBAction func clickBtnMusic(_ sender: AnyObject) {
        viewUnderline.frame = CGRect(x: viewTopBar.frame.size.width/3*2, y: viewTopBar.frame.size.height - 3 , width: viewTopBar.frame.size.width/3, height: 3)
        arrayData.removeAllObjects()
        self.ivDefault.isHidden = false
        
        let url = URL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/search_music")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
        if error == nil {
                do {
                    
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                    self.arrayData.addObjects(from: jsonData as [AnyObject])
                    self.updateTbl()
                    
                } catch {
                    // handle error
                    
                }
             }
         }
         task.resume()
        nID = 3
    }
    func buttonClicked(_ sender:UIButton)
    {
        let dic = self.arrayData.object(at: sender.tag) as! NSDictionary
        let youtubeUrl = dic.object(forKey: "youtubeUrl") as? String
        let articleUrl = dic.object(forKey: "articleUrl") as? String
        
        print(youtubeUrl)
        
        if (youtubeUrl != nil && (youtubeUrl?.characters.count)! > 0)
        {
            let youtubeID = getYoutubeID(youtubeUrl!)
            let youtubeVideoUrl = "https://www.youtube.com/embed/" + youtubeID
            
            SHYouTube.youtubeInBackground(withYouTubeURL: URL(string: youtubeVideoUrl), completion: { (youtube) in
                
                if (youtube != nil && youtube?.mediumURLPath != nil && (youtube?.mediumURLPath.characters.count)! > 0)
                {
                    let mp = MPMoviePlayerViewController(contentURL: NSURL(string:(youtube?.mediumURLPath)!) as URL!)
                    self.present(mp!, animated: true, completion: nil)
                }
                
            }) { (error) in
                
                print("can't parse url")
            }
        }
        else if (articleUrl != nil && (articleUrl?.characters.count)! > 0)
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "embeddedwebVC") as! EmbeddedWebViewController
            nextViewController.url = URL(string: articleUrl!)!
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblView.dequeueReusableCell(withIdentifier: "videolistCell") as! VideoListTableViewCell!
       
        let dic = self.arrayData.object(at: indexPath.row) as! NSMutableDictionary
        let strTitle = dic.object(forKey: "title") as! String
        let strSiteName = dic.object(forKey: "siteNeme") as! String
        let strPublishDate = dic.object(forKey: "publishDate") as! String
        let youtubeUrl = dic.object(forKey: "youtubeUrl") as? String
        
        
        cell?.lblTitle.text = strTitle as String
        cell?.lblSiteName.text = (strSiteName as String) + "    " + (strPublishDate as String)
        
        if (youtubeUrl != nil && (youtubeUrl?.characters.count)! > 0)
        {
//            let thumbUrl = "https://i1.ytimg.com/vi/" + getYoutubeID(youtubeUrl!) + "/default.jpg"
//
//            print("url =" + thumbUrl)

            let imageurl = dic.object(forKey: "imageUrl") as? String
//            cell.ivPicture.sd_setImageWithURL(NSURL(string: imageurl!))
//            cell.ivPicture.sd_setImageWithURL(NSURL(string: thumbUrl))
            cell?.ivPicture.contentMode = .scaleAspectFit
            cell?.ivPicture.backgroundColor = UIColor.black
        }
        else
        {
            let imageurl = dic.object(forKey: "imageUrl") as? String
//            cell.ivPicture.sd_setImageWithURL(NSURL(string: imageurl!))
            cell?.ivPicture.contentMode = .scaleAspectFit
            cell?.ivPicture.backgroundColor = UIColor.black
        }
        cell?.btnPlay.tag = indexPath.row;
        
        cell?.btnPlay.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
    }
    
}

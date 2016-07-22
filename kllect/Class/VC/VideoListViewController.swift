//
//  VideoListViewController.swift
//  kllect
//
//  Created by topmobile on 5/19/16.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit
import MediaPlayer
import MBProgressHUD
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
        
        viewUnderline = UIView(frame: CGRectMake(0, viewTopBar.frame.size.height - 3 , viewTopBar.frame.size.width/3, 3))
        viewUnderline?.backgroundColor = UIColor(white: 1, alpha: 0.8)
        self.view.addSubview(viewUnderline)
        let url = NSURL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/news_website")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if error == nil {
                do {
                
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSArray
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
    func addPullToRefreshWithAnimator(animator: CustomPullToRefreshAnimator) {
        tblView.addPullToRefresh(animator: animator, action: { [weak self] () -> Void in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
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
    func addInfiniteScrollWithAnimator(animator: CustomInfiniteScrollAnimator) {
        self.tblView.addInfiniteScroll(animator: animator, action: { [weak self] () -> Void in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                print("end Infinite scrolling")
                self!.refresh()
                self?.tblView?.endInfiniteScrolling()
            }
        })
    }
    func refresh() {
        // Code to refresh table view
        var url:NSURL!
        
        if nID == 1 {
            url = NSURL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/news_website")
        }
        if nID == 2 {
            url = NSURL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/search_movie")
        }
        if nID == 3 {
            url = NSURL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/search_music")
        }
        arrayData.removeAllObjects()
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if error == nil {
                do {
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSArray
                    self.arrayData.addObjectsFromArray(jsonData as [AnyObject])
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
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.ivDefault.hidden = true
            self.tblView.reloadData()
        })
    }
    @IBAction func clickBtnScience(sender: AnyObject) {
        viewUnderline.frame = CGRectMake(0, viewTopBar.frame.size.height - 3 , viewTopBar.frame.size.width/3, 3)

        arrayData.removeAllObjects()
        self.ivDefault.hidden = false
        let url = NSURL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/news_website")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            
            if error == nil {
                do {
                    
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSArray
                    self.arrayData.addObjectsFromArray(jsonData as [AnyObject])
                    self.updateTbl()
                    
                } catch {
                    // handle error
                    
                }
            }
         }
        task.resume()
         nID = 1
    }
    @IBAction func clickBtnMovie(sender: AnyObject) {
        viewUnderline.frame = CGRectMake(viewTopBar.frame.size.width/3, viewTopBar.frame.size.height - 3 , viewTopBar.frame.size.width/3, 3)
        
        arrayData.removeAllObjects()
        self.ivDefault.hidden = false
        let url = NSURL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/search_movie")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
        if error == nil {
                do {
                    
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSArray
                    self.arrayData.addObjectsFromArray(jsonData as [AnyObject])
                    self.updateTbl()
                    
                } catch {
                    // handle error
                    
                }
                
            }
            
        }
        task.resume()
        nID = 2
    }
    @IBAction func clickBtnMusic(sender: AnyObject) {
        viewUnderline.frame = CGRectMake(viewTopBar.frame.size.width/3*2, viewTopBar.frame.size.height - 3 , viewTopBar.frame.size.width/3, 3)
        arrayData.removeAllObjects()
        self.ivDefault.hidden = false
        
        let url = NSURL(string: "http://kllect-dev.us-east-1.elasticbeanstalk.com/articles/interest/search_music")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
        if error == nil {
                do {
                    
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSArray
                    self.arrayData.addObjectsFromArray(jsonData as [AnyObject])
                    self.updateTbl()
                    
                } catch {
                    // handle error
                    
                }
             }
         }
         task.resume()
        nID = 3
    }
    func buttonClicked(sender:UIButton)
    {
        let dic = self.arrayData.objectAtIndex(sender.tag) as! NSDictionary
        let youtubeUrl = dic.objectForKey("youtubeUrl") as? String
        let articleUrl = dic.objectForKey("articleUrl") as? String
        
        print(youtubeUrl)
        
        if (youtubeUrl != nil && youtubeUrl?.characters.count > 0)
        {
            let youtubeID = getYoutubeID(youtubeUrl!)
            let youtubeVideoUrl = "https://www.youtube.com/embed/" + youtubeID
            
            SHYouTube.youtubeInBackgroundWithYouTubeURL(NSURL(string: youtubeVideoUrl), completion: { (youtube) in
                
                if (youtube != nil && youtube.mediumURLPath != nil && youtube.mediumURLPath.characters.count > 0)
                {
                    let mp = MPMoviePlayerViewController(contentURL: NSURL(string:youtube.mediumURLPath))
                    self.presentViewController(mp, animated: true, completion: nil)
                }
                
            }) { (error) in
                
                print("can't parse url")
            }
        }
        else if (articleUrl != nil && articleUrl?.characters.count > 0)
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewControllerWithIdentifier("embeddedwebVC") as! EmbeddedWebViewController
            nextViewController.url = NSURL(string: articleUrl!)!
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }

    }
    
    func getYoutubeID(youtubeUrl : String) -> String{
        
        var youtubeID : String = ""
        
        let youtubeUrlFormat1 = "https://www.youtube.com/embed/"
        let youtubeUrlFormat2 = "https://youtu.be/"
        
        if ((youtubeUrl.containsString(youtubeUrlFormat1)) == true)
        {
            youtubeID = (youtubeUrl.componentsSeparatedByString(youtubeUrlFormat1).last?.componentsSeparatedByString("?").first)!
            
        }
        else if((youtubeUrl.containsString(youtubeUrlFormat2)) == true)
        {
            youtubeID = (youtubeUrl.componentsSeparatedByString(youtubeUrlFormat2).last?.componentsSeparatedByString("/").first)!
            
        }

        return youtubeID
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tblView.dequeueReusableCellWithIdentifier("videolistCell") as! VideoListTableViewCell!
       
        let dic = self.arrayData.objectAtIndex(indexPath.row) as! NSMutableDictionary
        let strTitle = dic.objectForKey("title") as! String
        let strSiteName = dic.objectForKey("siteNeme") as! String
        let strPublishDate = dic.objectForKey("publishDate") as! String
        let youtubeUrl = dic.objectForKey("youtubeUrl") as? String
        
        
        cell.lblTitle.text = strTitle as String
        cell.lblSiteName.text = (strSiteName as String) + "    " + (strPublishDate as String)
        
        if (youtubeUrl != nil && youtubeUrl?.characters.count > 0)
        {
//            let thumbUrl = "https://i1.ytimg.com/vi/" + getYoutubeID(youtubeUrl!) + "/default.jpg"
//
//            print("url =" + thumbUrl)

            let imageurl = dic.objectForKey("imageUrl") as? String
            cell.ivPicture.sd_setImageWithURL(NSURL(string: imageurl!))
//            cell.ivPicture.sd_setImageWithURL(NSURL(string: thumbUrl))
            cell.ivPicture.contentMode = .ScaleAspectFit
            cell.ivPicture.backgroundColor = UIColor.blackColor()
        }
        else
        {
            let imageurl = dic.objectForKey("imageUrl") as? String
            cell.ivPicture.sd_setImageWithURL(NSURL(string: imageurl!))
            cell.ivPicture.contentMode = .ScaleAspectFit
            cell.ivPicture.backgroundColor = UIColor.blackColor()
        }
        cell.btnPlay.tag = indexPath.row;
        
        cell.btnPlay.addTarget(self, action: #selector(self.buttonClicked(_:)), forControlEvents: .TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
}

//
//  EmbeddedWebViewController.swift
//  kllect
//
//  Created by topmobile on 6/1/16.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit

class EmbeddedWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var url:NSURL!
    override func viewDidLoad() {
        super.viewDidLoad()
        let requestObj = NSURLRequest(URL: url!);
        webView.loadRequest(requestObj);
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func clickBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

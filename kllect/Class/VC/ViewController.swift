//
//  ViewController.swift
//  kllect
//
//  Created by topmobile on 5/19/16.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let splashGif = UIImage.gifWithName("splash")
        let imageView = UIImageView(image: splashGif)
        imageView.frame = CGRect(x: 0.0, y: 0.0, width:  UIScreen.mainScreen().bounds.size.width, height:  UIScreen.mainScreen().bounds.size.height)
        
        view.addSubview(imageView)
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(2.4, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view, typically from a nib.
    }
    func update() {
        // Something cool
        let secondViewController = self.storyboard!.instantiateViewControllerWithIdentifier("videolistVC") as! VideoListViewController
        self.navigationController!.pushViewController(secondViewController, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


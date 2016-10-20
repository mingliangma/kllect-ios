//
//  VideoPageViewController.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-10-02.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit

class VideoPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	
	private var interestsCount: Int = 1
	private var interestsIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.dataSource = self
		self.delegate = self
		
		self.setViewControllers([UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoTableViewController")], direction: .forward, animated: false, completion: nil)
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.isNavigationBarHidden = true
		self.navigationController?.hidesBarsOnSwipe = false
		self.navigationController?.isToolbarHidden = true

	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		if 0..<self.interestsCount ~= self.interestsIndex - 1 {
			self.interestsIndex -= 1
			return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoTableViewController")
		}
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if 0..<self.interestsCount ~= self.interestsIndex + 1 {
			self.interestsIndex += 1
			return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoTableViewController")
		}
		return nil
	}
	
//	func presentationCount(for pageViewController: UIPageViewController) -> Int {
//		return self.interestsCount
//	}
//	
//	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//		return self.interestsIndex
//	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

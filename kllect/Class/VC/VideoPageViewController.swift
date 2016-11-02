//
//  VideoPageViewController.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-10-02.
//  Copyright © 2016 Kllect Inc. All rights reserved.
//

import UIKit

class VideoPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	
	// TODO: temporary until user interests are implemented
	private var interestsCount: Int = 1
	private var interestsIndex: Int = 0

	// MARK: - UIView
	
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
	
	// MARK: Page View Controller
	
	// provide instance of VideoTableViewController for each user selected interest
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
	
}

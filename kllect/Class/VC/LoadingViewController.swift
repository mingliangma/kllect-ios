//
//  LoadingViewController.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-10-28.
//  Copyright © 2016 Kllect. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

	@IBOutlet private weak var headerLabel: UILabel!
	@IBOutlet private weak var progressBar: UIProgressView!
	
	private var progressTimer: Timer?
	
	override func viewDidAppear(_ animated: Bool) {
		// Create a timer to advance the progress bar simulating a network call/processing for now until implemented
		self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(LoadingViewController.updateProgressBar(sender:)), userInfo: nil, repeats: true)
	}
	
	func updateProgressBar(sender: Timer) {
		guard self.progressBar.progress < 1 else {
			self.progressTimer?.invalidate()
			self.progressTimer = nil
			self.transitionToHomeScreen()
			return
		}
		
		self.progressBar.setProgress(self.progressBar.progress + 0.01, animated: true)
	}
	
	func transitionToHomeScreen() {
		self.performSegue(withIdentifier: "ToHomeScreen", sender: self)
	}

}

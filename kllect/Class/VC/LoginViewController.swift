//
//  LoginViewController.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-10-28.
//  Copyright © 2016 Kllect Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

	@IBOutlet private weak var facebookButton: UIButton!
	@IBOutlet private weak var guestButton: UIButton!
	@IBOutlet private weak var kllectLabel: UILabel!
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.isNavigationBarHidden = true
		self.navigationController?.hidesBarsOnSwipe = false
		self.navigationController?.isToolbarHidden = true
		self.automaticallyAdjustsScrollViewInsets = false
	}

}

//
//  CategoryOverlayView.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-10-14.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit

class CategoryOverlayView: UIView {

	@IBOutlet private weak var categoryLabel: UILabel!
	
	var category: String? {
		didSet {
			self.categoryLabel.text = self.category
		}
	}
	
}
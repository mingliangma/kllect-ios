//
//  InterestsViewController.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-10-28.
//  Copyright © 2016 Kllect. All rights reserved.
//

import UIKit
import ObjectMapper

class InterestsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	@IBOutlet private weak var headerLabel: UILabel!
	@IBOutlet private weak var collectionView: UICollectionView!
	@IBOutlet private weak var continueButton: UIButton!
	@IBOutlet private weak var remainingLabel: UILabel!
	
	private var tags = [Tag]() {
		didSet {
			if let collectionView = self.collectionView {
				DispatchQueue.main.async {
					collectionView.reloadData()
				}
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.getTags()
		self.collectionView.allowsMultipleSelection = true
	}
	
	func getTags() {
		
		let future = Remote.getTags()
		
		future.onComplete { response in
			guard let tags = response.value else {
				// didn't get tags
				return
			}
			self.tags = tags
		}
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.tags.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestCollectionCell", for: indexPath)
		
		let layer = cell.contentView.layer
		layer.borderColor = UIColor.black.cgColor
		layer.borderWidth = 0.5
		layer.cornerRadius = 21
		
		let label = UILabel()
		label.text = self.tags[indexPath.row].displayName
		label.font = UIFont(name: "Colfax-Regular", size: 18)
		label.frame = UIEdgeInsetsInsetRect(cell.contentView.bounds, UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
		label.sizeToFit()
		
		cell.contentView.addSubview(label)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		cell?.contentView.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		cell?.contentView.backgroundColor = UIColor.clear
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let label = UILabel()
		label.text = self.tags[indexPath.row].tagName.replacingOccurrences(of: "_", with: " ").capitalized
		label.font = UIFont(name: "Colfax-Regular", size: 18)
		label.sizeToFit()
		let size = CGSize(width: label.bounds.size.width + 20, height: label.bounds.size.height + 20)
		return size
	}

}

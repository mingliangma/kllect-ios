//
//  MenuViewController.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-09-25.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit
import ObjectMapper
import XCGLogger

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PulleyDelegate {
	
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var appLogoLabel: UILabel!
	@IBOutlet private weak var arrowIcon: UIView!
	
	private var tags = [Tag]() {
		didSet {
			if let tableView = self.tableView {
				DispatchQueue.main.async {
					tableView.reloadData()
				}
			}
		}
	}
	
	private var selectedIndex: IndexPath?
	
	// MARK: - UIView

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		self.getTags()
		if let drawer = self.parent as? PulleyViewController {
			drawer.delegate = self
		}
	}

	override func viewDidLayoutSubviews() {
		if let drawer = self.parent as? PulleyViewController {
			self.drawArrow(view: self.arrowIcon, drawerPosition: drawer.drawerPosition)
		}
	}
	
	// MARK: - Table View Delegate/Data Source
    
	func numberOfSections(in tableView: UITableView) -> Int {
		// First section for Header cell
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		} else {
			return self.tags.count
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if 0 == indexPath.section {
			return 30
		} else {
			return 46
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		
		if 0 == indexPath.section {
			cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath)
			let attributedString = NSAttributedString(string: "Categories".uppercased(), attributes: [NSKernAttributeName: NSNumber(value: 2.0)])
			(cell as! HeaderTableViewCell).titleLabel.attributedText = attributedString
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: "InterestCell", for: indexPath)
			let tag = self.tags[indexPath.row]
			cell.textLabel!.text = tag.displayName
		}
		
		if indexPath != self.selectedIndex {
			cell.accessoryType = .none
		} else {
			cell.accessoryType = .checkmark
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		guard indexPath.section != 0 else {
			return nil
		}
		return indexPath
	}
	
	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return indexPath.section != 0
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let tag = self.tags[indexPath.row]
		// Post a notification to tell Video Table View to load new tag
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowVideosForTag"), object: nil, userInfo: ["Tag": tag])
		
		self.tableView.deselectRow(at: indexPath, animated: false)
		
		// remove checkmark icon on previously selected row
		if let index = self.selectedIndex {
			self.tableView.cellForRow(at: index)?.accessoryType = .none
		}
		
		self.selectedIndex = indexPath
		
		// set checkmark icon on currently selected row
		// Checkmark icon like this will be changing when design decides on final icon
		self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
		
		// close the drawer
		if let drawer = self.parent as? PulleyViewController {
			drawer.setDrawerPosition(position: .collapsed, animated: true)
		}
	}
	
	// MARK: - Pulley Delegate
	
	func drawerPositionDidChange(drawer: PulleyViewController) {
		self.drawArrow(view: self.arrowIcon, drawerPosition: drawer.drawerPosition)
	}
	
	// MARK: - Draw Arrow for menu bar
	
	
	/// Draw an arrow based on the position of the drawer
	///
	/// - parameter view:           The view to draw the arrow in
	/// - parameter drawerPosition: The position of the drawer to determine arrow direction
	func drawArrow(view: UIView, drawerPosition: PulleyPosition) {
		view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
		
		let path: UIBezierPath
		switch drawerPosition {
		case .collapsed:
			path = self.pathForUpwardArrow(inView: self.arrowIcon)
		case .partiallyRevealed:
			path = self.pathForStraightArrow(inView: self.arrowIcon)
		case .open:
			path = self.pathForDownwardArrow(inView: self.arrowIcon)
		}
		
		let shapeLayer = CAShapeLayer()
		shapeLayer.strokeColor = #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2549019608, alpha: 1).cgColor
		shapeLayer.lineWidth = 1.5
		
		shapeLayer.fillColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0).cgColor
		
		shapeLayer.path = path.cgPath
		
		shapeLayer.lineCap = kCALineCapRound
		shapeLayer.lineJoin = kCALineJoinRound
		
		view.layer.addSublayer(shapeLayer)
	}
	
	func pathForUpwardArrow(inView view: UIView) -> UIBezierPath {
		let center = view.convert(view.center, from: self.view)
		
		let path = UIBezierPath()
		path.move(to: center + CGPoint(x: -10, y: 5))
		path.addLine(to: center)
		path.addLine(to: center + CGPoint(x: 10, y: 5))
		
		return path
	}
	
	func pathForStraightArrow(inView view: UIView) -> UIBezierPath {
		let center = view.convert(view.center, from: self.view)
		
		let path = UIBezierPath()
		path.move(to: center + CGPoint(x: -10, y: 0))
		path.addLine(to: center)
		path.addLine(to: center + CGPoint(x: 10, y: 0))
		
		return path
	}
	
	func pathForDownwardArrow(inView view: UIView) -> UIBezierPath {
		let center = view.convert(view.center, from: self.view)
		
		let path = UIBezierPath()
		path.move(to: center + CGPoint(x: -10, y: -5))
		path.addLine(to: center)
		path.addLine(to: center + CGPoint(x: 10, y: -5))
		
		return path
	}
	
	// MARK: - Tap Gesture Recognizer Handler
	
	@IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
		let location = sender.location(in: self.view)
		
		guard let parent = self.parent as? PulleyViewController, location.y < self.tableView.frame.origin.y else {
			return
		}
		
		// Change the position of the menu pulley when header is tapped
		
		switch parent.drawerPosition {
		case .open:
			parent.setDrawerPosition(position: .collapsed, animated: true)
		case .partiallyRevealed:
			// This position was removed by us, but we handle it just in case
			parent.setDrawerPosition(position: .open, animated: true)
		case .collapsed:
			parent.setDrawerPosition(position: .open, animated: true)
		}
	}
	
	// MARK: - Tags
	
	func getTags() {
		let future = Remote.getTags()
		
		future.onComplete { response in
			guard let tags = response.value else {
				log.error("Didn't receive tags from the API")
				return
			}
			self.tags.replaceSubrange(self.tags.startIndex..<self.tags.endIndex, with: tags)
			DispatchQueue.main.async {
				self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: .automatic)
			}
		}
	}
		
}

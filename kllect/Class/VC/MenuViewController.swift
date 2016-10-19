//
//  MenuViewController.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-09-25.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit
import ObjectMapper
import Pulley

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
    
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tags.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "InterestCell", for: indexPath)
		
		let tag = self.tags[indexPath.row]
		cell.textLabel!.text = "\(tag.tagName!.replacingOccurrences(of: "_", with: " ").capitalized)"
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let tag = self.tags[indexPath.row]
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowVideosForTag"), object: nil, userInfo: ["Tag": tag])
		self.tableView.deselectRow(at: indexPath, animated: false)
		if let drawer = self.parent as? PulleyViewController {
			drawer.setDrawerPosition(position: .collapsed, animated: true)
		}
	}
	
	func getTags() {
		print("getting stuff")
		let url = URL(string: "http://api.app.kllect.com/tags")
		let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
			
			if error == nil {
				do {
					print("success")
					let jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [AnyObject]
					self.tags.replaceSubrange(self.tags.startIndex..<self.tags.endIndex, with: Mapper<Tag>().mapArray(JSONObject: jsonData)!)
					DispatchQueue.main.async {
						self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: .automatic)
					}					
				} catch {
					// handle error
					
				}
			}
		}
		task.resume()
	}
	
	func drawerPositionDidChange(drawer: PulleyViewController) {
		self.drawArrow(view: self.arrowIcon, drawerPosition: drawer.drawerPosition)
	}
	
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
		shapeLayer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
		shapeLayer.lineWidth = 2
		
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
	
	@IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
		let location = sender.location(in: self.view)
		
		guard let parent = self.parent as? PulleyViewController, location.y < self.tableView.frame.origin.y else {
			return
		}
		
		switch parent.drawerPosition {
		case .open:
			parent.setDrawerPosition(position: .collapsed, animated: true)
		case .partiallyRevealed:
			parent.setDrawerPosition(position: .open, animated: true)
		case .collapsed:
			parent.setDrawerPosition(position: .open, animated: true)
		}
	}
		
}

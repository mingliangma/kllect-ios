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

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var appLogoLabel: UILabel!
	
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
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
	
}

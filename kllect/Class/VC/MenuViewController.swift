//
//  MenuViewController.swift
//  kllect
//
//  Created by Christopher Primerano on 2016-09-25.
//  Copyright © 2016 topmobile. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource {
	
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var appLogoLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 20
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "InterestCell", for: indexPath)
		
		cell.textLabel?.text = "Interest \(indexPath.row)"
		
		return cell
	}
	
}

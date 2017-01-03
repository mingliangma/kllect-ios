//
//  VerifyEmailController.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-06.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit

class VerifyEmailController: UIViewController {

    @IBOutlet weak var forwardIcon: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var email:String!
    var birthdate:Date!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.title = ""
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setHidesBackButton(true, animated: animated)
    }
    
    func setup() {
        self.statusLabel.text = "A confirmation link was sent to " + self.email
    }

    @IBAction func `continue`(_ sender: UIButton) {
        
        self.forwardIcon.isHidden = true
        self.activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.performSegue(withIdentifier: "SelectTopics", sender: self)
            self.forwardIcon.isHidden = false
            self.activityIndicator.stopAnimating()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SelectTopicsController {
            dest.birthdate = self.birthdate
        }
    }
}

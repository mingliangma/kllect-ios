//
//  LandingController.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-06.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit
import Firebase

class LandingController: UIViewController {

    @IBOutlet weak var termsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.topItem?.title = ""
        setNeedsStatusBarAppearanceUpdate()
        

        self.termsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openTerms)))
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = FIRAuth.auth()?.currentUser {
            showFeed()
        }
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        UserManager.shared.loginWithFacebook(from: self) { user, error in
            if let _ = user {
                self.setupTopics()
            }
        }
    }
    
    func showFeed() {
        let feedController = storyboard!.instantiateViewController(withIdentifier: "FeedController") as! FeedController
        self.present(feedController, animated: false, completion: nil)
    }
    
    func setupTopics() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "SelectTopicsController") as! SelectTopicsController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openTerms() {
        let url = URL(string: "http://docs.kllect.com/kllect-terms-conditions.html")!
        UIApplication.shared.openURL(url)
    }

}











//
//  NavigationController.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-06.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if var topViewController = self.topViewController {
            if let navigationController = topViewController as? UINavigationController {
                topViewController = navigationController.topViewController!
            }
            return topViewController.preferredStatusBarStyle
        }
        
        return super.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        if var topViewController = self.topViewController {
            if let navigationController = topViewController as? UINavigationController {
                topViewController = navigationController.topViewController!
            }
            return topViewController.prefersStatusBarHidden
        }
        
        return super.prefersStatusBarHidden
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if var topViewController = self.topViewController {
            if let navigationController = topViewController as? UINavigationController {
                topViewController = navigationController.topViewController!
            }
            return topViewController.supportedInterfaceOrientations
        }
        
        return super.supportedInterfaceOrientations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: true)
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
}

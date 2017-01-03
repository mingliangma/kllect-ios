 //
//  UserManager.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-07.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class UserManager: NSObject {
    
    static let shared = UserManager()
    
    let fbloginmgr = FBSDKLoginManager()
    
    func newUser(with email:String, password:String, callback: @escaping (Bool, NSError?) -> Void) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user:FIRUser?, error1:Error?) in
            if let u = user {
                u.sendEmailVerification(completion: { (error2:Error?) in
                    callback(error2 == nil, error2 as? NSError)
                })
            }
            else {
                callback(false, error1 as NSError?)
            }
        })
    }
    
    func login(with email:String, password:String, callback:@escaping (FIRUser?, NSError?) -> Void) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user:FIRUser?, error:Error?) in
            callback(user, error as? NSError)
        })
    }
    
    func loginWithFacebook(from vc:UIViewController, callback:@escaping (FIRUser?, NSError?) -> Void) {
        fbloginmgr.logIn(withReadPermissions: ["public_profile", "email"], from: vc) { result, error in
            if let t = result?.token?.tokenString {
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: t)
                FIRAuth.auth()?.signIn(with: credential, completion: { (user:FIRUser?, error:Error?) in
                    callback(user, error as NSError?)
                })
            }
            else {
                callback(nil, nil)
            }
        }
    }
    
}

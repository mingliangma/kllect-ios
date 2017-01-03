//
//  LoginController.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-08.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailSeparator: UIView!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordSeparator: UIView!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var forwardIcon: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var keyboardGuide: NSLayoutConstraint!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupFields()
        setupGesture()
        setupHandleKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailField.becomeFirstResponder()
    }

    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    func setupFields() {
        self.emailField.delegate = self
        self.passwordField.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case emailField:
            emailSeparator.backgroundColor = Color.KLPurple
        case passwordField:
            passwordSeparator.backgroundColor = Color.KLPurple
        default:break
        }
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        switch sender {
        case emailField:
            emailLabel.isHidden = sender.text?.characters.count ?? 0 == 0
        case passwordField:
            passwordLabel.isHidden = sender.text?.characters.count ?? 0 == 0
        default:break
        }
        
        updateValidity()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            passwordField.resignFirstResponder()
        default:break
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case emailField:
            emailSeparator.backgroundColor = UIColor(white: 0.8, alpha: 1)
        case passwordField:
            passwordSeparator.backgroundColor = UIColor(white: 0.8, alpha: 1)
        default:break
        }
    }
    
    func updateValidity() {
        if let e = emailField.text, e.isValidEmail(), let p = passwordField.text, p.characters.count > 0 {
            self.statusLabel.text = "Continue"
            self.continueButton.isEnabled = true
            showContinue()
        }
        else {
            self.statusLabel.text = "Enter your details above"
            hideContinue()
            self.continueButton.isEnabled = false
        }
    }
    
    func showContinue() {
        if !forwardIcon.isHidden { return }
        self.forwardIcon.isHidden = false
        self.forwardIcon.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: .beginFromCurrentState, animations: {
            self.forwardIcon.transform = CGAffineTransform.identity
        }) { (completed:Bool) in
            
        }
    }
    
    func hideContinue() {
        if forwardIcon.isHidden { return }
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: .beginFromCurrentState, animations: { 
            self.forwardIcon.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }) { (completed:Bool) in
            self.forwardIcon.isHidden = true
            self.forwardIcon.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        continueButton.isEnabled = false
        forwardIcon.isHidden = true
        activityIndicator.startAnimating()
        UserManager.shared.login(with: emailField.text!, password: passwordField.text!) { user, error in
            if let _ = user {
                let feedController = self.storyboard!.instantiateViewController(withIdentifier: "FeedController") as! FeedController
                self.navigationController?.present(feedController, animated: true, completion: nil)
                _ = self.navigationController?.popToRootViewController(animated: false)
            }
            else {
                self.activityIndicator.stopAnimating()
                self.forwardIcon.isHidden = false
                self.continueButton.isEnabled = true
                SVProgressHUD.showError(withStatus: "There was a problem with the login.\nPlease try again")
            }
        }
    }
    
    
    func setupHandleKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification:Notification) {
        if let kbHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            UIView.animate(withDuration: 0.3, animations: { 
                self.keyboardGuide.constant = kbHeight
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification:Notification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.keyboardGuide.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    
}


















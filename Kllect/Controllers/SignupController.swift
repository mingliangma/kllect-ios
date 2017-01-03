//
//  SignupController.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-06.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignupController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var birthdayField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var birthdaySeparator: UIView!
    @IBOutlet weak var emailSeparator: UIView!
    @IBOutlet weak var passwordSeparator: UIView!
    
    @IBOutlet weak var forwardIcon: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var termsLabel: UILabel!
    
    var datePicker:UIDatePicker!
    var dateEntered = false

    let dateFormatter = DateFormatter()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.navigationBar.topItem?.title = ""

        setupFields()
        setupOther()
        
        self.termsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openTerms)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !dateEntered {
            birthdayField.becomeFirstResponder()
            updateDateText()
        }
    }

    func setupOther() {
        forwardIcon.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
    }
    
    // MARK: TextField Management
    
    func setupFields() {
        datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
        datePicker.datePickerMode = .date
        datePicker.date = Date().addingTimeInterval(-20 * 365 * 24 * 60 * 60) // - 20 years
        datePicker.minimumDate = Date().addingTimeInterval(-80 * 365 * 24 * 60 * 60) // - 80 years
        datePicker.maximumDate = Date()
        birthdayField.delegate = self
        birthdayField.tintColor = UIColor.clear
        birthdayField.inputView = datePicker
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    func updateActiveField() {
        birthdaySeparator.backgroundColor = birthdayField.isFirstResponder ? Color.KLPurple:UIColor(white: 0.8, alpha: 1)
        emailLabel.isHidden = emailField.text?.characters.count ?? 0 == 0
        emailSeparator.backgroundColor = emailField.isFirstResponder ? Color.KLPurple:UIColor(white: 0.8, alpha: 1)
        passwordLabel.isHidden = passwordField.text?.characters.count ?? 0 == 0
        passwordSeparator.backgroundColor = passwordField.isFirstResponder ? Color.KLPurple:UIColor(white: 0.8, alpha: 1)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == birthdayField {
            updateDateText()
        }
        updateActiveField()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            passwordField.resignFirstResponder()
        default:
            break
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateActiveField()
        updateValidity()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == birthdayField {
            return false
        }
        
        return true
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        updateActiveField()
    }
    
    func updateValidity() {
        if let email = emailField.text, let password = passwordField.text, email.isValidEmail(), password.characters.count > 6 {
            self.statusLabel.text = "Continue"
            self.forwardIcon.isHidden = false
        }
        else {
            self.statusLabel.text = "Enter your details above"
            self.forwardIcon.isHidden = true
        }
    }
    
    func openTerms() {
        let url = URL(string: "http://docs.kllect.com/kllect-terms-conditions.html")!
        UIApplication.shared.openURL(url)
    }
    
    
    // MARK: Date picker management
    
    func updateDateText() {
        let date = self.datePicker.date
        birthdayField.text = self.dateFormatter.string(from: date)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        updateDateText()
        dateEntered = true
    }
    
    // MARK: Actions
    
    @IBAction func `continue`(_ sender: UIButton) {
        dateEntered = true
        
        self.birthdayField.isEnabled = false
        self.emailField.isEnabled = false
        self.passwordField.isEnabled = false
        sender.isEnabled = false
        self.activityIndicator.startAnimating()
        self.forwardIcon.isHidden = true
        
        UserManager.shared.newUser(with: emailField.text!, password: passwordField.text!) { success, error in
            if success {
                self.performSegue(withIdentifier: "VerifyEmail", sender: self)
            }
            else {
                SVProgressHUD.showError(withStatus: error?.localizedDescription ?? "An unknown error occurred. Please try again later")
            }
            self.birthdayField.isEnabled = true
            self.emailField.isEnabled = true
            self.passwordField.isEnabled = true
            sender.isEnabled = true
            self.activityIndicator.stopAnimating()
            self.forwardIcon.isHidden = false
        }
    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? VerifyEmailController {
            dest.email = emailField.text
            dest.birthdate = datePicker.date
        }
    }

}










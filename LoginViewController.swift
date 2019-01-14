//
//  ViewController.swift
//  on The Map
//
//  Created by Bushra on 30/12/2018.
//  Copyright © 2018 Bushra Alkhushiban. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        passwordField.resignFirstResponder()
        
        guard let username = emailField.text else {return}
        guard let password = passwordField.text else {return}
        
        ActivityIndicator.startActivityIndicator(view: self.view)
        
        if username.isEmpty || password.isEmpty {
            ActivityIndicator.stopActivityIndicator()
            let title = "Fill the required fields"
            let message = "Please fill both the email and password"
            displayAlert.displayAlert(message: message, title: title, vc: self)
            
        } else {
            API.login(username, password){(loginSuccess, key, error) in
                DispatchQueue.main.async {
                    
                    //Eerror Message
                    
                    if error != nil {
                        ActivityIndicator.stopActivityIndicator()
                        let title = "Erorr performing request"
                        let message = "There was an error performing your request"
                        displayAlert.displayAlert(message: message, title: title, vc: self)
                        return
                    }
                    
                    //check Error
                    if !loginSuccess {
                        ActivityIndicator.stopActivityIndicator()
                        
                        let title = "Erorr logging in"
                        let message = "incorrect email or password"
                        displayAlert.displayAlert(message: message, title: title, vc: self)
                    } else {
                        ActivityIndicator.stopActivityIndicator()
                        self.performSegue(withIdentifier: "TabBarController", sender: nil)
                        print ("the key is \(key)")
                        // add key to the app delegate
                        (UIApplication.shared.delegate as! AppDelegate).uniqueKey = key
                    }
                }}
        }
    }
    
    
    
    @IBAction func signupButton(_ sender: Any) {
        guard let url = URL(string: "https://auth.udacity.com/sign-up") else {return}
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Opened url : \(success)")
            })
        }
    }
    
    /*//keyboard Methods
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if emailField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
        if passwordField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    */
    
    // Validation fields
    func isValidateEmail(email:String) -> Bool {
        return (email.count >= 7) && (email.contains("@")) && (email.contains("."))
    }
    
    func isValidatePassword(password:String) -> Bool {
        return password.count >= 6
    }
    
}


extension LoginViewController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }
    
}


extension LoginViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == emailField {
            if !isValidateEmail(email: textField.text!) {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
                errorLabel.text = "Bad Email format..."
            } else {
                textField.layer.borderWidth = 0.0
                errorLabel.text = ""
            }
        }
        
        if textField == passwordField {
            if !isValidatePassword(password: textField.text!) {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
                errorLabel.text = "Short Password..."
            } else {
                textField.layer.borderWidth = 0.0
                errorLabel.text = ""
            }
        }
        
        return true
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderWidth = 0
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

    


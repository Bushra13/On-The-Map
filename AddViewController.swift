//
//  AddViewController.swift
//  on The Map
//
//  Created by Bushra on 05/01/2019.
//  Copyright © 2019 Bushra Alkhushiban. All rights reserved.
//

import UIKit
import MapKit

class AddViewController: UIViewController {

 
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var mediaField: UITextField!
    
    var latitude : Double?
    var longitude : Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationName.delegate = self
        mediaField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    //to find location
    
    @IBAction func findLocation(_ sender: Any) {
        
        mediaField.resignFirstResponder()
        locationName.resignFirstResponder()
        
        guard let websiteLink = mediaField.text else {return}
        
        let prefixOfwebsiteLinkFirst = String(websiteLink.prefix(7))
        let prefixOfwebsiteLinkSecond = String(websiteLink.prefix(8))
        
   
        
        let rangeCheckBool = (websiteLink.range(of:"http://") == nil ) || (websiteLink.range(of:"https://") == nil )
        let prefixCheckBool = (prefixOfwebsiteLinkFirst == "http://") || (prefixOfwebsiteLinkSecond == "https://")
        
        if  rangeCheckBool  &&  !prefixCheckBool {
            
            let title = "Invalid URL"
            let message = "No http:// or https:// in website link."
            displayAlert.displayAlert(message: message, title: title, vc: self)
            
            
        } else {
            if locationName.text != "" && mediaField.text != "" {
                
                ActivityIndicator.startActivityIndicator(view: self.view )
                
                let searchRequest = MKLocalSearch.Request()
                searchRequest.naturalLanguageQuery = locationName.text
                
                let activeSearch = MKLocalSearch(request: searchRequest)
                
                activeSearch.start { (response, error) in
                    
                    if error != nil {
                        ActivityIndicator.stopActivityIndicator()
                        let title = "Location not found."
                        let message = "Location Error : \(error!.localizedDescription)."
                        displayAlert.displayAlert(message: message, title: title, vc: self)
                        
                    }else {
                        ActivityIndicator.stopActivityIndicator()
                        self.latitude = response?.boundingRegion.center.latitude
                        self.longitude = response?.boundingRegion.center.longitude
                        self.performSegue(withIdentifier: "confirmAddInfoSegue", sender: nil)
                    }
                }
            }else {
                
                let title = "Location error."
                let message = "Enter URL or Location"
                displayAlert.displayAlert(message: message, title: title, vc: self)
            }
        }
        
    }
    
    //segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmAddInfoSegue"{
            let vc = segue.destination as! ConfirmAddInfoViewController
            vc.latitude = self.latitude
            vc.longitude = self.longitude
            vc.mapString = locationName.text
            vc.mediaURL = mediaField.text
            
        }
        
    }
    

    //keyboard methods
    func subscribeToKeyboardNotifications() {
      
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
     
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if mediaField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)/2
        }
        if locationName.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)/2
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
    
    
}

extension AddViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

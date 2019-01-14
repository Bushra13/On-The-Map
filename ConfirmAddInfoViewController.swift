//
//  ConfirmAddInfoViewController.swift
//  on The Map
//
//  Created by Bushra on 05/01/2019.
//  Copyright © 2019 Bushra Alkhushiban. All rights reserved.
//

import UIKit
import MapKit

class ConfirmAddInfoViewController: UIViewController,MKMapViewDelegate {

    var firstName : String?
    var mapString:String?
    var mediaURL:String?
    var latitude:Double?
    var longitude:Double?
    var uniqueKey = (UIApplication.shared.delegate as! AppDelegate).uniqueKey
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        createAnnotation()
    }
    @IBAction func finishButton(_ sender: Any) {
        ActivityIndicator.startActivityIndicator(view: self.view)
        API.postStudentLocation(mapString, mediaURL, uniqueKey, latitude, longitude) { (studentsLocation, error) in
            
            DispatchQueue.main.async {
                
                if error != nil {
                    ActivityIndicator.stopActivityIndicator()
                    
                    let title = "Erorr performing request."
                    let message = "There was an error performing your request"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                    
                    return
                }
                ActivityIndicator.stopActivityIndicator()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func createAnnotation(){
        
        let annotation = MKPointAnnotation()
        annotation.title = mapString!
        annotation.subtitle = mediaURL!
        annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
        mapView.addAnnotation(annotation)
        
        //Zoom to location
        
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    
    //delegate 
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}

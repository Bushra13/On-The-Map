//
//  MapViewController.swift
//  on The Map
//
//  Created by Bushra on 05/01/2019.
//  Copyright © 2019 Bushra Alkhushiban. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    
    @IBAction func logOut(_ sender: Any) {
        API.deleteSession { (logoutSuccess, key, error) in
            
            DispatchQueue.main.async {
                //error
                if error != nil {
                    let title = "Erorr performing request"
                    let message = "There was an error: \(error?.localizedDescription ?? "?")"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                    return
                }
                
                //check error
                if !logoutSuccess {
                    let title = "Erorr logging out"
                    let message = "There was an error: \(error?.localizedDescription ?? "?")"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                } else {
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    print ("the key is \(key)")
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLocation()
    }
    @IBAction func refreshClick(_ sender: Any) {
        getLocation()
    }
    
    
    func getLocation () {
        
        ActivityIndicator.startActivityIndicator(view: self.mapView)
        //To Remove pins
        mapView.removeAnnotations(mapView.annotations)
        
        API.getAllLocations () {(studentsLocations, error) in
            
            DispatchQueue.main.async {
                
                if error != nil {
                    ActivityIndicator.stopActivityIndicator()
                    let title = "Erorr performing request"
                    let message = "There was an error: \(error?.localizedDescription ?? "?")"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                    return
                }
                
                var annotations = [MKPointAnnotation] ()
                
                guard let locationsArray = studentsLocations else {
                    let title = "Erorr loading locations"
                    let message = "There was an error: \(error?.localizedDescription ?? "?")"
                    displayAlert.displayAlert(message: message, title: title, vc: self)
                    return
                }
                
                for locationStruct in locationsArray {
                    
                    let long = CLLocationDegrees (locationStruct.longitude ?? 0)
                    let lat = CLLocationDegrees (locationStruct.latitude ?? 0)
                    
                    let coords = CLLocationCoordinate2D (latitude: lat, longitude: long)
                    let mediaURL = locationStruct.mediaURL ?? " "
                    let first = locationStruct.firstName ?? " "
                    let last = locationStruct.lastName ?? " "
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coords
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    annotations.append (annotation)
                }
                ActivityIndicator.stopActivityIndicator()
                self.mapView.addAnnotations (annotations)
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
  
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}


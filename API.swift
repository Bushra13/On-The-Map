//
//  API.swift
//  on The Map
//
//  Created by Bushra on 31/12/2018.
//  Copyright © 2018 Bushra Alkhushiban. All rights reserved.
//


import UIKit

class API {
    
    static func login(_ username : String!, _ password : String!, completion: @escaping (Bool, String, Error?)->()) {
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username!)\", \"password\": \"\(password!)\"}}".data(using: .utf8)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completion (false, "", error)
                return
            }
            
            //check if the response is OK or not
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                completion (false, "", error)
                return
            }
            
            if statusCode >= 200  && statusCode < 300 {
                
                //Skipping the first 5 characters
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range) /* subset response data! */
                
                //Print the data
                print (String(data: newData!, encoding: .utf8)!)
                
                let json = try! JSONSerialization.jsonObject(with: newData!, options: []) as? [String : Any]
                
                //Get the unique key of the user
                let accountDictionary = json? ["account"] as? [String : Any]
                let uniqueKey = accountDictionary? ["key"] as? String ?? " "
                completion (true, uniqueKey, nil)
            } else {
                completion (false, "", nil)
            }
        }
        //Start the task
        task.resume()
    }
    
    
    //Delete session function
    
    static func deleteSession (completion: @escaping (Bool, String, Error?)->() ) {
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completion (false, "", error)
                return
            }
            
            //check if the response is OK or not
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                completion (false, "", error)
                return
            }
            if statusCode >= 200  && statusCode < 300 {
                
                //Skipping the first 5 characters
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range) /* subset response data! */
                
                //Print the data
                print (String(data: newData!, encoding: .utf8)!)
                
                let json = try! JSONSerialization.jsonObject(with: newData!, options: []) as? [String : Any]
                
                //Get the unique key of the user
                let accountDictionary = json? ["account"] as? [String : Any]
                let uniqueKey = accountDictionary? ["key"] as? String ?? " "
                completion (true, uniqueKey, nil)
            } else {
                completion (false, "", nil)
            }
        }
        
        task.resume()
        
    }
    
    //Parse get all Locations function
    static func getAllLocations (completion: @escaping ([StudentLocation]?, Error?) -> ()) {
        
        var request = URLRequest (url: URL (string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            guard error == nil else {
                completion (nil, error)
                return
            }
            
            print (String(data: data!, encoding: .utf8)!)
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                completion (nil, error)
                return
            }
            
            if statusCode >= 200 && statusCode < 300 {
                let result = try! JSONDecoder().decode(Result.self, from: data!)
                completion (result.results, nil)
            }
            }.resume()
    }
    
    
    //Posting student location function
    
    static func postStudentLocation (_ mapString : String!, _ mediaURL : String!,_ uniqueKey :String!, _ latitude : Double!,_ longitude : Double!,  completion: @escaping (StudentLocation?, Error?) -> ()) {
        
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey ?? "?")\", \"firstName\": \"\("firstName")\", \"lastName\": \"\("lastName")\",\"mapString\": \"\(mapString ?? "?")\", \"mediaURL\": \"\(mediaURL ?? "?")\",\"latitude\": \(latitude ?? 0.00), \"longitude\": \(longitude ?? 0.00)}".data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) {data, response, error in
            guard error == nil else {
                completion (nil, error)
                return
            }
            print (String(data: data!, encoding: .utf8)!)
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                completion (nil, error)
                return
            }
            
            if statusCode >= 200 && statusCode < 300 {
                let result = try! JSONDecoder().decode(singleResult.self, from: data!)
                completion (result.singleResult, nil)
            }
            }.resume()
    }
    
}

//Result for all locations

class Result: Codable {
    var results: [StudentLocation]?
}

//Result for single locations
struct singleResult: Codable {
    var singleResult: StudentLocation?
}



//
//  KMKatsanaAPI+Login.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation
import SwiftyJSON
import Siesta

extension KatsanaAPI {
    
    public func login(email: String, password: String, completion: (_ user: String) -> Void) -> Void {
        let path = self.baseURL().absoluteString + "auth"
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "POST"
        let postString = "email=" + email + "&password=" + password;
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let json = JSON(data: data)
            let token = json["token"].string
            if token != nil {
                DispatchQueue.main.async {
                    self.authToken = token
                    self.API.resource("profile").addObserver(owner: self) {
                        [weak self] resource, event in
                        let user : KMUser? = resource.typedContent()
                        self?.currentUser = user;
                        
                    }.loadIfNeeded()?.onFailure({ (error) in
                        
                    })
                }
            }
        }
        task.resume()
    }
}

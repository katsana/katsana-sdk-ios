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
    
    public func login(email: String, password: String, completion: @escaping (_ user: KMUser?) -> Void) -> Void {
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
                    let resource = self.API.resource("profile")
                    resource.loadIfNeeded()?.onSuccess({ (entity) in
                        let user : KMUser? = resource.typedContent()
                        self.currentUser = user
                        completion(user)
                    }).onFailure({ (error) in
                        completion(nil)
                    })
                }
            }
        }
        task.resume()
    }
    
    public func refreshToken(completion: @escaping (_ success: Bool) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        guard self.authToken != nil else {
            failure(nil)
            return
        }
        
        let path = "auth/refresh"
        let resource = API.resource(path);
        resource.load().onSuccess({ (entity) in
            let content = entity.content as? JSON
            let dicto = content?.rawValue as? [String : String]
            if dicto != nil{
                let token = dicto?["token"]
                self.authToken = token
                completion(true)
            }else{
                failure(nil)
            }
        }).onFailure({ (error) in
            failure(error)
        })
    }
}

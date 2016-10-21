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
    
    
    public func login(email: String, password: String, completion: @escaping (_ user: KMUser?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        
        
        let useOAuth2 = false
        var data : Dictionary<String,String>
        var tokenKey = "token"
        var authPath = "auth"
        if useOAuth2 {
            tokenKey = "access_token"
            authPath = "oauth/token"
            data = ["username" : email, "password" : password, "client_id" : self.clientId, "client_secret" : self.clientSecret, "scope" : "*", "grant_type": self.grantType]
        }else{
            data = ["email" : email, "password" : password]
        }

        let path = self.baseURL().absoluteString + authPath
        Just.post(
            path,
            data: data
        ) { r in
            if r.ok {
                let json = JSON(data: r.content!)
                let token = json[tokenKey].string
                if token != nil {
                    DispatchQueue.main.sync {
                        self.authToken = token
                        let resource = self.API.resource("profile")
                        resource.loadIfNeeded()?.onSuccess({ (entity) in
                            let user : KMUser? = resource.typedContent()
                            self.currentUser = user
                            completion(user)
                        }).onFailure({ (error) in
                            failure(error)
                        })
                    }
                }else{
                    failure(r.error)
                }
            }else{
                let json = JSON(data: r.content!)
                var errorString = json["error"].string
                let status : Int = r.statusCode!
                print(errorString)
                switch status {
                case 401:
                    errorString = "Invalid login details"
                default:
                    ()
                }
                
                let userInfo: [String : String] = [ NSLocalizedDescriptionKey :  errorString!, NSLocalizedFailureReasonErrorKey : json["error"].string!]
                let error = NSError(domain: APIError.domain, code: status, userInfo: userInfo)
                DispatchQueue.main.sync {
                    failure(error)
                }
            }
        }
    }
    
    public func login() -> Void {
        let headers = [
            "content-type": "multipart/form-data; boundary=---011000010111000001101001",
            "accept": "application/vnd.KATSANA.v1+json"
        ]
        let parameters = [
            [
                "name": "client_id",
                "value": "2"
            ],
            [
                "name": "client_secret",
                "value": "1JLd2k0X6RBqRmJuJiZmXulMCc3WQyqnCgeoYdpE"
            ],
            [
                "name": "grant_type",
                "value": "password"
            ],
            [
                "name": "username",
                "value": "hello@katsana.com"
            ],
            [
                "name": "password",
                "value": "katsini!"
            ],
            [
                "name": "scope",
                "value": "*"
            ]
        ]
        
        let boundary = "---011000010111000001101001"
        
        var body = ""
        var error: NSError? = nil
        for param in parameters {
            let paramName = param["name"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if let filename = param["fileName"] {
                let contentType = param["content-type"]!
                let fileContent = try? String(contentsOfFile: filename, encoding: String.Encoding.utf8)
                body += "; filename=\"\(filename)\"\r\n"
                body += "Content-Type: \(contentType)\r\n\r\n"
                body += fileContent!
            } else if let paramValue = param["value"] {
                body += "\r\n\r\n\(paramValue)"
            }
        }
        
        var request = URLRequest(url: NSURL(string: "https://carbon.api.katsana.com/oauth/token")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response
                let json = JSON(data: data!)
                print(httpResponse)
            }
        })
        
        dataTask.resume()
    }
    
    
    public func logout() -> Void {
        NotificationCenter.default.post(name: KatsanaAPI.userWillLogoutNotification, object: nil)
        currentVehicle = nil;
        vehicles = nil
        currentUser = nil
        authToken = nil
        NotificationCenter.default.post(name: KatsanaAPI.userDidLogoutNotification, object: nil)
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

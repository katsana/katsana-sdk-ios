//
//  KMKatsanaAPI+Login.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation
import XCGLogger

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
                var errorString = json["error"].stringValue
                if let status : Int = r.statusCode{
                    print(errorString)
                    switch status {
                    case 401:
                        errorString = "Invalid login details"
                    default:
                        ()
                    }
                    print(status)
                    let userInfo: [String : String] = [ NSLocalizedDescriptionKey :  errorString, NSLocalizedFailureReasonErrorKey : json["error"].string!]
                    let error = NSError(domain: APIError.domain, code: status, userInfo: userInfo)
                    DispatchQueue.main.sync {
                        failure(error)
                    }
                }else{
                    DispatchQueue.main.sync {
                        failure(nil)
                    }
                }
                
            }
        }
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

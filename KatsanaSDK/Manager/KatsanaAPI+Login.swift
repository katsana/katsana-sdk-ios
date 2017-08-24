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

    public func loginJWT(name: String, password: String, nameKey: String = "email", authPath: String = "auth", completion: @escaping () -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let useOAuth2 = false
        var data = [nameKey : name, "password" : password]
        var tokenKey = "token"

        let path = self.baseURL().absoluteString + authPath
        Just.post(
            path,
            data: data
        ) { r in
            if r.ok {
                let json = JSON(data: r.content!)
                let token = json["token"].string
                if token != nil {
                    DispatchQueue.main.sync {
                        self.authToken = token
                        NotificationCenter.default.post(name: KatsanaAPI.userSuccessLoginNotification, object: nil)
                        completion()
                    }
                }else{
                    failure(r.error)
                }
            }else{
                let json = JSON(data: r.content!)
                var errorString = json["error"].stringValue
                if let status : Int = r.statusCode, let jsonError = json["error"].string{
                    print(errorString)
                    switch status {
                    case 401:
                        errorString = "Invalid login details"
                    default:
                        errorString = statusCodeDescriptions[status]!
                    }
                    let userInfo: [String : String] = [ NSLocalizedDescriptionKey :  errorString, NSLocalizedFailureReasonErrorKey : jsonError]
//                    let error = NSError(domain: SDKError.domain, code: status, userInfo: userInfo)
                    DispatchQueue.main.sync {
                        failure(r.APIError())
                    }
                    self.log.info("Error logon \(r.APIError())")
                }else{
                    DispatchQueue.main.sync {
                        failure(r.APIError())
                        self.log.info("Error logon \(r.APIError())")
                    }
                }
            }
        }
    }
    
    public func login(email: String, password: String, completion: @escaping (_ user: User?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        var data : Dictionary<String,String>
        let tokenKey = "access_token"
        let authPath = "oauth/token"

        data = ["username" : email, "password" : password, "client_id" : self.clientId, "client_secret" : self.clientSecret, "scope" : "*", "grant_type": self.grantType]

        let path = self.baseURL().absoluteString + authPath
        Just.post(
            path,
            data: data
        ) { r in
            if r.ok {
                let json = JSON(data: r.content!)
                let token = json[tokenKey].stringValue
                let refreshToken = json["refresh_token"].stringValue
                
                if token.characters.count > 0 {
                    DispatchQueue.main.sync {
                        self.authToken = token
                        self.refreshToken = refreshToken
                        let resource = self.API.resource("profile")
                        resource.loadIfNeeded()?.onSuccess({ (entity) in
                            let user : User? = resource.typedContent()
                            if let user = user{
                                self.currentUser = user
                                completion(user)
                                NotificationCenter.default.post(name: KatsanaAPI.userSuccessLoginNotification, object: nil)
                                self.log.info("Logged in user \(user.userId), \(user.email)")
                                CacheManager.shared.cache(user: user)
                            }else{
                                failure(nil)
                            }
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
                if let status : Int = r.statusCode, let jsonError = json["error"].string{
                    print(errorString)
                    switch status {
                    case 401:
                        errorString = "Invalid login details"
                    default:
                        errorString = statusCodeDescriptions[status]!
                    }
                    let userInfo: [String : String] = [ NSLocalizedDescriptionKey :  errorString, NSLocalizedFailureReasonErrorKey : jsonError]
                    let error = NSError(domain: SDKError.domain, code: status, userInfo: userInfo)
                    DispatchQueue.main.sync {
                        failure(error)
                    }
                    
                    self.log.info("Error logon \(r.APIError())")
                }else{
                    DispatchQueue.main.sync {
                        failure(r.error)
                        self.log.info("Error logon \(r.APIError())")
                    }
                }
                
            }
        }
    }
        
    public func logout() -> Void {
        NotificationCenter.default.post(name: KatsanaAPI.userWillLogoutNotification, object: nil)
        currentVehicle = nil
        if vehicles != nil {
            vehicles = nil
        }
        currentUser = nil
        authToken = nil
        NotificationCenter.default.post(name: KatsanaAPI.userDidLogoutNotification, object: nil)
        log.info("Logged out user \(self.currentUser?.userId), \(self.currentUser?.email)")
        CacheManager.shared.clearTravelCache(vehicleId: "-1")
    }
    
    public func verify(password:String, completion: @escaping (_ success: Bool) -> Void) -> Void {
        guard self.authToken != nil else {
            completion(false)
            return
        }

        let path = self.baseURL().absoluteString + "auth/verify"
        Just.post(
            path,
            data: ["password" : password],
            headers: ["Authorization" : ("Bearer " + self.authToken)]
        ) { r in
            if r.ok{
                let json = JSON(data: r.content!)
                let success = json["success"].boolValue
                DispatchQueue.main.sync {
                    completion(success)
                }
            }else{
                DispatchQueue.main.sync {
                    completion(false)
                }
            }
        }
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

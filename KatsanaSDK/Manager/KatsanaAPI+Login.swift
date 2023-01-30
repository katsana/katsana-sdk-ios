//
//  KMKatsanaAPI+Login.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation
import XCGLogger
import Siesta

extension KatsanaAPI {
    
    public func loginJWT(name: String, password: String, nameKey: String = "email", authPath: String = "auth", completion: @escaping () -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        //        let useOAuth2 = false
        let data = [nameKey : name, "password" : password]
        
        let resource = self.API.resource(authPath)
        resource.request(.post, json: NSDictionary(dictionary: data)).onSuccess({ (entity) in
            if let json = entity.content as? JSON{
                let token = json["token"].stringValue
//                let refreshToken = json["refresh_token"].stringValue
//                self.refreshToken = refreshToken
                self.authToken = token
                NotificationCenter.default.post(name: KatsanaAPI.userSuccessLoginNotification, object: nil)
                completion()
            }else{
                failure(nil)
            }
        }).onFailure({ (error) in
            failure(error)
        })
    }

    public func login(email: String, password: String, completion: @escaping (_ user: KTUser?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        var data : Dictionary<String,String>
        let tokenKey = "access_token"
        let authPath = "oauth/token"
        
        data = ["username" : email, "password" : password, "client_id" : self.clientId, "client_secret" : self.clientSecret, "scope" : "*", "grant_type": self.grantType]
        
        let resource = self.API.resource(authPath)
        resource.request(.post, json: NSDictionary(dictionary: data)).onSuccess({ (entity) in
            if let json = entity.content as? JSON{
                let token = json[tokenKey].stringValue
                let refreshToken = json["refresh_token"].stringValue
                if token.count > 0 {
                    self.authToken = token
                    self.refreshToken = refreshToken
                    NotificationCenter.default.post(name: KatsanaAPI.userSuccessLoginNotification, object: nil)
                    self.loadProfile(completion: { (user) in
                        completion(user)
                    }, failure: { (error) in
                        self.loadProfile(completion: { (user) in
                            completion(user)
                        }, failure: { (error) in
                            self.loadProfile(completion: { (user) in
                                completion(user)
                            }, failure: { (error) in
                                failure(error)
                            })
                        })
                        
                    })
                }else{
                    failure(nil)
                }
            }
        }).onFailure({ (error) in
            print(error.errorDescription)
            let theError = NSError(domain: "KatsanaSDKErrorDomain", code: error.httpStatusCode ?? 0, userInfo: [NSLocalizedDescriptionKey: error.userMessage])
            failure(theError)
        })
        
    }
    
    public func login(token: String, completion: @escaping (_ user: KTUser?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        if token.count > 0{
            self.authToken = token
            
            self.loadProfile(completion: { (user) in
                NotificationCenter.default.post(name: KatsanaAPI.userSuccessLoginNotification, object: nil)
                completion(user)
            }, failure: { (error) in
                self.loadProfile(completion: { (user) in
                    NotificationCenter.default.post(name: KatsanaAPI.userSuccessLoginNotification, object: nil)
                    completion(user)
                }, failure: { (error) in
                    self.loadProfile(completion: { (user) in
                        NotificationCenter.default.post(name: KatsanaAPI.userSuccessLoginNotification, object: nil)
                        completion(user)
                    }, failure: { (error) in
                        failure(error)
                    })
                })
                
            })
        }
    }
    
    private func loadProfile(completion: @escaping (_ user: KTUser?) -> Void, failure: @escaping (_ error: RequestError?) -> Void) {
        var resource = self.API.resource("profile")
        if let options = defaultRequestProfileOptions{
            let text = options.joined(separator: ",")
            resource = resource.withParam("includes", text)
        }
        
        resource.loadIfNeeded()?.onSuccess({ (entity) in
            let user : KTUser? = resource.typedContent()
            if let user = user{
                self.currentUser = user
                completion(user)
                NotificationCenter.default.post(name: KatsanaAPI.userSuccessLoginNotification, object: nil)
                self.log.info("Logged in user \(String(describing: user.userId)), \(user.email)")
                self.cache?.cache(user: user)
            }else{
                failure(nil)
            }
        }).onFailure({ (error) in
            failure(error)
        })
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
        log.info("Logged out user \(self.currentUser?.userId ?? "??"), \(self.currentUser?.email ?? "")")
        self.cache?.clearTravelCache(vehicleId: "-1")
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
                DispatchQueue.main.sync{completion(success)}
            }else{
                DispatchQueue.main.sync{completion(false)}
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
    
    public func requestUser(completion: @escaping (_ user: KTUser) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void{
        let resource = self.API.resource("profile")
        resource.load().onSuccess({ (entity) in
            let user : KTUser? = resource.typedContent()
            if let user = user{
                self.currentUser = user
                completion(user)
                self.log.info("Logged in user \(String(describing: user.userId)), \(user.email)")
                self.cache?.cache(user: user)
            }else{
                failure(nil)
            }
        }).onFailure({ (error) in
            failure(error)
        })
    }
}

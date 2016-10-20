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
        let path = self.baseURL().absoluteString + "auth"
        Just.post(
            path,
            data: ["email" : email, "password" : password]
        ) { r in
            if r.ok {
                let json = JSON(data: r.content!)
                let token = json["token"].string
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
                failure(r.error)
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

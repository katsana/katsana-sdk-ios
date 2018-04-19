//
//  KatsanaAPI+Subscribe.swift
//  KatsanaSDK
//
//  Created by Wan Lutfi on 09/04/2018.
//  Copyright © 2018 pixelated. All rights reserved.
//

import Siesta

extension KatsanaAPI{
    public func requestSubscriptions(completion: @escaping (_ subscriptions: [VehicleSubscription]) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "subscriptions"
        let resource = API.resource(path);
        let request = resource.loadIfNeeded()
        
        request?.onSuccess({(entity) in
            if let summaries : [VehicleSubscription] = resource.typedContent(){
                CacheManager.shared.cache(vehicleSubscription: summaries)
                NotificationCenter.default.post(name: KatsanaAPI.subscriptionRequestedNotification, object: summaries)
                completion(summaries)
            }else{
                failure(nil)
            }
        }).onFailure({ (error) in
            failure(error)
            self.log.error("Error getting vehicle subscriptions, \(error)")
        })
        
        if request == nil {
            if let summaries : [VehicleSubscription] = resource.typedContent(){
                completion(summaries)
            }else{
                failure(nil)
            }
        }
    }
    
    public func requestSubscription(id: String, completion: @escaping (_ subscription: VehicleSubscription) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "subscriptions/" + id
        let resource = API.resource(path);
        let request = resource.loadIfNeeded()
        
        request?.onSuccess({(entity) in
            if let subscription : VehicleSubscription = resource.typedContent(){
                completion(subscription)
            }else{
                failure(nil)
            }
        }).onFailure({ (error) in
            failure(error)
            self.log.error("Error getting vehicle subscription \(id), \(error)")
        })
    }
    
    public func requestPaySubscriptionURL(subscriptionId: String, completion: @escaping (_ url: String) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "subscriptions/" + subscriptionId + "/pay"
        let resource = API.resource(path);
        
        resource.request(.post).onSuccess({(entity) in
            let test = entity.content as? JSON
            if let url = test!["pay_url"].string{
                completion(url)
            }else{
                failure(nil)
            }
        }).onFailure({ (error) in
            failure(error)
            self.log.error("Error getting pay subscriptions url, \(error)")
        })
    }
    
    public func requestUpgradeSubscriptionURL(subscriptionId: String, planId: String, completion: @escaping (_ url: String) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "subscriptions/" + subscriptionId + "/upgrade"
        let resource = API.resource(path);
        
        let parameters = ["plan_id": planId] as [String : Any]
        resource.request(.post, json: NSDictionary(dictionary: parameters)).onSuccess({(entity) in
            let test = entity.content as? JSON
            if let url = test!["pay_url"].string{
                completion(url)
            }else{
                failure(nil)
            }
        }).onFailure({ (error) in
            failure(error)
            self.log.error("Error getting upgrade subscriptions url, \(error)")
        })
    }
    
    public func cachedVehicleSubscriptions() -> [VehicleSubscription]! {
        if let user = currentUser{
            return CacheManager.shared.vehicleSubscriptions(userId: user.userId)
        }
        return nil
    }
}

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
        let userId = currentUser?.userId ?? "0"
        
        
        request?.onSuccess({(entity) in
            if let summaries : [VehicleSubscription] = resource.typedContent(){
                self.cache?.cache(vehicleSubscription: summaries, userId: userId)
                NotificationCenter.default.post(name: KatsanaAPI.subscriptionRequestedNotification, object: summaries)
                completion(summaries)
            }else{
                failure(nil)
            }
        }).onFailure({ (error) in
            failure(error)
            self.log?.error("Error getting vehicle subscriptions, \(error)")
        })
        
        if request == nil {
            if let summaries : [VehicleSubscription] = resource.typedContent(){
                completion(summaries)
            }else{
                failure(nil)
            }
        }
    }
    
//    public func requestSubscription(id: String, completion: @escaping (_ subscription: VehicleSubscription) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
//        let path = "subscriptions/" + id
//        let resource = API.resource(path);
//        let request = resource.loadIfNeeded()
//
//        request?.onSuccess({(entity) in
//            if let subscription : VehicleSubscription = resource.typedContent(){
//                completion(subscription)
//            }else{
//                failure(nil)
//            }
//        }).onFailure({ (error) in
//            failure(error)
//            self.log?.error("Error getting vehicle subscription \(id), \(error)")
//        })
//    }
    
    public func requestPaySubscriptionURL(subscriptions: [VehicleSubscription], period:Int, completion: @escaping (_ url: String) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        
        var params = [String: Any]()
        var newIds = [Int]()
        for subscription in subscriptions{
            if let val = Int(subscription.subscriptionId){
                newIds.append(val)
            }
        }
        params["subscription"] = newIds
        params["period"] = period
        
        let path = "subscriptions/pay"
        let resource = API.resource(path);
        
        resource.request(.post, json: NSDictionary(dictionary: params)).onSuccess({(entity) in
            let test = entity.content as? JSON
            if let url = test!["transaction"]["meta"]["bill"]["url"].string{
                completion(url)
            }else{
                failure(nil)
            }
        }).onFailure({ (error) in
            failure(error)
            self.log?.error("Error getting pay subscriptions url, \(error)")
        })
    }
    
    public func notifySupportKatsanaForSubscription(subscriptions: [VehicleSubscription], completion: @escaping () -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        
        var params = [String: Any]()
        var newIds = [Int]()
        for subscription in subscriptions{
            if let val = Int(subscription.deviceId){
                newIds.append(val)
            }
        }
        params["device"] = newIds
        
        let path = "subscriptions/notify"
        let resource = API.resource(path);
        
        resource.request(.post, json: NSDictionary(dictionary: params)).onSuccess({(entity) in
//            let test = entity.content as? JSON
//            print(entity)
            completion()
        }).onFailure({ (error) in
            failure(error)
            self.log?.error("Error notify Customer Support to renew terminated subscriptions, \(error)")
        })
    }
    
//    public func requestUpgradeSubscriptionURL(subscriptionId: String, planId: String, completion: @escaping (_ url: String) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
//        let path = "subscriptions/" + subscriptionId + "/upgrade"
//        let resource = API.resource(path);
//
//        let parameters = ["plan_id": planId] as [String : Any]
//        resource.request(.post, json: NSDictionary(dictionary: parameters)).onSuccess({(entity) in
//            let test = entity.content as? JSON
//            if let url = test!["pay_url"].string{
//                completion(url)
//            }else{
//                failure(nil)
//            }
//        }).onFailure({ (error) in
//            failure(error)
//            self.log?.error("Error getting upgrade subscriptions url, \(error)")
//        })
//    }
    
    public func wipeSubscriptionResources(){
        API.wipeResources(matching: "subscriptions")
    }
    
    public func cachedVehicleSubscriptions() -> [VehicleSubscription]! {
        if let user = currentUser{
            return self.cache?.vehicleSubscriptions(userId: user.userId)
        }
        return nil
    }
}

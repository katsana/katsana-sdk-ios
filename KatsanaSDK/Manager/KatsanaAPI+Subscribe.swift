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
}

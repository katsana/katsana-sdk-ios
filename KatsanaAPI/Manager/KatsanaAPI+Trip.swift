//
//  KatsanaAPI+Trip.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit

extension KatsanaAPI {
    
    public func requestTripSummaryToday(vehicleId: String, completion: @escaping (KMTravelHistory?, Error?) -> Void) -> Void {
        let path = "vehicles/" + vehicleId + "summaries/today"
        let resource = API.resource(path);
        resource.loadIfNeeded()?.onSuccess({(entity) in
            let summary : KMTravelHistory? = resource.typedContent()
            completion(summary, nil)
            }).onFailure({ (error) in
                completion(nil, error)
            })
    }
    
    //!Request trip summary between dates. Only load trip count without actual trip details to minimize data usage,
    public func requestTripSummary(vehicleId: String, fromDate: Date!, toDate: Date, completion: @escaping (KMTravelHistory?, Error?) -> Void) -> Void {
        let path = "vehicles/" + vehicleId + "summaries/today"
        let resource = API.resource(path);
        resource.loadIfNeeded()?.onSuccess({(entity) in
            let summary : KMTravelHistory? = resource.typedContent()
            completion(summary, nil)
        }).onFailure({ (error) in
            completion(nil, error)
        })
    }
    
    //!Request trip history will download histories for that particular date
    public func requestTripHistory(vehicleId: String, date: Date, completion: @escaping (KMTravelHistory?, Error?) -> Void) -> Void {
        let path = "vehicles/" + vehicleId + "summaries/today"
        let resource = API.resource(path);
        resource.loadIfNeeded()?.onSuccess({(entity) in
            let summary : KMTravelHistory? = resource.typedContent()
            completion(summary, nil)
        }).onFailure({ (error) in
            completion(nil, error)
        })
    }

}



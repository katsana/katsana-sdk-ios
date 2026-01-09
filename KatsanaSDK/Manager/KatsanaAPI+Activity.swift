//
//  KatsanaAPI+Activity.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 30/10/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import Siesta

extension KatsanaAPI{
    private static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HH:mm:ss"
        
        
//        if (internalJsonDateGMTFormatter == nil) {
//            internalJsonDateGMTFormatter = DateFormatter()
//            internalJsonDateGMTFormatter!.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            internalJsonDateGMTFormatter?.timeZone = Foundation.TimeZone(secondsFromGMT: 0)!
//            internalJsonDateGMTFormatter!.locale = Locale(identifier: "en_US_POSIX")
//            //            2013-11-18 03:31:02
//        }
//        internalJsonDateGMTFormatter?.timeZone = Foundation.TimeZone(secondsFromGMT: Int(gmt * 60*60))!
        return formatter
    }
    
    public func markActivityRead(readActivityDate: Date, completion: @escaping () -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        
        let dateText = KatsanaAPI.dateFormatter().string(from: readActivityDate)
        print(dateText)
        let path = "notifications/read/\(dateText)"
        let resource = API.resource(path)
        let request = resource.loadIfNeeded()
        
        func handleResource() -> Void {
            completion()
        }
        
        request?.onSuccess({(entity) in
            handleResource()
        }).onFailure({ (error) in
            failure(error)
        })
        if request == nil {
            handleResource()
        }
    }
    
    public func requestVehicleActivities(page: Int, countPerPage: Int = 100, afterId: String? = nil, completion: @escaping (_ activities:[VehicleActivity]) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        
        let path = "notifications"
        var resource = API.resource(path).withParam("page", "\(page)").withParam("per_page", "\(countPerPage)")
        if let afterId{
            resource = resource.withParam("after", "\(afterId)")
        }
        let request = resource.loadIfNeeded()
        
        func handleResource() -> Void {
            if let activities : [VehicleActivity] = resource.typedContent(){
                completion(activities)
            }else{
                failure(nil)
            }
        }
        
        request?.onSuccess({(entity) in
            handleResource()
        }).onFailure({ (error) in
            failure(error)
            self.handleError(error: error, details: "Error getting vehicle activities")
        })
        if request == nil {
            handleResource()
        }
    }
}

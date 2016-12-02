//
//  KatsanaAPI+Share.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutf Wan Md Hatta on 29/11/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation


extension KatsanaAPI {
    
    
    /// Request live share link. Duration is in minute format
    ///
    /// - Returns: Return live share
    public func requestLiveShareLink(vehicleId: String, duration: CGFloat, completion: @escaping (_ liveShare: LiveShare?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {

        let path = "vehicles/" + vehicleId + "/sharing"
        let durationText = String(format: "%.0fi", duration)
        
        let fullPath = self.baseURL().absoluteString + path
        Just.post(
            fullPath,
            json: ["duration" : durationText],
            headers: ["Authorization" : ("Bearer " + self.authToken)]
        ) { r in
            if r.ok {
                let json = JSON(data: r.content!)
                let liveShare = ObjectJSONTransformer.LiveShareObject(json: json)
                DispatchQueue.main.sync {
                    completion(liveShare)
                }
                
            }else{
                DispatchQueue.main.sync {
                    self.log.error("Error requesting live share link \(vehicleId), \(r.error)")
                    failure( r.error)
                }
                
            }
        }
    }
}

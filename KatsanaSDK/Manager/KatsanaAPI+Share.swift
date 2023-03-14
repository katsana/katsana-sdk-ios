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
            headers: ["Authorization" : ("Bearer " + self.authToken)], asyncCompletionHandler:  { r in
                if r.ok, let json = try? JSON(data: r.content!) {
                    
                    let liveShare = ObjectJSONTransformer.LiveShareObject(json: json)
                    liveShare.duration = Int(duration)
                    DispatchQueue.main.sync{completion(liveShare)}
                    
                }else{
                    var text = r.reason
                    if let content = r.content{
                        text = String(data: content, encoding: .utf8)!
                    }
                    self.log?.error("Error requesting live share link \(vehicleId), error: \(text)")
                    DispatchQueue.main.sync{failure(r.APIError())}
                }
            })
    }
    
    public func requestLiveShareLinksInfo(vehicleId: String, completion: @escaping (_ liveShares: [LiveShare]) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        
        let path = "vehicles/" + vehicleId + "/sharing"
        let fullPath = self.baseURL().absoluteString + path
        Just.get(
            fullPath,
            headers: ["Authorization" : ("Bearer " + self.authToken)], asyncCompletionHandler:  { r in
                if r.ok, let json = try? JSON(data: r.content!) {
                    
                    let array = json.arrayValue
                    var liveShares = [LiveShare]()
                    for aJson in array{
                        let liveShare = ObjectJSONTransformer.LiveShareObject(json: aJson)
                        liveShares.append(liveShare)
                    }
                    DispatchQueue.main.sync{completion(liveShares)}
                    
                }else{
                    var text = r.reason
                    if let content = r.content{
                        text = String(data: content, encoding: .utf8)!
                    }
                    self.log?.error("Error requesting live share link info \(vehicleId), \(text)")
                    failure(r.APIError())
                    
                }
            })
    }
    
    public func deleteLiveShareLink(vehicleId: String, liveShareId: String, completion: @escaping (_ success: Bool) -> Void) -> Void {
        let path = "vehicles/" + vehicleId + "/sharing/" + liveShareId
        let fullPath = self.baseURL().absoluteString + path
        Just.delete(
            fullPath,
            headers: ["Authorization" : ("Bearer " + self.authToken)], asyncCompletionHandler:  { r in
                if r.ok {
                    DispatchQueue.main.sync{completion(true)}
                }else{
                    var text = r.reason
                    if let content = r.content{
                        text = String(data: content, encoding: .utf8)!
                    }
                    
                    self.log?.error("Error deleting live share link \(vehicleId), \(text)")
                    DispatchQueue.main.sync{completion(false)}
                }
            })
    }
}

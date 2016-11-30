//
//  KatsanaAPI+Share.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutf Wan Md Hatta on 29/11/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation


extension KatsanaAPI {
    
    public func requestLiveShareLink(vehicleId: String, duration: CGFloat, completion: @escaping (_ vehicle: KMVehicle?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {

        let path = "vehicles/" + vehicleId + "/sharing"
//        let resource = API.resource(path);
//        resource.request(.post, json: ["duration" : "23H"]).onSuccess { (entity) in
//            let data = resource.jsonDict
//            print(data)
//        }.onFailure { (error) in
//            print(error.localizedDescription)
//            print("sdfsdf")
//        }
        
        let fullPath = self.baseURL().absoluteString + path
        Just.post(
            fullPath,
//            data: ["token": self.authToken],
            json: ["duration" : "23H"],
            headers: ["Authorization" : ("Bearer " + self.authToken)]
//            files: ["file": .data("avatar.png", data, "image/jpeg")]
        ) { r in
            //            let strData = NSString(data: r.content!, encoding: String.Encoding.utf8.rawValue)
            if r.ok {
                DispatchQueue.main.sync {
                    completion( nil)
                }
                
            }else{
                DispatchQueue.main.sync {
                    failure( r.error)
                }
                
            }
        }
    }
}

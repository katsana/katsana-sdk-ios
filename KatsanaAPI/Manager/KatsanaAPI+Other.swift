//
//  KatsanaAPI+Other.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//
import SwiftyJSON

extension KatsanaAPI{
    
    func uploadImage(image : UIImage, path : String, completion : @escaping (Bool, Error?) -> Void) -> Void {
        //        let path = self.baseURL().absoluteString + "profile/avatar"
        let data = UIImageJPEGRepresentation(image, 0.9)! //Change to data
        Just.post(
            path,
            data: ["token": self.authToken],
            files: ["file": .data("avatar.png", data, "image/jpeg")]
        ) { r in
//            let strData = NSString(data: r.content!, encoding: String.Encoding.utf8.rawValue)
            if r.ok {
                completion(true, nil)
            }else{
                completion(false, r.error)
            }
        }
    }
    
    
    /// Request custom response from other application using current KatsanaAPI endpoint.
    ///
    /// - parameter path:       path to append to current endpoint
    /// - parameter completion: completion
    public func requestResponse(for path: String, completion: @escaping (_ response: Dictionary<String, Any>?, _ error: Error?) -> Void) -> Void {
        
        
        let fullPath = self.baseURL().absoluteString + path
        Just.get(
            fullPath,
            data: ["token": self.authToken]
        ) { r in
            let json = JSON(data: r.content!)
            let dicto = json.dictionaryObject
            completion(dicto, r.error)
        }
    }
    
    public func requestResponseUsing(fullPath: String, defaultHeaders: Dictionary<String, String> = [:], parameters:Dictionary<String, String> = [:], completion: @escaping (_ response: Dictionary<String, Any>?, _ error: Error?) -> Void) -> Void {
        Just.get(
            fullPath,
            params:  parameters,
            headers: defaultHeaders
        ) { r in
            let json = JSON(data: r.content!)
            let dicto = json.dictionaryObject
            completion(dicto, r.error)
        }
    }
}

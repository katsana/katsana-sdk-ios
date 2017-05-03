//
//  KatsanaAPI+Other.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

extension KatsanaAPI{
    
    func uploadImage(image : KMImage, path : String, completion : @escaping (Bool, Error?) -> Void) -> Void {
        //        let path = self.baseURL().absoluteString + "profile/avatar"
        #if os(iOS)
            let data = UIImageJPEGRepresentation(image, 0.9)! //Change to data
        #elseif os(OSX)
            let data = image.tiffRepresentation(using: .JPEG, factor: 0.9)! //Change to data
        #endif
        
        Just.post(
            path,
            data: ["token": self.authToken],
            files: ["file": .data("avatar.png", data, "image/jpeg")]
        ) { r in
//            let strData = NSString(data: r.content!, encoding: String.Encoding.utf8.rawValue)
            if r.ok {
                DispatchQueue.main.sync {
                    completion(true, nil)
                }
                
            }else{
                DispatchQueue.main.sync {
                    completion(false, r.APIError())
                }
                
            }
        }
    }
    
    
    /// Request custom response from other application using current KatsanaAPI endpoint.
    ///
    /// - parameter path:       path to append to current endpoint
    /// - parameter completion: completion
    public func requestResponse(for path: String, completion: @escaping (_ response: Dictionary<String, Any>?, _ error: Error?) -> Void) -> Void {
        
        let resource = API.resource(path);
        let request = resource.loadIfNeeded()
        request?.onSuccess({(entity) in
            let json = entity.content as? JSON
            let dicto = json?.dictionaryObject
            completion(dicto, nil)
        }).onFailure({ (error) in
            completion(nil, error)
            self.log.error("Error request custom response for path \(path), \(error)")
        })
        
        if request == nil {
            let json = resource.latestData?.content as? JSON
            let dicto = json?.dictionaryObject
            completion(dicto, nil)
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
            DispatchQueue.main.sync {
                completion(dicto, r.APIError())
            }
        }
    }
}

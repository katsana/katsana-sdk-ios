//
//  ImageRequest.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit
import Siesta


/// Class to request image from server. It is not included with KatsanaAPI because image request need a max async connection because the data is bigger tha json
public class ImageRequest: NSObject {
    public static let shared = ImageRequest()
    
    public var API : Service!
    
    override init() {
        super.init()
        configure()
    }

    func configure() {
        let sessionConfig = URLSessionConfiguration()
        sessionConfig.httpMaximumConnectionsPerHost = 5
        API = Service(networking:sessionConfig)
        API.configure("**") {
            $0.expirationTime = 15
        }
    }
    
    public func requestImage(path : String, completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) -> Void {
        let url = NSURL(string: path)
        let image = KMCacheManager.sharedInstance().image(forIdentifier: url?.lastPathComponent)
        if image != nil {
            completion(image, nil)
            return
        }
        
        let resource = API.resource(path);
        resource.loadIfNeeded()?.onSuccess({(entity) in
            let image : UIImage? = resource.typedContent()
            if image != nil{
                KMCacheManager.sharedInstance().cacheData(image, identifier: url?.lastPathComponent)
                completion (image, nil)
            }else{
                completion (nil, nil)
            }
        }).onFailure({ (error) in
            completion(nil, error)
        })
    }
    
}

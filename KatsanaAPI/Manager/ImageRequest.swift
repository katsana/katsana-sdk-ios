//
//  ImageRequest.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit
import Siesta
import SwiftyJSON

/// Class to request image from server. It is not included with KatsanaAPI because image request need a max async connection because the data is bigger tha json
public class ImageRequest: NSObject {
    public static let shared = ImageRequest()
    
    public var API : Service!
    
    override init() {
        super.init()
        configure()
    }

    func configure() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpMaximumConnectionsPerHost = 5
        API = Service(networking:sessionConfig)
        API.configure("**") {
            $0.expirationTime = 15
        }
    }
    
    public func requestImage(path : String, completion: @escaping (_ image: UIImage?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let url = NSURL(string: path)
        let image = KMCacheManager.sharedInstance().image(forIdentifier: url?.lastPathComponent)
        if image != nil {
            completion(image)
            return
        }
        
        Just.get(
            path
        ) { r in
            if r.ok {
                let content = r.content
                let image = UIImage(data: content!)
                KMCacheManager.sharedInstance().cacheData(image, identifier: url?.lastPathComponent)
                DispatchQueue.main.sync{completion(image)}
            }else{
                DispatchQueue.main.sync{failure(r.error)}
            }
        }
    }
    
}

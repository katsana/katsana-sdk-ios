//
//  ImageRequest.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

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
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpMaximumConnectionsPerHost = 5
        API = Service(networking:sessionConfig)
        API.configure("**") {
            $0.expirationTime = 15
        }
    }
    
    public func requestImage(path : String, completion: @escaping (_ image: KMImage?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let url = NSURL(string: path)
        if let lastComponent = url?.lastPathComponent, let image = CacheManager.shared.image(for: lastComponent){
            completion(image)
            return
        }
        
        Just.get(
            path
        ) { r in
            if r.ok {
                let content = r.content
                if let image = KMImage(data: content!), let lastComponent = url?.lastPathComponent{
                    CacheManager.shared.cache(image: image, identifier: lastComponent)
                    DispatchQueue.main.sync{completion(image)}
                }else{
                    DispatchQueue.main.sync{failure(r.error)}
                }
            }else{
                DispatchQueue.main.sync{failure(r.APIError())}
            }
        }
    }
    
}

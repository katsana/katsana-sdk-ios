//
//  KatsanaAPI+Other.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

extension KatsanaAPI{
    
    func uploadImage(image : UIImage, path : String, completion : @escaping (Bool, Error?) -> Void) -> Void {
        //        let path = self.baseURL().absoluteString + "profile/avatar"
        let data = UIImageJPEGRepresentation(image, 0.9)! //Change to data
        Just.post(
            path,
            data: ["token": self.authToken],
            files: ["file": .data("avatar.png", data, "image/jpeg")]
        ) { r in
            let strData = NSString(data: r.content!, encoding: String.Encoding.utf8.rawValue)
            if r.ok {
                completion(true, nil)
            }else{
                completion(false, r.error)
            }
        }
    }
}

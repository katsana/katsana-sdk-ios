//
//  KatsanaAPI+Profile.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//
//import Alamofire

extension KatsanaAPI {
    public func saveCurrentUserProfile(completion: @escaping (_ user: KMUser?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let resource = self.API.resource("profile")
        
        let json = self.currentUser.jsonPatchDictionary()
        resource.request(.patch, json: json!).onSuccess { (_) in
            completion(self.currentUser)
        }.onFailure { (error) in
            failure(error)
        }
    }
    
   public func saveCurrentUserProfileImage(image : UIImage?, completion: @escaping (_ user: KMUser?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        var finalImage = image! as UIImage
        if image == nil {
            finalImage = UIImage(color: UIColor.white)!
        }
        finalImage = finalImage.fixOrientation()
        
        var maxSize : CGFloat = 600
        let scale = UIScreen.main.scale
        if scale > 1 {maxSize /= scale}
        
        if ((finalImage.size.width) > maxSize || (finalImage.size.height) > maxSize) {
            let factor = finalImage.size.width/finalImage.size.height;
            if (factor > 1) {
                finalImage = finalImage.scale(to: CGSize(width: maxSize, height: maxSize / factor))
            }else{
                finalImage = finalImage.scale(to: CGSize(width: maxSize * factor, height: maxSize))
            }
        }
        
        //Just put it although still not saved
        self.currentUser.avatarImage = finalImage
        let path = self.baseURL().absoluteString + "profile/avatar"
        uploadImage(image: finalImage, path: path) { (success, error) in
            if success{
                completion(self.currentUser)
            }else{
                failure(error)
            }
        }
    }
}




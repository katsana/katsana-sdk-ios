//
//  KatsanaAPI+Profile.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Siesta
import UIKit

#if os(iOS)
    public typealias KMColor = UIColor
    public typealias KMImage = UIImage
#elseif os(OSX)
    public typealias KMColor = NSColor
    public typealias KMImage = NSImage
#endif


extension KatsanaAPI {
    public func saveCurrentUserProfile(data: [String: Any], completion: @escaping (_ user: KTUser) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let resource = self.API.resource("profile")
        let user = currentUser!
        
//        var newData = data
//        for (key, value) in data {
//            if let value = value as? String, value == ""{
//                //Do nothing, should not add if have empty value
//            }
//        }
        
//        let json = self.currentUser.jsonPatch()
        resource.request(.patch, json: data).onSuccess { (_) in
            for (key, value) in data{
                if let value = value as? String{
                    if key == "fullname"{
                        user.fullname = value
                    }
                    else if key == "phone_mobile"{
                        user.phoneMobile = value
                    }
                    else if key == "birthday"{
                        user.birthdayText = value
                    }
                    else if key == "gender"{
                        user.genderText = value.lowercased()
                    }
                    else if key == "address"{
                        user.address = value
                    }
                    else if key == "country"{
                        user.country = value
                    }
                    else if key == "state"{
                        user.state = value
                    }
                    else if key == "postcode"{
                        user.postcode = value
                    }
                }
            }
            completion(user)
            NotificationCenter.default.post(name: KatsanaAPI.profileUpdatedNotification, object: nil)
        }.onFailure { (error) in
            failure(error)
            self.log.error("Error save user profile \(error)")
        }
    }
    
   public func saveCurrentUserProfileImage(image : KMImage?, completion: @escaping (_ user: KTUser?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
    
        var finalImage : KMImage!
        if image == nil {
            finalImage = KMImage(color: KMColor.white)!
        }else{
            finalImage = image
        }
    
        finalImage = finalImage.fixOrientation()
        
        var maxSize : CGFloat = 600
    #if os(iOS)
        let scale = UIScreen.main.scale
    #elseif os(OSX)
        let scale = (NSScreen.main()?.backingScaleFactor)! as CGFloat
    #endif
    
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
        currentUser.updateImage(finalImage)
        let path = self.baseURL().absoluteString + "profile/avatar"
        uploadImage(image: finalImage, path: path) { (success, error) in
            if success{
                completion(self.currentUser)
            }else{
                failure(error)
                self.log.error("Error save user profile image \(String(describing: error))")
            }
        }
    }
}




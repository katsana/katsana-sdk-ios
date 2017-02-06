//
//  KatsanaAPI+Profile.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

#if os(iOS)
    public typealias KMColor = UIColor
    public typealias KMImage = UIImage
#elseif os(OSX)
    public typealias KMColor = NSColor
    public typealias KMImage = NSImage
#endif


extension KatsanaAPI {
    public func saveCurrentUserProfile(completion: @escaping (_ user: User?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let resource = self.API.resource("profile")
        let json = self.currentUser.jsonPatch()
        resource.request(.patch, json: json).onSuccess { (_) in
            completion(self.currentUser)
            }.onFailure { (error) in
                failure(error)
                self.log.error("Error save user profile \(error)")
        }
    }
    
   public func saveCurrentUserProfileImage(image : KMImage?, completion: @escaping (_ user: User?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
    
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
                self.log.error("Error save user profile image \(error)")
            }
        }
    }
}



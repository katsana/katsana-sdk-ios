//
//  KatsanaAPI+Profile.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//
//import Alamofire

extension KatsanaAPI {
    func saveCurrentUserProfile(completion: @escaping (KMUser?, Error?) -> Void) -> Void {
        let resource = self.API.resource("profile")
        
        let json = self.currentUser.jsonPatchDictionary()
        resource.request(.patch, json: json!).onSuccess { (_) in
            print("success")
        }.onFailure { (error) in
            completion(nil, error)
        }
    }
    
    func saveCurrentUserProfileImage(image : UIImage?, completion: @escaping (KMUser?, Error?) -> Void) -> Void {
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
                completion(self.currentUser, nil)
            }else{
                completion(nil, nil)
            }
        }
    }

    func uploadImage(image : UIImage, path : String, completion : (Bool, Error?) -> Void) -> Void {
//        let path = self.baseURL().absoluteString + "profile/avatar"
        let url = URL(string: path)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let imageData = UIImageJPEGRepresentation(image, 0.9)
        let base64String = imageData?.base64EncodedString()
        
        let params = ["image":[ "content_type": "image/jpeg", "filename":"avatar.png", "file_data": base64String]]
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        }
        task.resume() // this is needed to start the task
        
//        var task = URLSession.shared.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
//            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            var err: NSError?
//            
//            // process the response
//        })
        
        task.resume() // this is needed to start the task
        
    }
    
}




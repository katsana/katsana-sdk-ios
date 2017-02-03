//
//  User.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 27/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import UIKit

public class User: NSObject {
    public var email: String
    public var userId: String!
    public var address: String!
    public var phoneHome: String!
    public var phoneMobile: String!
    public var identification: String!
    public var fullname: String!
    public var status: Int = 0
    
    public var emergencyFullName: String!
    public var emergencyPhoneHome: String!
    public var emergencyPhoneMobile: String!
    public var imageURL: String!
    public var thumbImageURL: String!
    
    public var createdAt: Date!
    public var updatedAt: Date!
    
    private(set) public var image : UIImage!
    private(set) public var thumbImage : UIImage!
    
    private var imageBlocks = [(image: UIImage) -> Void]()
    private var thumbImageBlocks = [(image: UIImage) -> Void]()
    private var isLoadingImage = false
    private var isLoadingThumbImage = false
    
    ///Implemented to satisfy FastCoder and set default value
    override init() {
        email = ""
    }
    
    init(email: String) {
        self.email = email
    }
    
    override public class func fastCodingKeys() -> [Any]? {
        return ["userId", "email", "address", "phoneHome", "phoneMobile", "fullname", "status", "createdAt", "imageURL", "thumbImageURL"]
    }
    
    public func jsonPatch() -> [String: Any] {
        var dicto = [String: Any]()
        if let address = address{
            dicto["address"] = address
        }
        if let phoneHome = phoneHome{
            dicto["phone_home"] = phoneHome
        }
        if let phoneMobile = phoneMobile{
            dicto["phone_mobile"] = phoneMobile
        }
        if let fullname = fullname{
            dicto["fullname"] = fullname
        }
        if let emergencyFullName = emergencyFullName{
            dicto["meta.emergency.fullname"] = emergencyFullName
        }
        if let emergencyPhoneHome = emergencyPhoneHome{
            dicto["meta.emergency.phone.home"] = emergencyPhoneHome
        }
        if let emergencyPhoneMobile = emergencyPhoneMobile{
            dicto["meta.emergency.phone.mobile"] = emergencyPhoneMobile
        }
        return dicto
    }
    
    // MARK: Image
    
    public func updateImage(_ image: KMImage) {
        self.image = image
    }
    
    public func image(completion: @escaping (_ image: UIImage) -> Void){
        guard imageURL != nil else {
            return
        }
        
        if let image = image {
            completion(image)
        }else if let image = CacheManager.shared.image(for: (NSURL(string: imageURL)?.lastPathComponent)!){
            completion(image)
        }else{
            if isLoadingImage {
                imageBlocks.append(completion)
            }else{
                isLoadingImage = true
                ImageRequest.shared.requestImage(path: imageURL, completion: { (image) in
                    self.image = image
                    self.isLoadingImage = false
                    for block in self.imageBlocks{
                        block(image!)
                    }
                    completion(image!)
                }, failure: { (error) in
                    KatsanaAPI.shared.log.error("Error requesting user image \(self.email)")
                    self.isLoadingImage = false
                })
            }
        }
    }
    
    public func thumbImage(completion: @escaping (_ image: UIImage) -> Void){
        guard thumbImageURL != nil else {
            return
        }
        
        if let image = thumbImage {
            completion(image)
        }else if let image = CacheManager.shared.image(for: (NSURL(string: thumbImageURL)?.lastPathComponent)!){
            completion(image)
        }else{
            if isLoadingThumbImage {
                thumbImageBlocks.append(completion)
            }else{
                isLoadingThumbImage = true
                ImageRequest.shared.requestImage(path: thumbImageURL, completion: { (image) in
                    self.thumbImage = image
                    self.isLoadingThumbImage = false
                    for block in self.thumbImageBlocks{
                        block(image!)
                    }
                    completion(image!)
                }, failure: { (error) in
                    KatsanaAPI.shared.log.error("Error requesting user thumb image \(self.email)")
                    self.isLoadingThumbImage = false
                })
            }
        }
    }
    
    // MARK: helper
    
    func isPhoneNumber(_ text: String) -> Bool {
        if text.characters.count < 3 {
            return false
        }
        let set = CharacterSet(charactersIn: "+0123456789 ")
        if text.trimmingCharacters(in: set) == ""{
            return true
        }
        return false
    }
}


//
//  DriveMarkSDK.User.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 27/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

open class User: NSObject {
    open var email: String
    open var userId: String!
    open var address: String!
    open var phoneHome: String!
    open var phoneMobile: String!
    open var identification: String!
    open var fullname: String!
    open var status: Int = 0
    
    open var emergencyFullName: String!
    open var emergencyPhoneHome: String!
    open var emergencyPhoneMobile: String!
    open var imageURL: String!
    open var thumbImageURL: String!
    
    open var createdAt: Date!
    open var updatedAt: Date!
    
    private(set) open var image : KMImage!
    private(set) open var thumbImage : KMImage!
    
    private var imageBlocks = [(image: KMImage) -> Void]()
    private var thumbImageBlocks = [(image: KMImage) -> Void]()
    private var isLoadingImage = false
    private var isLoadingThumbImage = false
    
    ///Implemented to satisfy FastCoder and set default value
    override init() {
        email = ""
    }
    
    init(email: String) {
        self.email = email
    }
    
    override open class func fastCodingKeys() -> [Any]? {
        return ["userId", "email", "address", "phoneHome", "phoneMobile", "fullname", "status", "createdAt", "imageURL", "thumbImageURL"]
    }
    
    open func jsonPatch() -> [String: Any] {
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
    
    open func updateImage(_ image: KMImage) {
        self.image = image
    }
    
    open func image(completion: @escaping (_ image: KMImage) -> Void){
        guard imageURL != nil else {
            return
        }
        
        if let image = image {
            completion(image)
        }else if let path = NSURL(string: imageURL)?.lastPathComponent, let image = CacheManager.shared.image(for: path){
            self.image = image
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
    
    open func thumbImage(completion: @escaping (_ image: KMImage) -> Void){
        guard thumbImageURL != nil else {
            return
        }
        
        if let image = thumbImage {
            completion(image)
        }else if let path = NSURL(string: thumbImageURL)?.lastPathComponent, let image = CacheManager.shared.image(for: path){
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


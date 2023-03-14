//
//  DriveMarkSDK.User.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 27/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//
import Foundation

public enum Gender : String, Codable{
    case unknown
    case male
    case female
}

public class KTUser: Codable {
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    enum CodingKeys: CodingKey {
        case email
        case userId
        case address
        case phoneHome
        case phoneMobile
        case identification
        case fullname
        case status
        case emergencyFullName
        case emergencyPhoneHome
        case emergencyPhoneMobile
        case imageURL
        case thumbImageURL
        case phoneMobileCountryCode
        case postcode
        case state
        case country
        case gender
        case planId
        case planName
        case planDescription
        case fleets
        case birthday
        case createdAt
        case updatedAt
    }
    
    public let email: String
    public let userId: String
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
    
    public var phoneMobileCountryCode: String!
    public var postcode: String!
    public var state: String!
    public var country: String!
    public var gender: Gender = .unknown
    
    public var planId: Int!
    public var planName: String!
    public var planDescription: String!
    
    public var fleets = [Fleet]()
    
    public var genderText: String!{
        get{
            if gender == .unknown{
                return nil
            }
            return gender.rawValue.capitalized
        }
        set{
            if let newValue = newValue{
                if newValue.lowercased() == "male" {
                    gender = .male
                }
                else if newValue.lowercased() == "female" {
                    gender = .female
                }
            }else{
                gender = .unknown
            }
        }
    }
    
    public var birthday: Date!{
        didSet{
            if let birthday = birthday {
                let dateStr = KTUser.dateFormatter.string(from: birthday)
                if let birthdayText = birthdayText, dateStr == birthdayText{
                    
                }else{
                    birthdayText = dateStr
                }
            }else{
                birthdayText = ""
            }
            
        }
    }
    public var birthdayText: String!{
        didSet{
            if let birthdayText = birthdayText {
                let date = KTUser.dateFormatter.date(from: birthdayText)
                if let birthday = birthday, date == birthday {
                    //Do nothing
                }else if date != nil{
                    birthday = date
                }
            }else{
                birthday = nil
            }
            
        }
    }
    
    public var createdAt: Date!
    public var updatedAt: Date!
    
    private(set) public var image : KMImage!
    private(set) public var thumbImage : KMImage!
    
    private var imageBlocks = [(image: KMImage) -> Void]()
    private var thumbImageBlocks = [(image: KMImage) -> Void]()
    private var isLoadingImage = false
    private var isLoadingThumbImage = false
    
    
    public init(userID:String, email: String) {
        self.userId = userID
        self.email = email
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
    
    public func image(completion: @escaping (_ image: KMImage) -> Void){
        guard imageURL != nil else {
            return
        }
        
        if let image = image {
            completion(image)
        }else if let path = NSURL(string: imageURL)?.lastPathComponent, let image = KTCacheManager.shared.image(for: path){
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
                    KatsanaAPI.shared.log?.error("Error requesting user image \(self.email)")
                    self.isLoadingImage = false
                })
            }
        }
    }
    
    public func thumbImage(completion: @escaping (_ image: KMImage) -> Void){
        guard thumbImageURL != nil else {
            return
        }
        
        if let image = thumbImage {
            completion(image)
        }else if let path = NSURL(string: thumbImageURL)?.lastPathComponent, let image = KTCacheManager.shared.image(for: path){
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
                    KatsanaAPI.shared.log?.error("Error requesting user thumb image \(self.email)")
                    self.isLoadingThumbImage = false
                })
            }
        }
    }
    
    // MARK: helper
    
    public func fleet(id: Int) -> Fleet!{
        for fleet in fleets{
            if fleet.fleetId == id{
                return fleet
            }
        }
        return nil
    }
    
    
    
    public func profileProgress() -> CGFloat {
        var progressCount :CGFloat = 0
        let totalCount:CGFloat = 8 - 1
        
        if let fullname = fullname, fullname.count > 0 {
            progressCount += 1
        }
        if let phoneNumber = phoneMobile, phoneNumber.count > 0 {
            progressCount += 1
        }
//        if (birthday) != nil{
//            progressCount += 1
//        }
        if let address = address, address.count > 0{
            progressCount += 1
        }
        if let country = country, country.count > 0{
            progressCount += 1
        }
        if let postcode = postcode, postcode.count > 0{
            progressCount += 1
        }
        if gender != .unknown{
            progressCount += 1
        }
        if let imageURL = imageURL,  imageURL.count > 0{
            progressCount += 1
        }else if image != nil{
            progressCount += 1
        }
        let progress = progressCount/totalCount
        return progress
    }
    
    func isPhoneNumber(_ text: String) -> Bool {
        if text.count < 3 {
            return false
        }
        let set = CharacterSet(charactersIn: "+0123456789 ")
        if text.trimmingCharacters(in: set) == ""{
            return true
        }
        return false
    }
    
    public func date(from string: String) -> Date! {
        return KTUser.dateFormatter.date(from: string)
    }
}


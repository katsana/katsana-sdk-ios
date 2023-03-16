//
//  DriveMarkSDK.User.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 27/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//
import Foundation

public enum Gender : String, Codable, Equatable{
    case male
    case female
}

public struct UserPlan: Codable, Equatable{
    public let id: Int?
    public let name: String
    public let description: String?
}

public struct Company: Codable, Equatable{
    public let companyName: String
    public let personInChargeName: String?
    public let personInChargeNumber: String?
}

public class KTUser: Codable {
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    public let email: String
    public let userId: String
    
    public let createdAt: Date
    public var updatedAt: Date
    public let imageURL: String?

    public var fullname: String?
    public var gender: Gender?
    public var address: String?
    public var phoneHome: String?
    public var phoneMobile: String?
    public var identification: String?
    public var phoneMobileCountryCode: String?
    public var postcode: String?
    public var state: String?
    public var country: String?
    public var birthday: Date?
    
    public let plan: UserPlan?
    public let company: Company?
    public let fleets: [Fleet]
    
    
    public init(userId:String, email: String, imageURL: String?, plan: UserPlan?, company: Company?, fleets: [Fleet] = [], createdAt: Date, updatedAt: Date! = nil ) {
        self.userId = userId
        self.email = email
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
        self.imageURL = imageURL
        self.plan = plan
        self.fleets = fleets
        self.company = company
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
        return dicto
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
        if gender != nil{
            progressCount += 1
        }
        if let imageURL, imageURL.count > 0{
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
    
    // MARK: Need remove
    
    open func updateImage(_ image: KMImage) {
//        self.image = image
    }
}

extension KTUser: Equatable{
    public static func == (lhs: KTUser, rhs: KTUser) -> Bool {
        if lhs.email == rhs.email, lhs.userId == rhs.userId, lhs.fleets == rhs.fleets, lhs.plan == rhs.plan, lhs.createdAt == rhs.createdAt{
            return true
        }
        return false
    }
    
    
}

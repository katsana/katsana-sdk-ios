//
//  UserMapper.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class UserMapper{
//    private struct Root: Decodable {
//        let id: Int
//        let email: String
//
//        var user: KTUser {
//            KTUser(userID: "\(id)", email: email)
//        }
//    }
    
    private static var OK_200: Int { return 200 }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> KTUser {
        guard response.isOK else{
            throw Error.invalidData
        }
        
        do{
            let json = try JSON(data: data)
            
            
//            objectInitializationHandler?(json, KTUser.self)
            return mapJSON(json)
        }
        catch{
            throw Error.invalidData
        }
    }
    
    public static func mapJSON(_ json: JSON) -> KTUser {
        let email = json["email"].stringValue
        let userId = json["id"].stringValue
        let imageURL = json["avatar"]["url"].string
        let createdAt = json["created_at"].date(gmt: 0)
        let updatedAt = json["updated_at"].date(gmt: 0)
        
        let planId = json["plan"]["id"].int
        let planName = json["plan"]["name"].string
        let planDescription = json["plan"]["description"].string
        
        var theFleets = [Fleet]()
        if let fleets = json["fleets"].array{
            for fleet in fleets{
                let fleetId = fleet["id"].intValue
                let name = fleet["name"].stringValue
                let deviceCount = fleet["devices"].intValue
                let aFleet = Fleet(fleetId: fleetId, name: name, deviceCount: deviceCount)
                theFleets.append(aFleet)
            }
        }
        
        var plan: UserPlan?
        if let planName{
            plan = UserPlan(id: planId, name: planName, description: planDescription)
        }
        
        let user = KTUser(userId: userId, email: email, imageURL: imageURL, plan: plan, fleets: theFleets, createdAt: createdAt ?? Date(), updatedAt: updatedAt)
        
        user.address = json["address"].stringValue
        user.phoneHome = json["phone_home"].stringValue
        user.phoneMobile = json["phone_mobile"].stringValue
        user.fullname = json["fullname"].stringValue
        user.address = json["address"].stringValue
        if let gender = json["gender"].string, (gender == "male" || gender == "female"){
            user.gender = Gender(rawValue: gender)!
        }
        
        
        user.country = json["country"].stringValue
        user.state = json["state"].stringValue
        user.postcode = json["postcode"].stringValue
        user.birthday = json["birthday"].date(gmt: 0)
        return user
    }
}

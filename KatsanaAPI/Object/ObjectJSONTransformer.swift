//
//  ObjectJSONTransformer.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit
import SwiftyJSON

class ObjectJSONTransformer: NSObject {
    class func UserObject(json : JSON) -> KMUser {
        let user = KMUser()
        user.email = json["email"].string
        user.userId = json["id"].string
        user.address = json["address"].string
        user.phoneHome = json["phone_home"].string
        user.phoneMobile = json["phone_mobile"].string
        user.fullname = json["fullname"].string
        user.emergencyFullName = json["meta"]["fullname"].string
        user.emergencyPhoneHome = json["meta"]["phone"]["home"].string
        user.emergencyPhoneMobile = json["meta"]["phone"]["mobile"].string
        user.avatarURLPath = json["avatar"]["url"].string
        
        let createdAt = json["created_at"].string
        let updatedAt = json["updated_at"].string
        
        
        return user
    }
    
    class func VehicleObject(json : JSON) -> KMVehicle {
        let vehicle = KMVehicle()
        vehicle.userId = json["email"].string
        vehicle.vehicleId = json["id"].string
        vehicle.vehicleDescription = json["address"].string
        vehicle.vehicleNumber = json["phone_home"].string
        vehicle.imei = json["phone_mobile"].string
        vehicle.mode = json["fullname"].string
        
        vehicle.todayMaxSpeed = CGFloat(json["meta"]["phone"]["home"].floatValue)
        vehicle.markerURLPath = json["meta"]["phone"]["mobile"].string
        vehicle.avatarURLPath = json["avatar"]["url"].string
        vehicle.speedLimit = CGFloat(json["avatar"]["url"].floatValue)
        vehicle.odometer = CGFloat(json["avatar"]["url"].floatValue)
        vehicle.subscriptionEnd = json["avatar"]["url"].string
        vehicle.websocket = json["avatar"]["url"].string
        
        
        vehicle.current = json["meta"]["fullname"].string
        
        let createdAt = json["created_at"].string
        let updatedAt = json["updated_at"].string
        
        
        return vehicle
    }
}




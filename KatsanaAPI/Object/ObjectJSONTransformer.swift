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
}


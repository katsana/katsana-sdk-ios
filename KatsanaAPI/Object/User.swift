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
    
    public var emergencyFullname: String!
    public var emergencyPhoneHome: String!
    public var emergencyPhoneMobile: String!
    public var imageURL: String!
    public var thumbImageURL: String!
    
    public var createdAt: Date!
    public var updatedAt: Date!
    
    init(email: String) {
        self.email = email
    }
    
    class func fastCodingKeys() -> [Any?] {
        return ["userId", "email", "address", "phoneHome", "phoneMobile", "fullname", "status", "createdAt", "imageURL", "thumbImageURL"]
    }

}


//
//  Insurer.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutf Wan Md Hatta on 14/12/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

@objcMembers
open class Insurer: NSObject {
    public var country: String
    public var name: String
    public var partner = false
    
    override open class func fastCodingKeys() -> [Any]? {
        return ["country", "name", "partner"]
    }
    
    init(name: String, country: String, partner: Bool = false) {
        self.country = country
        self.partner = partner
        self.name = name
    }
}

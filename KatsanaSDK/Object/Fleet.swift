//
//  Fleet.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 06/05/2020.
//  Copyright © 2020 pixelated. All rights reserved.
//


@objcMembers
open class Fleet: NSObject, Codable {
    open var fleetId = 0
    open var name = ""
    open var deviceCount = 0
    
    override open class func fastCodingKeys() -> [Any]? {
        return ["fleetId", "name", "deviceCount"]
    }
}

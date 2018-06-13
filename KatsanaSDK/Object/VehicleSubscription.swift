//
//  VehicleSubscription.swift
//  KatsanaSDK
//
//  Created by Wan Lutfi on 09/04/2018.
//  Copyright © 2018 pixelated. All rights reserved.
//


@objc public enum VehicleSubscriptionStatus: Int{
    case active
    case grace
    case expired
}

open class VehicleSubscription: NSObject {
    override open class func fastCodingKeys() -> [Any]? {
        return ["id", "userId", "planId", "planName", "planDescription", "billingCycle", "amountBeforeTax", "amountAfterTax", "taxPercent", "status", "endsAt", "isExpiring", "upgrades", "vehicle", "devices"]
    }
    
    open var id: String!
    open var userId: String!
    open var planId: String!
    open var planName: String!
    open var planDescription: String!
    open var billingCycle: Int = 0
    
    open var amountBeforeTax : Float = 0
    open var amountAfterTax : Float = 0
    open var taxPercent: Float = 0
    open var taxAmount: Float = 0
    
    open var status: VehicleSubscriptionStatus = .active
    open var endsAt: Date!
    open var isExpiring = false

    open var upgrades = [VehicleSubscription]()
    
    //Need to be set manually
    open var vehicle: Vehicle!
    open var devices = [Vehicle]()
    
    open func firstDevice() -> Vehicle {
        return devices.first!
    }
}

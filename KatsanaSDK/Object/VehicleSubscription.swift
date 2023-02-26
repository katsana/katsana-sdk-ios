//
//  VehicleSubscription.swift
//  KatsanaSDK
//
//  Created by Wan Lutfi on 09/04/2018.
//  Copyright © 2018 pixelated. All rights reserved.
//


public enum VehicleSubscriptionStatus: Int{
    case active
    case expiring
    case expired
    case terminated
    case unknown
}

open class VehicleSubscription: Codable {
    
    public let deviceId: String
    public let subscriptionId: String
    
    open var deviceImei: String?
    open var vehicleNumber: String?
    open var vehicleDescription: String?
    open var vehicleExpiredAt: Date?
    
    
    open var subscriptionPrice: Int = 0
    open var subscriptionPriceWithTax: Int = 0
    open var subscriptionTax: Float = 0
    
    open var subscriptionStartAt: Date?
    open var subscriptionEndAt: Date?
    
    open var planId: String?
    open var planName: String?
    open var planDescription: String?
    open var planPrice: Int = 0
//    open var planTaxRate: Int = 0 //Should not be used
//    open var planTaxValue: Int = 0 //Should not be used
    open var planBillingCycle: Int = 0
    open var planQuickBooksId: String?
    open var planRenewalAddonId: String?
    open var planTagId: String?
    open var planType: String?
    open var planCreatedAt: Date?
    open var planUpdatedAt: Date?
    
    open var isReseller = false
    
    init(deviceId: String, subscriptionId: String){
        self.deviceId = deviceId
        self.subscriptionId = subscriptionId
    }
    
    open func status() -> VehicleSubscriptionStatus {
        if let date = vehicleExpiredAt {
            var status = VehicleSubscriptionStatus.unknown
            let dayDuration = date.daysAfterDate(Date())
            if dayDuration >= 60 {
                status = .active
            }
            else if dayDuration >= 0, dayDuration < 60{
                status = .expiring
            }
            else if dayDuration < 0, dayDuration > -60{
                status = .expired
            }else{
                status = .terminated
            }
            return status
        }
        return .unknown
    }
}

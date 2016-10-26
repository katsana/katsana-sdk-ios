//
//  Violation.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 25/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit

@objc public enum ActivityType : Int {
    case none
    case tripStart
    case time
    case speed
    case area
    case batteryCutoff
    case refuel
    case siphoning
    case checkpoint
    case harshBrake
    case harshAccelerate
    case harshCorner
    case speedSummary
    //More can be added
}

//@property (nonatomic, strong) NSString *identifier;
//@property (nonatomic, assign) CGFloat altitude;
//@property (nonatomic, assign) CGFloat course;
//@property (nonatomic, assign) CGFloat speed;
//@property (nonatomic, strong) NSAttributedString *attributedMessage;
//
//@property (nonatomic, strong) NSString *serverTimeText;

public class VehicleActivity: NSObject {
    var vehicleId: String!
    var message: String!
    var attributedMessage: NSAttributedString!
    var address: String!
    
    var distance: Float!
    var duration: Float!
    var latitude: Double!
    var longitude: Double!
    var altitude: Double!
    var course: Double!
    
    var speed: Double!
    var maxSpeed: Float!
    var averageSpeed: Float!
    
    var timeString : String!
    var startTime: Date!
    var endTime: Date!
    var startPosition: Int!
    var endPosition: Int!
    var violationId: Int!
    var policyId: Int!
    public var activityType: ActivityType = .none
    
    /// Policy string from server
    var policyKey: String!{
        didSet{
            var type : ActivityType!
            switch policyKey {
            case "speed":
                type = .speed
            case "movement":
                type = .time
            case "area":
                type = .area
            case "battery-cutoff":
                type = .batteryCutoff
            case "trip-start":
                type = .tripStart
            case "speed-summary":
                type = .speedSummary
            case "harsh-brake":
                type = .harshBrake
            case "harsh-accelerate":
                type = .harshAccelerate
            case "harsh-corner":
                type = .harshCorner
            case "checkpoint":
                type = .checkpoint
            default:
                print("Policy" + policyKey + "not handled")
            }
            activityType = type
        }
    }
    
    class func fastCodingKeys() -> [String]! {
        return ["deviceId", "message", "distance", "duration", "latitude", "longitude", "startTime", "endTime", "startPosition", "endPosition", "violationId", "policyId", "policyKey", "maxSpeed", "averageSpeed", "identifier", "altitude", "course", "speed", "timeString"]
    }
    
    public func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public func vehicle() -> KMVehicle! {
        return KatsanaAPI.shared.vehicleWith(vehicleId: vehicleId)
    }
    
    public func addressWithCompletion(completion: @escaping (String?) -> Void) -> Void {
        guard latitude == 0 || longitude == 0 else {
            completion("")
            return
        }
        KatsanaAPI.shared.requestAddress(for: coordinate(), completion: {address in
            completion(address?.optimizedAddress())
        })
    }
    
    func localizedSpeedString() -> String {
        
    }
    
}

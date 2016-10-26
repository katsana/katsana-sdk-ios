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
    public var vehicleId: String!
    public var message: String!
    public var attributedMessage: NSAttributedString!{
        set{
        }
        get{
            //Implement function updateAttributedMessage in extension for lazy attributed message initialization
            if self.attributedMessage == nil {
                if responds(to: Selector(("updateAttributedMessage"))) {
                    perform(Selector(("updateAttributedMessage")))
                }
            }
            return self.attributedMessage
        }
    }
    public var address: String!
    
    public var distance: Float!
    public var duration: Float!
    public var latitude: Double!
    public var longitude: Double!
    public var altitude: Double!
    public var course: Double!
    
    public var speed: Double!
    public var maxSpeed: Float!
    public var averageSpeed: Float!
    
    public var timeString : String!
    public var startTime: Date!
    public var endTime: Date!
    public var startPosition: Int!
    public var endPosition: Int!
    
    public var identifier : String!
    public var violationId: Int!
    public var policyId: Int!
    public var type: ActivityType = .none
    
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
            self.type = type
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
    
    public func speedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: speed)
    }
    
}

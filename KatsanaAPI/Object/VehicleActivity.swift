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
    case doorAjar
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
    internal var privateAttributedMessage: NSAttributedString!
    
    class func fastCodingKeys() -> [String]! {
        return ["vehicleId", "message", "distance", "duration", "latitude", "longitude", "startTime", "endTime", "startPosition", "endPosition", "violationId", "policyId", "policyKey", "maxSpeed", "averageSpeed", "identifier", "altitude", "course", "speed", "timeString"]
    }
    
    public var vehicleId: String!
    public var message: String!
    public var attributedMessage: NSAttributedString!{
        set{
            privateAttributedMessage = newValue
        }
        get{
            //Implement function updateAttributedMessage in extension for lazy attributed message initialization
            if privateAttributedMessage == nil {
                if self.responds(to: Selector(("updateAttributedMessage"))) {
                    perform(Selector(("updateAttributedMessage")))
                }
            }
            return privateAttributedMessage
        }
    }
    public var address: String!
    
    public var distance: Float = 0
    public var duration: Float = 0
    public var latitude: Double = 0
    public var longitude: Double = 0
    public var altitude: Double = 0
    public var course: Double = 0
    
    public var speed: Float = 0
    public var maxSpeed: Float = 0
    public var averageSpeed: Float = 0
    
    public var timeString : String!
    public var startTime: Date!
    public var endTime: Date!
    public var startPosition: Int = 0
    public var endPosition: Int = 0
    
    public var identifier : String!
    public var violationId: Int = 0
    public var policyId: Int = 0
    public lazy var type: ActivityType = {
        var type : ActivityType = .none
        switch self.policyKey {
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
        case "door-ajar":
            type = .doorAjar
        default:
            print("Policy " + self.policyKey + " not handled")
        }
        return type
    }()
    
    /// Policy string from server
    var policyKey: String!
    
    convenience override init() {
        self.init(dictionary: nil, identifier: nil)
    }
    
    public init(dictionary:[String : Any]! = nil, identifier:String! = nil) {
        super.init()
        if dictionary != nil {
            self.policyKey = dictionary["type"] as? String
            self.vehicleId = (dictionary["device_id"] as? NSNumber)?.stringValue
            self.message = dictionary["message"] as? String
            self.timeString = dictionary["time"] as? String
            self.startTime = (dictionary["time"] as? String)?.date(gmt: 0)
            self.identifier = identifier
        }        
        
    }

    public func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public func vehicle() -> KMVehicle! {
        return KatsanaAPI.shared.vehicleWith(vehicleId: vehicleId)
    }
    
    public func address(completion: @escaping (String?) -> Void) -> Void {
        guard latitude == 0 || longitude == 0 else {
            completion("")
            return
        }
        KatsanaAPI.shared.requestAddress(for: coordinate(), completion: {address in
            completion(address?.optimizedAddress())
        })
    }

    // MARK: Display
    
    public func speedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(speed))
    }
    
    public func maxSpeedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(maxSpeed))
    }
    
//    class public func allTypes() -> [String] {
//        return ["speed", "movement", "area", "battery-cutoff", "trip-start", "speed-summary", "harsh-brake", "harsh-accelerate", "harsh-corner", "checkpoint"]
//    }
}

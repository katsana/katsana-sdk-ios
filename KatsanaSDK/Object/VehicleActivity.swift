//
//  Violation.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 25/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import CoreLocation

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
    case intrusion
    case tripScore
    case fuelLow
    //More can be added
}

@objcMembers
open class VehicleActivity: NSObject {
    internal var privateAttributedMessage: NSAttributedString!
    
    override open class func fastCodingKeys() -> [Any]? {
        return ["vehicleId", "message", "distance", "duration", "latitude", "longitude", "startTime", "endTime", "startPosition", "endPosition", "violationId", "policyId", "policyKey", "maxSpeed", "averageSpeed", "identifier", "altitude", "course", "speed", "timeString"]
    }
    
    open var vehicleId: String!
    open var message: String!
    open var attributedMessage: NSAttributedString!{
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
    open var address: String!
    
    open var distance: Float = 0
    open var duration: Float = 0
    open var latitude: Double = 0
    open var longitude: Double = 0
    open var altitude: Double = 0
    open var course: Double = 0
    
    open var speed: Float = 0
    open var maxSpeed: Float = 0
    open var averageSpeed: Float = 0
    
    open var timeString : String!
    open var startTime = Date(timeIntervalSinceReferenceDate: 0)
    open var endTime = Date(timeIntervalSinceReferenceDate: 0)
    open var startPosition: Int = 0
    open var endPosition: Int = 0
    
    open var identifier : String!
    open var violationId: Int = 0
    open var policyId: Int = 0
    open lazy var type: ActivityType = {
        guard self.policyKey != nil else{
            return .none
        }
        
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
        case "intrusion":
            type = .intrusion
        case "trip-score":
            type = .tripScore
        case "fuel-low":
            type = .fuelLow
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
            if let date = (dictionary["time"] as? String)?.date(gmt: 0){
                self.startTime = date
            }else{
                KatsanaAPI.shared.log.warning("Date cannot be create \(String(describing: self.timeString))")
            }
            self.identifier = identifier
        }        
        
    }

    open func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    open func vehicle() -> Vehicle! {
        return KatsanaAPI.shared.vehicleWith(vehicleId: vehicleId)
    }
    
    open func address(completion: @escaping (String?) -> Void) -> Void {
        guard latitude != 0 || longitude != 0 else {
            completion("")
            return
        }
        KatsanaAPI.shared.requestAddress(for: coordinate(), completion: {address in
            completion(address?.optimizedAddress())
        })
    }

    // MARK: Display
    
    open func speedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(speed))
    }
    
    open func maxSpeedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(maxSpeed))
    }
    
    open override var description: String{
        return "\(super.description): \(message!) \(startTime)"
    }
    
}

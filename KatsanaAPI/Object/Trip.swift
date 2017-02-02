//
//  Trip.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import UIKit

public class Trip: NSObject {
    public var start: VehicleLocation!
    public var end: VehicleLocation!
    public var distance: Double = 0
    public var duration: Double = 0
    public var maxSpeed: Float = 0
    public var averageSpeed: Float = 0
    public var idleDuration: Float = 0
    public var score: Float = -1
    
    public var idles = [VehicleLocation]()
    public var locations = [VehicleLocation]()
    public var violations = [VehicleActivity]()
    
    ///Next trip and prev trip automatically set when trips are set in Travel class
    weak var nextTrip: Trip!
    weak var prevTrip: Trip!
    
    //Extra data that user can set to trip
    public var extraData: [String: Any]!
    
    class func fastCodingKeys() -> [Any?] {
        return ["start", "end", "distance", "duration", "maxSpeed", "averageSpeed", "idleDuration", "locations", "violations", "idles", "score", "extraData"]
    }
    
    // MARK: Logic
    
    func durationToNextTrip() -> Float {
        if let nextTrip = nextTrip {
            let duration = nextTrip.start.trackedAt.timeIntervalSince(end.trackedAt)
            return Float(duration)
        }
        return 0
    }
    
    func durationToNextTripString() -> String {
        return KatsanaFormatter.durationStringFrom(seconds: Double(durationToNextTrip()))
    }
    
    func maxSpeedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(maxSpeed))
    }
    
}

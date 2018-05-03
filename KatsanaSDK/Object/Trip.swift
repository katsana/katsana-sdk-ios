//
//  Trip.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//
import FastCoding

open class Trip: NSObject {
    open var start: VehicleLocation!
    open var end: VehicleLocation!
    open var distance: Double = 0
    open var duration: Double = 0
    open var maxSpeed: Float = 0
    open var averageSpeed: Float = 0
    open var idleDuration: Float = 0
    open var score: Float = -1
    open var date = Date(timeIntervalSinceReferenceDate: 0)
    
    open var idles = [VehicleLocation]()
    @objc dynamic open var locations = [VehicleLocation]()
    open var violations = [VehicleActivity]()
    
    ///Next trip and prev trip automatically set when trips are set in Travel class
    weak open var nextTrip: Trip!
    weak open var prevTrip: Trip!
    
    //Extra data that user can set to trip
    open var extraData = [String: Any]()
    
    override open class func fastCodingKeys() -> [Any]? {
        return ["start", "end", "distance", "duration", "maxSpeed", "averageSpeed", "idleDuration", "locations", "violations", "idles", "score", "extraData", "date"]
    }
    
    // MARK: Logic
    
    ///Because locations size is high, need to load only when needed
//    func loadLocations(completion: (_ locations: [VehicleLocation])->Void) {
//        <#function body#>
//    }
    
    open func durationToNextTrip() -> Float {
        if let nextTrip = nextTrip {
            let duration = nextTrip.start.trackedAt.timeIntervalSince(end.trackedAt)
            return Float(duration)
        }
        return 0
    }
    
    open func durationToNextTripString() -> String {
        return KatsanaFormatter.durationStringFrom(seconds: Double(durationToNextTrip()))
    }
    
    open func maxSpeedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(maxSpeed))
    }
    
    open func averageSpeedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(averageSpeed))
    }
    
    open func durationString() -> String {
        return KatsanaFormatter.durationStringFrom(seconds: duration)
    }
    
    open func distanceString() -> String {
        return KatsanaFormatter.distanceStringFrom(meter: distance)
    }
}

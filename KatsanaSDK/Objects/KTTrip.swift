//
//  Trip.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//
import Foundation

open class KTTrip: NSCopying, Codable {
    enum CodingKeys: CodingKey {
        case id
        case start
        case end
        case distance
        case duration
        case maxSpeed
        case averageSpeed
        case idleDuration
        case score
        case date
        case publicTransit
        case idles
        case locations
    }
    
    open var id : String!
    ///Alternate id set manually if required. Default to nil
    open var alternateId: String!
    open var start: VehicleLocation?
    open var end: VehicleLocation?
    open var distance: Double = 0
    open var duration: Double = 0
    open var maxSpeed: Float = 0
    open var averageSpeed: Float = 0
    open var idleDuration: Float = 0
    open var score: Float = -1
    open var date = Date(timeIntervalSinceReferenceDate: 0)
    open var publicTransit = false
    
    open var idles = [VehicleLocation]()
    open var locations = [VehicleLocation]()
    open var violations = [VehicleActivity]()
    
    ///Next trip and prev trip automatically set when trips are set in Travel class
    weak open var nextTrip: KTTrip?
    weak open var prevTrip: KTTrip?
    
    //Extra data that user can set to trip
    open var extraData = [String: Any]()
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let trip = KTTrip()
        trip.id = id
        trip.maxSpeed = maxSpeed
        trip.distance = distance
        trip.averageSpeed = averageSpeed
        trip.idleDuration = idleDuration
        trip.duration = duration
        trip.start = start
        trip.end = end
        trip.locations = locations
        trip.idles = idles
        trip.score = score
        trip.date = date
        trip.violations = violations
        trip.nextTrip = nextTrip
        trip.prevTrip = prevTrip
        trip.extraData = extraData
        trip.publicTransit = publicTransit
        return trip
    }
    
    // MARK: Logic
    
    open func durationToNextTrip() -> Float {
        if let nextTripStart = nextTrip?.start, let end {
            let duration = nextTripStart.trackedAt.timeIntervalSince(end.trackedAt)
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

//
//  Trip.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//
import Foundation

public class KTTrip: NSCopying, Codable {
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
        case publicTransit
        case idles
        case locations
    }
    
    public var id : String!
    ///Alternate id set manually if required. Default to nil
    public var alternateId: String!
    public let start: VehicleLocation
    public let end: VehicleLocation
    public var distance: Double = 0
    public var duration: Double = 0
    public var maxSpeed: Float = 0
    public var averageSpeed: Float = 0
    public var idleDuration: Float = 0
    public var score: Float = -1
    public var publicTransit = false
    
    public var idles = [VehicleLocation]()
    public var locations: [VehicleLocation]
    public var violations = [VehicleActivity]()
    
    ///Next trip and prev trip automatically set when trips are set in Travel class
//    weak public var nextTrip: KTTrip?
//    weak public var prevTrip: KTTrip?
    
    //Extra data that user can set to trip
    public var extraData = [String: Any]()
    
    public init(start: VehicleLocation, end: VehicleLocation, locations: [VehicleLocation]) {
        self.start = start
        self.end = end
        self.locations = locations
    }
    
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let trip = KTTrip(start: start, end: end, locations: locations)
        trip.id = id
        trip.maxSpeed = maxSpeed
        trip.distance = distance
        trip.averageSpeed = averageSpeed
        trip.idleDuration = idleDuration
        trip.duration = duration
        trip.locations = locations
        trip.idles = idles
        trip.score = score
        trip.violations = violations
//        trip.nextTrip = nextTrip
//        trip.prevTrip = prevTrip
        trip.extraData = extraData
        trip.publicTransit = publicTransit
        return trip
    }
    
    // MARK: Logic
    
//    public func durationToNextTrip() -> Float {
//        if let nextTripStart = nextTrip?.start, let end {
//            let duration = nextTripStart.trackedAt.timeIntervalSince(end.trackedAt)
//            return Float(duration)
//        }
//        return 0
//    }
//
//    public func durationToNextTripString() -> String {
//        return KatsanaFormatter.durationStringFrom(seconds: Double(durationToNextTrip()))
//    }
    
    public func startDate() -> Date{
        return start.trackedAt
    }
    
    public func maxSpeedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(maxSpeed))
    }
    
    public func averageSpeedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(averageSpeed))
    }
    
    public func durationString() -> String {
        return KatsanaFormatter.durationStringFrom(seconds: duration)
    }
    
    public func distanceString() -> String {
        return KatsanaFormatter.distanceStringFrom(meter: distance)
    }
}

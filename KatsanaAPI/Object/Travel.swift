//
//  Travel.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import UIKit

///Vehicle travel data for a day
public class Travel: NSObject {
    public var vehicleId : String!
    public var maxSpeed : Float = 0
    public var distance : Double = 0
    public var idleDuration : Double = 0
    
    private var _duration : Double = 0
    public var duration : Double{
        set{
            _duration = newValue
        }
        get{
            if _duration == 0 {
                var totalDuration : Double = 0
                for trip in trips {
                    totalDuration = trip.duration
                }
                return totalDuration
            }
            return _duration
        }
    }
    
    public var trips = [Trip](){
        didSet{
            //Set trip count explicitly
            tripCount = trips.count
            
            //Set previous and next trip
            for (index, trip) in trips.enumerated() {
                if index == 0 {
                    if trips.count > 1{
                        trip.nextTrip = trips[1]
                    }
                }else if index == trips.count - 1{
                    trip.prevTrip = trips[index-1];
                }
                else {
                    trip.prevTrip = trips[index-1];
                    if (trips.count > index+1) {
                        trip.nextTrip = trips[index+1];
                    }
                }
            }
        }
    }
    
    public var date : Date!
    public var lastUpdate : Date!
    
    public var violationCount : Int = 0
    public var tripCount : Int = 0

    public var needLoadTripHistory = false
    
    class func fastCodingKeys() -> [Any?] {
        return ["trips", "maxSpeed", "distance", "violationCount", "date", "idleDuration", "duration", "tripCount", "needLoadTripHistory", "vehicleId"]
    }
    
    // MARK: Helper
    
    public var _vehicle : Vehicle!
    func owner() -> Vehicle {
        if _vehicle == nil {
//            _vehicle = KatsanaAPI.shared.vehicleWith(vehicleId: vehicleId)
        }
        return _vehicle
    }
    
    func averageSpeed() -> Double {
        var totalSpeed : Float = 0
        for trip in trips {
            totalSpeed = trip.averageSpeed
        }
        let averageSpeed = totalSpeed/Float(trips.count)
        return Double(averageSpeed)
    }
    
    func averageSpeedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: averageSpeed())
    }
    
    func idleDurationString() -> String {
        var duration : Float = 0;
        for trip in trips {
            duration += trip.idleDuration
        }
        if duration == 0 {
            duration = Float(idleDuration)
        }
        return KatsanaFormatter.durationStringFrom(seconds: Double(duration))
    }
    
    func todayMaxSpeedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(maxSpeed))
    }
    
    func totalDistanceString() -> String {
        return KatsanaFormatter.distanceStringFrom(meter: distance)
    }
    
    func totalDurationString() -> String {
        return KatsanaFormatter.durationStringFrom(seconds: duration)
    }
    
    // MARK: Logic
    
    ///Get trip at specified time, return nil if not found
    func trip(at time: Date) -> Trip! {
        for trip in trips {
            if let startTime = trip.start?.trackedAt, let endTime = trip.end?.trackedAt  {
                if time.timeIntervalSince(startTime) >= 0, endTime.timeIntervalSince(time) >= 0 {
                    return trip
                }
            }
        }
        return nil
    }
    
    // MARK: Equatable Protocol
    
    static public func ==(a: Travel, b: Travel) -> Bool
    {
        guard a.date != nil, b.date != nil else {
            return false
        }
        
        var equal = false
        if Calendar.current.isDate(a.date, equalTo: b.date, toGranularity: .day), a.trips.count == b.trips.count {
            equal = true
        }
        return equal
    }
    
    // MARK: Description
    
    public override var description: String{
        return String(format: "%@, trips:%@, maxSpeed:%.1f, date:%@", super.description, trips.description, maxSpeed, date.description)
    }
    
}

//
//  Travel.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import FastCoding

///The class contains information about vehicle travel for particular day.
@objcMembers
open class Travel: NSObject, NSCopying {
    open var vehicleId : String!
    open var maxSpeed : Float = 0
    open var distance : Double = 0
    open var idleDuration : Double = 0
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let travel = Travel()
        travel.vehicleId = vehicleId
        travel.maxSpeed = maxSpeed
        travel.distance = distance
        travel.idleDuration = idleDuration
        travel.duration = duration
        
        var newTrips = [KTTrip]()
        for trip in trips{
            let newTrip = trip.copy() as! KTTrip
            newTrips.append(newTrip)
        }
        travel.trips = newTrips
        travel.date = date
        travel.lastUpdate = lastUpdate
        travel.violationCount = violationCount
        travel.tripCount = tripCount
        travel._vehicle = _vehicle
        return travel
    }
    
    private var _duration : Double = 0
    open var duration : Double{
        set{
            _duration = newValue
        }
        get{
            if trips.count > 0 {
                var totalDuration : Double = 0
                for trip in trips {
                    totalDuration += trip.duration
                }
                _duration = totalDuration
            }
            return _duration
        }
    }
    
    open var trips = [KTTrip](){
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
    
    open var date : Date!
    open var lastUpdate = Date()
    
    open var violationCount : Int = 0
    open var tripCount : Int = 0

    open var needLoadTripHistory = false
    
    override open class func fastCodingKeys() -> [Any]? {
        return ["trips", "maxSpeed", "distance", "violationCount", "date", "idleDuration", "duration", "tripCount", "needLoadTripHistory", "vehicleId"]
    }
    
    // MARK: Helper
    
    open var _vehicle : KTVehicle!
    open func owner() -> KTVehicle! {
        if _vehicle == nil, let vehicleId = vehicleId {
            _vehicle = KatsanaAPI.shared.vehicleWith(vehicleId: vehicleId)
        }
        return _vehicle
    }
    
    open func averageSpeed() -> Double {
        var totalSpeed : Float = 0
        for trip in trips {
            totalSpeed = trip.averageSpeed
        }
        let averageSpeed = totalSpeed/Float(trips.count)
        return Double(averageSpeed)
    }
    
    open func averageSpeedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: averageSpeed())
    }
    
    open func idleDurationString() -> String {
        var duration : Float = 0;
        for trip in trips {
            duration += trip.idleDuration
        }
        if duration == 0 {
            duration = Float(idleDuration)
        }
        return KatsanaFormatter.durationStringFrom(seconds: Double(duration))
    }
    
    open func todayMaxSpeedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(maxSpeed))
    }
    
    open func totalDistanceString() -> String {
        return KatsanaFormatter.distanceStringFrom(meter: distance)
    }
    
    open func totalDurationString() -> String {
        return KatsanaFormatter.durationStringFrom(seconds: duration)
    }
    
    // MARK: Logic
    
    ///Get trip at specified time, return nil if not found
    open func trip(at time: Date) -> KTTrip! {
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
        if Calendar.current.isDate(a.date, equalTo: b.date, toGranularity: .day), a.trips.count == b.trips.count, fabs(a.distance - b.distance) < 50 {
            equal = true
        }
        return equal
    }
    
    // MARK: Description
    
    open override var description: String{
        return String(format: "%@, trips:%@, maxSpeed:%.1f, date:%@", super.description, trips.description, maxSpeed, date?.description ?? "")
    }
    
    open class func separateTripsIntoTravels(trips : [KTTrip]) -> [Travel] {
        var travels = [Travel]()
        var currentTravel: Travel!
        for trip in trips{
            if currentTravel == nil{
                currentTravel = Travel()
                currentTravel.date = trip.date
                currentTravel.trips = [KTTrip]()
                travels.append(currentTravel)
            }
            else if trip.date.isEqualToDateIgnoringTime(currentTravel.date){
                //Do nothing
            }else{
                //If date not same, create new travel
                currentTravel = Travel()
                currentTravel.date = trip.date
                travels.append(currentTravel)
            }
            currentTravel.trips.append(trip)
        }
        return travels
    }
    
    func updateDataFromTrip() {
        var distance : Double = 0
        var maxSpeed : CGFloat = 0
        var duration : Double = 0
        
        for trip in trips {
            distance += trip.distance
            duration += trip.duration
            maxSpeed = max(maxSpeed, CGFloat(trip.maxSpeed))
        }
        self.distance = distance
        self.duration = duration
        self.maxSpeed = Float(maxSpeed)
        if let date = trips.first?.date{
            self.date = date
        }
    }
    
}

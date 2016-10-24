//
//  ObjectJSONTransformer.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit
import SwiftyJSON


/// Class to convert Swifty JSON to API object
class ObjectJSONTransformer: NSObject {
    class func UserObject(json : JSON) -> KMUser {
        let user = KMUser()
        user.email = json["email"].rawString()
        user.userId = json["id"].rawString()
        user.address = json["address"].rawString()
        user.phoneHome = json["phone_home"].rawString()
        user.phoneMobile = json["phone_mobile"].rawString()
        user.fullname = json["fullname"].rawString()
        user.emergencyFullName = json["meta"]["fullname"].rawString()
        user.emergencyPhoneHome = json["meta"]["phone"]["home"].rawString()
        user.emergencyPhoneMobile = json["meta"]["phone"]["mobile"].rawString()
        user.avatarURLPath = json["avatar"]["url"].string
        
        user.createdAt = json["created_at"].date(gmt: 0)
        user.updatedAt = json["updated_at"].date(gmt: 0)
        return user
    }
    
    class func VehiclesObject(json : JSON) -> [KMVehicle]{
        let arr = json["devices"].arrayValue
        let vehicles = arr.map{VehicleObject(json: $0)}
        return vehicles
    }
    
    class func VehicleObject(json : JSON) -> KMVehicle {
        var dicto = json["device"]
        //Check if called from vehicle or vehicles API
        if dicto.dictionaryValue.keys.count == 0 {
            dicto = json
        }
        
        let vehicle = KMVehicle()
        vehicle.userId = dicto["user_id"].rawString()
        vehicle.vehicleId = dicto["id"].rawString()
        vehicle.vehicleDescription = dicto["description"].string
        vehicle.vehicleNumber = dicto["vehicle_number"].rawString()
        vehicle.imei = dicto["imei"].rawString()
        vehicle.mode = dicto["mode"].rawString()
        
        vehicle.todayMaxSpeed = dicto["today_max_speed"].floatValue
        vehicle.markerURLPath = dicto["marker"].string
        vehicle.avatarURLPath = dicto["avatar"].string
        vehicle.odometer = dicto["odometer"].floatValue
        vehicle.websocket = dicto["meta"]["websocket"].boolValue
        
        vehicle.subscriptionEnd = dicto["ends_at"].date
        vehicle.current = self.VehicleLocationObject(json: json["current"])
        return vehicle
    }
    
    class func VehicleLocationObject(json : JSON) -> KMVehicleLocation {
        let pos = KMVehicleLocation()
//        pos.altitude = json["altitude"].doubleValue
//        pos.course = json["course"].string
        pos.latitude = json["latitude"].doubleValue
        pos.longitude = json["longitude"].doubleValue
//        pos.distance = json["distance"].floatValue
//        pos.fuelPercentage = json["mode"].string
        
        pos.state = json["state"].string
        pos.voltage = json["voltage"].rawString()
        pos.gsm = json["gsm"].rawString()
        pos.ignitionState = json["ignition"].rawString()
        pos.trackedAt = json["tracked_at"].date(gmt: 0)
        
        return pos
    }
    
    class func TravelSummariesObject(json : JSON) -> [KMTravelHistory] {
        var summaries = [KMTravelHistory]()
        let array = json.arrayValue
        for jsonObj in array {
            let history = TravelSummaryObject(json: jsonObj)
            summaries.append(history)
        }
        return summaries
    }
    
    class func TravelSummaryObject(json : JSON) -> KMTravelHistory {
        let history = KMTravelHistory()
        history.maxSpeed = json["max_speed"].floatValue
        history.distance = json["distance"].doubleValue
        history.violationCount = json["violation"].intValue
        history.tripCount = json["trip"].intValue
        history.duration = json["duration"].doubleValue
        history.idleDuration = json["idle_duration"].doubleValue
        history.date = json["date"].dateWithoutTime
//        /change date to local date and check UTC time again
        return history
    }
    
    class func TravelHistoryObject(json : JSON) -> KMTravelHistory {
        let history = KMTravelHistory()
        history.maxSpeed = json["summary"]["max_speed"].floatValue
        history.distance = json["summary"]["distance"].doubleValue
        history.violationCount = json["summary"]["violation"].intValue
        history.trips = json["trips"].arrayValue.map{TripObject(json: $0)}
        
        history.date = json["duration"]["from"].date(gmt: 0)
        return history
    }
    
    class func TripObject(json : JSON) -> KMTrip {
        let trip = KMTrip()
        trip.maxSpeed = json["max_speed"].floatValue
        trip.distance = json["distance"].doubleValue
        trip.duration = json["duration"].doubleValue
        trip.averageSpeed = json["average_speed"].floatValue
        trip.idleDuration = json["idle_duration"].doubleValue
        
        trip.start = VehicleLocationObject(json: json["start"])
        trip.end = VehicleLocationObject(json: json["end"])
        trip.idles = json["idles"].arrayValue.map{VehicleLocationObject(json: $0)}
        trip.histories = json["histories"].arrayValue.map {VehicleLocationObject(json: $0)}
        
        return trip
    }
    
    class func AddressObject(json : JSON) -> KMAddress {
        let address = KMAddress()
        address.latitude = json["latitude"].doubleValue
        address.longitude = json["longitude"].doubleValue
        let streetNumber = json["street_number"].string
        address.streetNumber = streetNumber
        address.streetName = json["street_name"].string
        address.locality = json["locality"].string
        address.sublocality = json["sublocality"].string
        address.postcode = json["postcode"].intValue
        address.country = json["country"].string
        address.address = json["address"].string

        return address
    }
}

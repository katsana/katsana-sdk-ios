//
//  ObjectJSONTransformer.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit
import SwiftyJSON

class ObjectJSONTransformer: NSObject {
    class func UserObject(json : JSON) -> KMUser {
        let user = KMUser()
        user.email = json["email"].string
        user.userId = json["id"].string
        user.address = json["address"].string
        user.phoneHome = json["phone_home"].string
        user.phoneMobile = json["phone_mobile"].string
        user.fullname = json["fullname"].string
        user.emergencyFullName = json["meta"]["fullname"].string
        user.emergencyPhoneHome = json["meta"]["phone"]["home"].string
        user.emergencyPhoneMobile = json["meta"]["phone"]["mobile"].string
        user.avatarURLPath = json["avatar"]["url"].string
        
        let createdAt = json["created_at"].string
        let updatedAt = json["updated_at"].string
        
        
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
        
        let subscriptionEnd = dicto["ends_at"].string
//        vehicle.subscriptionEnd =

        vehicle.current = self.VehiclePositionObject(json: json["current"])
        
        let createdAt = dicto["created_at"].string
        let updatedAt = dicto["updated_at"].string
        
        return vehicle
    }
    
    class func VehiclePositionObject(json : JSON) -> KMVehicleLocation {
        let pos = KMVehicleLocation()
//        pos.altitude = json["altitude"].doubleValue
//        pos.course = json["course"].string
        pos.latitude = json["latitude"].doubleValue
        pos.longitude = json["longitude"].doubleValue
//        pos.distance = json["distance"].floatValue
//        pos.fuelPercentage = json["mode"].string
        
        pos.state = json["state"].string
        pos.voltage = json["voltage"].string
        pos.gsm = json["gsm"].string
        pos.ignitionState = json["ignition"].string

        let trackedAt = json["tracked_at"].string
        
        return pos
    }
    
    class func TravelHistoryObject(json : JSON) -> KMTravelHistory {
        let history = KMTravelHistory()
        history.maxSpeed = json["summary"]["max_speed"].floatValue
        history.distance = json["summary"]["distance"].doubleValue
        history.violationCount = json["summary"]["violation"].intValue
        history.trips = json["trips"].arrayValue.map{TripObject(json: $0)}
        
        let historyDate = json["duration"]["from"]

        return history
    }
    
    class func TripObject(json : JSON) -> KMTrip {
        let trip = KMTrip()
        trip.maxSpeed = json["max_speed"].floatValue
        trip.distance = json["distance"].doubleValue
        trip.duration = json["duration"].doubleValue
        trip.averageSpeed = json["average_speed"].floatValue
        trip.idleDuration = json["idle_duration"].doubleValue
        
        trip.start = VehiclePositionObject(json: json["start"])
        trip.end = VehiclePositionObject(json: json["end"])
        trip.idles = json["idles"].arrayValue.map{VehiclePositionObject(json: $0)}
        return trip
    }
}

//@property (nonatomic, strong) KMVehiclePosition *start;
//@property (nonatomic, strong) KMVehiclePosition *end;
//@property (nonatomic, assign) CGFloat distance;
//@property (nonatomic, assign) CGFloat duration;
//@property (nonatomic, assign) CGFloat maxSpeed;
//@property (nonatomic, assign) CGFloat averageSpeed;
//@property (nonatomic, assign) CGFloat idleDuration;
//@property (nonatomic, strong) NSArray *histories;
//@property (nonatomic, strong) NSArray *violations;
//
//@property (nonatomic, weak) KMTrip *nextTrip;
//@property (nonatomic, weak) KMTrip *prevTrip;




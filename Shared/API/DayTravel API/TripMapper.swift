//
//  TripMapper.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class TripMapper{
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> KTTrip {
        do{
            let json = try JSON(data: data)
            return try mapJSON(json)
        }
        catch{
            throw Error.invalidData
        }
    }
    
    public static func mapJSON(_ json: JSON) throws -> KTTrip {
        let start = VehicleLocationMapper.mapJSON(json["start"])
        let end = VehicleLocationMapper.mapJSON(json["end"])
        let locations = json["histories"].arrayValue.map{VehicleLocationMapper.mapJSON($0)}
        
        let trip = KTTrip(start: start, end: end, locations: locations)
        trip.maxSpeed = json["max_speed"].floatValue
        trip.distance = json["distance"].doubleValue
        trip.duration = json["duration"].doubleValue
        trip.averageSpeed = json["average_speed"].floatValue
        trip.idleDuration = json["idle_duration"].floatValue
        trip.id = json["id"].stringValue
        

        trip.idles = json["idles"].arrayValue.map{VehicleLocationMapper.mapJSON($0)}
        trip.violations = json["violations"].arrayValue.map{VehicleActivityMapper.mapJSON($0)}

        trip.score = json["score"].floatValue
        let type = json["type"].stringValue
        if type == "public_transit"{
            trip.publicTransit = true
        }
        
//        objectInitializationHandler?(json, KTUser.self)
        return trip
    }
    
//    func mapLocations(_ json: JSON) -> [VehicleLocation]?{
//        return VehicleLocationMapper.mapJSON(json)
//    }
}

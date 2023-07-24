//
//  VehicleLocationMapper.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class VehicleLocationMapper{
    private init() {}

    
    public static func mapJSON(_ json: JSON) -> VehicleLocation {
        let latitude = json["latitude"].doubleValue
        let longitude = json["longitude"].doubleValue
        let date = json["tracked_at"].date(gmt: 0)
        
        let pos = VehicleLocation(latitude: latitude, longitude: longitude, trackedAt: date ?? Date())
        
        pos.altitude = json["altitude"].doubleValue
        pos.course = json["course"].doubleValue
        pos.latitude = json["latitude"].doubleValue
        pos.longitude = json["longitude"].doubleValue
//        pos.distance = json["distance"].floatValue
//        pos.fuelPercentage = json["mode"].string
        pos.speed = json["speed"].floatValue
        pos.state = json["state"].stringValue
        pos.voltage = json["voltage"].intValue
        pos.gsm = json["gsm"].intValue
        pos.ignitionState = json["ignition"].boolValue
        
        
        if let harsh = json["harsh"].dictionaryObject{
            pos.extraData["harsh"] = harsh
        }
        return pos
    }
}

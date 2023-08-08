//
//  VehicleActivityMapper.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class VehicleActivityMapper{
    private init() {}
    
    public static func mapJSON(_ json: JSON) -> OldVehicleActivity {
        let violation = OldVehicleActivity()
        violation.violationId = json["id"].intValue
        violation.policyId = json["policy_id"].intValue
        violation.policyKey = json["policy_type"].stringValue
        violation.address = json["address"].stringValue
        violation.distance = json["distance"].floatValue
        violation.duration = json["duration"].floatValue
        violation.latitude = json["latitude"].doubleValue
        violation.longitude = json["longitude"].doubleValue
        if let date = json["start_time"].date(gmt: 0){
            violation.startTime = date
        }
        if let date = json["end_time"].date(gmt: 0){
            violation.endTime = date
        }
        violation.startPosition = json["start_position"].intValue
        violation.endPosition = json["end_position"].intValue
        violation.maxSpeed = json["max_speed"].floatValue
        violation.averageSpeed = json["average_speed"].floatValue
        violation.message = json["description"].stringValue
        
        return violation
    }
}

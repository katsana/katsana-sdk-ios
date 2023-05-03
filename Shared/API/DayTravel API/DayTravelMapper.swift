//
//  DayTravelMapper.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class DayTravelMapper{
    
    public enum Error: Swift.Error {
        case invalidData
        case invalidDateFormat
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> KTDayTravel {
        do{
            let json = try JSON(data: data)
            return try mapJSON(json)
        }
        catch{
            throw Error.invalidData
        }
    }
    
    public static func mapJSON(_ json: JSON) throws -> KTDayTravel {
        guard let date = json["duration"]["from"].date(gmt: 0) else{
            throw Error.invalidDateFormat
        }
        
        let history = KTDayTravel(date: date)
        history.maxSpeed = json["summary"]["max_speed"].floatValue
        history.distance = json["summary"]["distance"].doubleValue
        history.violationCount = json["summary"]["violation"].intValue
        history.trips = json["trips"].arrayValue.map{ try! TripMapper.mapJSON($0)}
        
        return history
    }
}

//
//  DayTravelSummaryMapper.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class DayTravelSummaryMapper{
    
    public enum Error: Swift.Error {
        case invalidData
        case invalidDateFormat
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> KTDayTravelSummary {
        do{
            let json = try JSON(data: data)
            return try mapJSON(json)
        }
        catch{
            throw Error.invalidData
        }
    }
    
    public static func mapJSON(_ json: JSON) throws -> KTDayTravelSummary {
        let date = try dateFromString(json["date"].stringValue)
        let distance = json["distance"].doubleValue
        let duration = json["duration"].doubleValue
        let idleDuration = json["idle_duration"].doubleValue
        let maxSpeed = json["max_speed"].doubleValue
        let tripCount = json["trip"].intValue
        let violationCount = json["violation"].intValue
        let score = json["score"].doubleValue

        let history = KTDayTravelSummary(date: date, distance: distance, duration: duration, idleDuration: idleDuration, maxSpeed: maxSpeed, tripCount: tripCount, violationCount: violationCount, score: score)
        
        return history
    }
    
    public static func dateFromString(_ text: String) throws -> Date{
        guard let date = text.dateWithoutTime else{
            throw Error.invalidDateFormat
        }
        return date
    }
}

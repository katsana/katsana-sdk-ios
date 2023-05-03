//
//  DayTravelMapper.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class DayTravelMapper{
    private static var formatter: DateFormatter?
    private static var dateFormatter: DateFormatter {
        if (formatter == nil) {
            formatter = DateFormatter()
            formatter!.dateFormat = "yyyy-MM-dd"
        }
        return formatter!
    }
    
    public enum Error: Swift.Error {
        case invalidData
        case invalidDateFormat
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> KTTripSummary {
        do{
            let json = try JSON(data: data)
            return try mapJSON(json)
        }
        catch{
            throw Error.invalidData
        }
    }
    
    public static func mapJSON(_ json: JSON) throws -> KTTripSummary {
        let date = json["date"].stringValue

        let distance = json["distance"].doubleValue
        let duration = json["duration"].doubleValue
        let idleDuration = json["idle_duration"].doubleValue
        let maxSpeed = json["max_speed"].doubleValue
        let tripCount = json["trip"].intValue
        let violationCount = json["violation"].intValue
        let score = json["score"].doubleValue
        
//        let dateText = TripSummaryMapper.dateFormatter.date(from: date)
//        if dateText == nil{
//            throw Error.invalidDateFormat
//        }
        
        throw Error.invalidDateFormat

//        return KTTripSummary(date: dateText!, distance: distance, duration: duration, idleDuration: idleDuration, maxSpeed: maxSpeed, tripCount: tripCount, violationCount: violationCount, score: score)
    }
}

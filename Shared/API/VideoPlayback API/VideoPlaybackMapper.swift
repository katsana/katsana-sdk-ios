//
//  VideoPlaybackMapper.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 19/08/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class VideoPlaybacksMapper{
    private init(){}
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse, vehicleId: Int) throws -> [VideoPlayback] {
        do{
            let json = try JSON(data: data)
            return try mapJSON(json, vehicleId: vehicleId)
        }
        catch{
            throw Error.invalidData
        }
    }
    
    public static func mapJSON(_ json: JSON, vehicleId: Int) throws -> [VideoPlayback] {
        let arr = json["vehicles"].arrayValue
        for vehicle in arr{
            if vehicleId == vehicle["id"].intValue{
                let playbacksJSON = vehicle["dvr"]["playback"].arrayValue
                return try playbacksJSON.map{try VideoPlaybackMapper.mapJSON($0)}
            }
        }
        return []
    }
}

public class VideoPlaybackMapper{
    public enum Error: Swift.Error {
        case invalidData
        case invalidDateFormat
    }
    
    public static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
    
    fileprivate static func mapJSON(_ json: JSON) throws -> VideoPlayback {
        let channelId = json["channel"].int
        let id = json["id"].int
        let userId = json["user_id"].int
        let deviceId = json["device_id"].int
        let vacronDeviceId = json["vacron_device_id"].string
        let filename = json["filename"].string
        let duration = json["duration"].floatValue
        let date = json["date"].stringValue
        let startTimeText = date + " " + json["start_time"].stringValue
        let endTimeText = date + " " + json["end_time"].stringValue
        let startTime = Self.dateFormatter.date(from: startTimeText)
        let endTime = Self.dateFormatter.date(from: endTimeText)
            
        guard let channelId, let id, let userId, let deviceId, let filename else{
            throw Error.invalidData
        }
        guard let endTime, let startTime else{
            throw Error.invalidDateFormat
        }
        
        let video = VideoPlayback(id: id, channelId: channelId, userId: userId, deviceId: deviceId, vacronDeviceId: vacronDeviceId, filename: filename, startTime: startTime, endTime: endTime, duration: duration)
        return video
    }
}

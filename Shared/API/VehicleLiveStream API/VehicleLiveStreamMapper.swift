//
//  VehicleLiveStreamMapper.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/08/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class VehicleLiveStreamsMapper{
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [VehicleLiveStream] {
        do{
            let json = try JSON(data: data)
            return try mapJSON(json)
        }
        catch{
            throw Error.invalidData
        }
    }
    
    public static func mapJSON(_ json: JSON) throws -> [VehicleLiveStream] {
        let arr = json["vehicles"].arrayValue
        let vehicles = try arr.map(VehicleLiveStreamMapper.mapJSON)
        return vehicles
    }
}

private class VehicleLiveStreamMapper{
    public enum Error: Swift.Error {
        case invalidData
    }
    
    fileprivate static func mapJSON(_ json: JSON) throws -> VehicleLiveStream {
        var theChannels = [VideoRecordingChannel]()
        let channels = json["dvr"]["channels"].dictionaryValue
        for (key, value) in channels {
            let theChannel = VideoRecordingChannel()
            theChannel.name = value["name"].string
            if let status = value["status"].string, status == "On"{
                theChannel.isOn = true
            }
            theChannel.identifier = key
            theChannels.append(theChannel)
        }
        theChannels.sort { a, b in
            if let id1 = a.identifier, let id2 = b.identifier{
                return id1 < id2
            }
            return false
        }
        
        let vehicleId = json["id"].int
        let url = json["dvr"]["liveStreamURL"].string
        
        var horizontalRatio: Int?
        var verticalRatio: Int?
        if let ratio = json["dvr"]["ratio"].arrayObject as? [Int], ratio.count > 1{
            horizontalRatio = ratio[0]
            verticalRatio = ratio[1]
        }
        
        if let vehicleId, let url{
            let video = VehicleLiveStream(vehicleId: vehicleId, url: url, horizontalRatio: horizontalRatio, verticalRatio: verticalRatio, channels: theChannels)
            return video
        }
        throw Error.invalidData
    }
}

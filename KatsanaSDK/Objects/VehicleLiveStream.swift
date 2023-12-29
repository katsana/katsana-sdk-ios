//
//  VideoRecording.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2022.
//  Copyright © 2022 pixelated. All rights reserved.
//

import Foundation

public class VehicleLiveStream: Codable, Equatable {
    enum CodingKeys: CodingKey {
        case vehicleId
        case horizontalRatio
        case verticalRatio
        case channels
        case url
    }
    
    public let vehicleId: Int
    public let url: String

    public let horizontalRatio: Int?
    public let verticalRatio: Int?
    public let channels: [VehicleLiveStreamChannel]
    
    public init(vehicleId: Int, url: String, horizontalRatio: Int? = nil, verticalRatio: Int? = nil, channels: [VehicleLiveStreamChannel]) {
        self.vehicleId = vehicleId
        self.url = url
        self.horizontalRatio = horizontalRatio
        self.verticalRatio = verticalRatio
        self.channels = channels
    }
    
    open func liveStreamURLTruncated() -> String!{
        if url.count > 15{
            let prefixURL = url.prefix(upTo: url.index(url.startIndex, offsetBy: 15)) + "..."
            return String(prefixURL)
        }else{
            return url
        }
    }
    
//    open func channelName(identifier: String) -> String!{
//        for channel in channels {
//            if let id = channel.identifier, identifier == id{
//                return channel.name
//            }
//        }
//        return nil
//    }
    
    public static func == (lhs: VehicleLiveStream, rhs: VehicleLiveStream) -> Bool {
        if lhs.vehicleId == rhs.vehicleId, lhs.url == rhs.url, lhs.channels == rhs.channels{
            return true
        }
        return false
    }
}

public struct VehicleLiveStreamChannel: Codable, Equatable{
    public let id: String
    public let name: String
    public let status: Bool
}

public class VehicleLiveStreamChannelURLTransformer{
    private init(){}
    
    public static func transformURL(from livestream: VehicleLiveStream, channel: VehicleLiveStreamChannel) -> URL{
        let url = livestream.url + "&channel=" + channel.id
        return URL(string: url)!
    }
}
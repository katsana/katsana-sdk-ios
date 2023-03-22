//
//  VideoRecording.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2022.
//  Copyright © 2022 pixelated. All rights reserved.
//


open class VideoRecording: Codable {
    enum CodingKeys: CodingKey {
        case id
        case horizontalRatio
        case verticalRatio
        case channels
        case liveStreamURL
    }
    
    open var id: String?
    open var horizontalRatio: Int?
    open var verticalRatio: Int?
    open var channels = [VideoRecordingChannel]()
    open var liveStreamURL: String?
    
    open func liveStreamURLTruncated() -> String!{
        if let url = liveStreamURL{
            if url.count > 15{
                let prefixURL = url.prefix(upTo: url.index(url.startIndex, offsetBy: 15)) + "..."
                return String(prefixURL)
            }else{
                return url
            }
        }
        return nil
    }
    
    open func channelName(identifier: String) -> String!{
        for channel in channels {
            if let id = channel.identifier, identifier == id{
                return channel.name
            }
        }
        return nil
    }
}

//
//  LiveShare.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutf Wan Md Hatta on 30/11/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//


public class LiveShare: NSObject {
    public var deviceId : String!
    public var userId : String!
    public var token : String!
    public var shareDescription: String!
    public var duration : Int = 0
    public var startAt : Date!
    public var endAt : Date!
    public var url : URL!
//    public var updatedAt : Date!
    public var createdAt : Date!
    public var shareId : String!
    
    override public class func fastCodingKeys() -> [Any]! {
        return ["deviceId", "userId", "token", "type", "shareDescription", "durationText", "startAt", "endAt", "updatedAt", "createdAt"]
    }
    
    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy / H:mm a"
        return formatter
    }()
    public func dateString() -> String {
        return dateFormatter.string(from: endAt)
    }
}

//{\"device_share\":{\"device_id\":105,\"user_id\":5,\"token\":\"DZKTmdXpGm\",\"type\":\"live\",\"description\":null,\"duration\":\"321i\",\"started_at\":\"2016-11-30 03:38:36\",\"ended_at\":\"2016-11-30 08:59:36\",\"updated_at\":\"2016-11-30 03:38:36\",\"created_at\":\"2016-11-30 03:38:36\",\"id\":76}}"	0x00007fded1e5e890

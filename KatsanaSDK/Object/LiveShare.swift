//
//  LiveShare.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutf Wan Md Hatta on 30/11/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//


open class LiveShare: NSObject {
    open var deviceId : String!
    open var userId : String!
    open var token : String!
    open var shareDescription: String!
    open var duration : Int = 0
    open var startAt : Date!
    open var endAt : Date!
    open var url : URL!
//    open var updatedAt : Date!
    open var createdAt : Date!
    open var shareId : String!
    
    override open class func fastCodingKeys() -> [Any]! {
        return ["deviceId", "userId", "token", "type", "shareDescription", "durationText", "startAt", "endAt", "updatedAt", "createdAt"]
    }
    
    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy / H:mm a"
        return formatter
    }()
    open func dateString() -> String {
        if let endAt = endAt {
            return dateFormatter.string(from: endAt)
        }else{
            return ""
        }
    }
}

//
//  TimeTransformer.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 02/02/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

@objcMembers
public class TimeTransformer: ValueTransformer {
    public var fullFormat = false
    
    override public class func allowsReverseTransformation() -> Bool{
        return false
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
        if let number = value as? NSNumber {
            let duration = number.floatValue
            var minutes = duration/60
            if (minutes > 60) {
                var hour = minutes/60.0
                minutes = (hour - floor(hour)) * 60
                hour = floor(hour)
                minutes = floor(minutes)
                
                var timeStr: String!
                if (hour >= 24) {
                    let day = hour/24
                    hour = (day - floor(day)) * 24
                    hour = ceil(hour)
                    timeStr = String(format:"%.0f day %.0f hours", day, hour)
                }else{
                    timeStr = String(format:"%.0f hr %.0f min", hour, minutes)
                    if (self.fullFormat) {
                        timeStr = String(format:"%.0f hour %.0f minutes", hour, minutes)
                    }
                }
                return timeStr;
            }else{
                var timeStr: String!
                if (minutes < 1) {
                    timeStr = String(format:"%.0f sec", minutes * 60)
                    if (self.fullFormat) {
                        timeStr = String(format:"%.0f seconds", minutes * 60)
                    }
                }else{
                    minutes = round(minutes);
                    timeStr = String(format:"%.0f min", minutes )
                    if (self.fullFormat) {
                        timeStr = String(format:"%.0f minutes", minutes )
                    }
                }
                
                return timeStr;
            }

        }
        return "0 min"
    }
}

//
//  TimeTransformer.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 02/02/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

@objcMembers
public class TimeTransformer: ValueTransformer {
    public var displayFormat = DisplayFormat.short
    
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
                if hour >= 24, displayFormat != .hourShort {
                    let day = hour/24
                    hour = (day - floor(day)) * 24
                    hour = ceil(hour)
                    timeStr = String(format: NSLocalizedString("%.0f day %.0f hours", comment: "") , day, hour)
                    if displayFormat == .hourOrMinuteOnly{
                        timeStr = String(format: NSLocalizedString("%.0f day", comment: "") , day)
                    }
                }else{
                    timeStr = String(format:NSLocalizedString("%.0f hr %.0f min", comment: ""), hour, minutes)
                    if displayFormat == .full {
                        timeStr = String(format:NSLocalizedString("%.0f hour %.0f minutes", comment: ""), hour, minutes)
                    }
                    else if displayFormat == .hourShort{
                        timeStr = String(format:NSLocalizedString("%.0f:%.0f hrs", comment: ""), hour, minutes)
                    }else if displayFormat == .hourOrMinuteOnly{
                        timeStr = String(format:NSLocalizedString("%.0f hr", comment: ""), hour)
                    }
                }
                return timeStr;
            }else{
                var timeStr: String!
                if (minutes < 1) {
                    timeStr = String(format:NSLocalizedString("%.0f sec", comment: ""), minutes * 60)
                    if displayFormat == .full {
                        timeStr = String(format:NSLocalizedString("%.0f seconds", comment: ""), minutes * 60)
                    }
                    else if displayFormat == .hourShort{
                        timeStr = String(format:NSLocalizedString("%.0f:%.0f hrs", comment: ""), 0, 0)
                    }
                }else{
                    minutes = round(minutes);
                    timeStr = String(format:NSLocalizedString("%.0f min", comment: ""), minutes )
                    if displayFormat == .full {
                        timeStr = String(format:NSLocalizedString("%.0f minutes", comment: ""), minutes )
                    }
                    else if displayFormat == .hourShort{
                        timeStr = String(format:NSLocalizedString("%.0f:%.0f hrs", comment: ""), 0, minutes)
                    }
                }
                
                return timeStr;
            }

        }
        return String(format:NSLocalizedString("%.0f min", comment: ""), 0)
    }
}

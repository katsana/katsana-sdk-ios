//
//  Date+Extension.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation

extension Date{
    static let timeDateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        let timezone = NSTimeZone.local
        formatter.timeZone = timezone
        formatter.dateFormat = "yyyy-MM-dd+HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let timeFormatter : DateFormatter = {
        let formatter = DateFormatter()
        let timezone = NSTimeZone.local
        formatter.timeZone = timezone
        formatter.dateFormat = "hh:mm:ss a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
//    2017/4/11+14:45:57
    
    public func toStringWithTime(includeSeconds: Bool = true) -> String {
        if includeSeconds{
            Date.timeFormatter.dateFormat = "hh:mm:ss a"
        }else{
            Date.timeFormatter.dateFormat = "hh:mm a"
        }
        return Date.timeFormatter.string(from: self)
    }
    
    public func toStringWithYearMonthDay() -> String {
        let dateComps = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let str = "\(dateComps.year!)/\(dateComps.month!)/\(dateComps.day!)"
        return str
    }
    
    public func toStringWithYearMonthDayAndTime(timezone: NSTimeZone! = nil) -> String {
        if let timezone = timezone {
            Date.timeDateFormatter.timeZone = timezone as Foundation.TimeZone
            Date.timeDateFormatter.dateFormat = "yyyy-MM-dd+HH:mm:ss"
        }
        return Date.timeDateFormatter.string(from: self)
    }
}

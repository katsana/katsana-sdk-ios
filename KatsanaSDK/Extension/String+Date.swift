//
//  String+Date.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation

extension String {
    
    public func date(gmt: Float) -> Date? {
        return Formatter.jsonDateFormatter(gmt: gmt).date(from: self)
    }
    
    public var date: Date? {
        get {
            return Formatter.jsonDateFormatter.date(from: self)
        }
    }
    
    public var dateWithoutTime: Date? {
        get {
            let text = Formatter.jsonDateWithoutTimeFormatter.date(from: self)
            return text
        }
    }
    
    public var dateWithoutTime2: Date? {
        get {
            let text = Formatter.jsonDateWithoutTimeFormatter2.date(from: self)
            return text
        }
    }
    
    public var dateTime: Date? {
        get {
            return Formatter.jsonDateTimeFormatter.date(from: self)
        }
    }
    
    public var dateTime2: Date? {
        get {
            return Formatter.jsonDateTimeFormatter2.date(from: self)
        }
    }
    
}

class Formatter {
    
    private static var internalJsonDateFormatter: DateFormatter?
    private static var internalJsonDateGMTFormatter: DateFormatter?
    private static var internalJsonDateWithoutTimeFormatter: DateFormatter?
    private static var internalJsonDateWithoutTimeFormatter2: DateFormatter?
    private static var internalJsonDateTimeFormatter: DateFormatter?
    private static var internalJsonDateTimeFormatter2: DateFormatter?
    
    static func jsonDateFormatter(gmt: Float) -> DateFormatter {
        if (internalJsonDateGMTFormatter == nil) {
            internalJsonDateGMTFormatter = DateFormatter()
            internalJsonDateGMTFormatter!.dateFormat = "yyyy-MM-dd HH:mm:ss"
            internalJsonDateGMTFormatter?.timeZone = Foundation.TimeZone(secondsFromGMT: 0)!
            internalJsonDateGMTFormatter!.locale = Locale(identifier: "en_US_POSIX")
            //            2013-11-18 03:31:02
        }
        internalJsonDateGMTFormatter?.timeZone = Foundation.TimeZone(secondsFromGMT: Int(gmt * 60*60))!
        return internalJsonDateGMTFormatter!
    }
    
    static var jsonDateFormatter: DateFormatter {
        if (internalJsonDateFormatter == nil) {
            internalJsonDateFormatter = DateFormatter()
            internalJsonDateFormatter!.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            //            2013-11-18 03:31:02
        }
        return internalJsonDateFormatter!
    }
    
    static var jsonDateFormatter2: DateFormatter {
        if (internalJsonDateFormatter == nil) {
            internalJsonDateFormatter = DateFormatter()
            internalJsonDateFormatter!.dateFormat = "yyyy-MM-dd hh:mm:ss"
            
            //            2013-11-18 03:31:02
        }
        return internalJsonDateFormatter!
    }
    
    static var jsonDateWithoutTimeFormatter: DateFormatter {
        if (internalJsonDateWithoutTimeFormatter == nil) {
            internalJsonDateWithoutTimeFormatter = DateFormatter()
            internalJsonDateWithoutTimeFormatter!.dateFormat = "yyyy-MM-dd"
            
            //            2013-11-18 03:31:02
        }
        return internalJsonDateWithoutTimeFormatter!
    }
    
    static var jsonDateWithoutTimeFormatter2: DateFormatter {
        if (internalJsonDateWithoutTimeFormatter2 == nil) {
            internalJsonDateWithoutTimeFormatter2 = DateFormatter()
            internalJsonDateWithoutTimeFormatter2!.dateFormat = "dd/MM/yyyy"
            
            //            2013-11-18 03:31:02
        }
        return internalJsonDateWithoutTimeFormatter2!
    }
    
    static var jsonDateTimeFormatter: DateFormatter {
        if (internalJsonDateTimeFormatter == nil) {
            internalJsonDateTimeFormatter = DateFormatter()
            internalJsonDateTimeFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        }
        return internalJsonDateTimeFormatter!
    }
    
    static var jsonDateTimeFormatter2: DateFormatter {
        if (internalJsonDateTimeFormatter2 == nil) {
            internalJsonDateTimeFormatter2 = DateFormatter()
            internalJsonDateTimeFormatter2!.dateFormat = "yyyy-MM-ddTHH:mm:ss.SSSZ"
        }
        return internalJsonDateTimeFormatter2!
    }
    
}

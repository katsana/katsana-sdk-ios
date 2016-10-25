//
//  JSON+Date.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

extension JSON {
    
    func date(gmt: Float) -> Date? {
        switch self.type {
        case .string:
            return Formatter.jsonDateFormatter(gmt: gmt).date(from: (self.object as! String))
        default:
            return nil
        }
    }
    
    public var date: Date? {
        get {
            switch self.type {
            case .string:
                return Formatter.jsonDateFormatter.date(from: (self.object as! String))
            default:
                return nil
            }
        }
    }
    
    public var dateWithoutTime: Date? {
        get {
            switch self.type {
            case .string:
                return Formatter.jsonDateWithoutTimeFormatter.date(from: (self.object as! String))
            default:
                return nil
            }
        }
    }
    
    public var dateTime: Date? {
        get {
            switch self.type {
            case .string:
                return Formatter.jsonDateTimeFormatter.date(from: self.object as! String)
            default:
                return nil
            }
        }
    }
    
}

class Formatter {
    
    private static var internalJsonDateFormatter: DateFormatter?
    private static var internalJsonDateGMTFormatter: DateFormatter?
    private static var internalJsonDateWithoutTimeFormatter: DateFormatter?
    private static var internalJsonDateTimeFormatter: DateFormatter?
    
    static func jsonDateFormatter(gmt: Float) -> DateFormatter {
        if (internalJsonDateGMTFormatter == nil) {
            internalJsonDateGMTFormatter = DateFormatter()
            internalJsonDateGMTFormatter!.dateFormat = "yyyy-MM-dd HH:mm:ss"
            internalJsonDateGMTFormatter?.timeZone = Foundation.TimeZone(secondsFromGMT: 0)!
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
    
    static var jsonDateWithoutTimeFormatter: DateFormatter {
        if (internalJsonDateWithoutTimeFormatter == nil) {
            internalJsonDateWithoutTimeFormatter = DateFormatter()
            internalJsonDateWithoutTimeFormatter!.dateFormat = "yyyy-MM-dd"
            
            //            2013-11-18 03:31:02
        }
        return internalJsonDateWithoutTimeFormatter!
    }
    
    static var jsonDateTimeFormatter: DateFormatter {
        if (internalJsonDateTimeFormatter == nil) {
            internalJsonDateTimeFormatter = DateFormatter()
            internalJsonDateTimeFormatter!.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        }
        return internalJsonDateTimeFormatter!
    }
    
}

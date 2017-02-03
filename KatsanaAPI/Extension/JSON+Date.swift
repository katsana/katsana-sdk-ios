//
//  JSON+Date.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation

extension JSON {
    
    public func date(gmt: Float) -> Date? {
        switch self.type {
        case .string:
            return (self.object as! String).date(gmt: gmt)
        default:
            return nil
        }
    }
    
    public var date: Date? {
        get {
            switch self.type {
            case .string:
                return (self.object as! String).date
            default:
                return nil
            }
        }
    }
    
    public var dateWithoutTime: Date? {
        get {
            switch self.type {
            case .string:
                return (self.object as! String).dateWithoutTime
            default:
                return nil
            }
        }
    }
    
    public var dateTime: Date? {
        get {
            switch self.type {
            case .string:
                return (self.object as! String).dateTime
            default:
                return nil
            }
        }
    }
    
}

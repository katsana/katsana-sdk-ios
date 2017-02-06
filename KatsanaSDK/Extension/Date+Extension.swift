//
//  Date+Extension.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation

extension Date{
    public func toStringWithYearMonthDay() -> String {
        let dateComps = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let str = "\(dateComps.year!)/\(dateComps.month!)/\(dateComps.day!)"
        return str
    }
}

//
//  TripSummaryEndpoint.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public enum TripSummaryEndpoint {
    case get(vehicleId: Int, fromDate: Date, toDate: Date)

    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(vehicleId, fromDate, toDate):
            var queryItems: [URLQueryItem]?
            queryItems = [URLQueryItem(name: "start", value: fromDate.toStringWithYearMonthDay()),
                          URLQueryItem(name: "end", value: toDate.toStringWithYearMonthDay())].compactMap { $0 }
            
            let urlString = baseURL.absoluteString + "/vehicles" + "\(vehicleId)" + "/summaries/duration"
            let url = URL(string: urlString)!
            
            let finalURL = URL.make(url: url, queryItems: queryItems)
            return finalURL!
        }
    }
}

public extension Date{
    func toStringWithYearMonthDay() -> String {
        let dateComps = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let str = "\(dateComps.year!)/\(dateComps.month!)/\(dateComps.day!)"
        return str
    }
}

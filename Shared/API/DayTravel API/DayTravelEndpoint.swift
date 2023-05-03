//
//  DayTravelEndpoint.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public enum DayTravelEndpoint {
    case get(vehicleId: Int, date: Date)

    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(vehicleId, date):
            var queryItems: [URLQueryItem]?
//            queryItems = [URLQueryItem(name: "start", value: date.toStringWithYearMonthDay())]
            
            let urlString = baseURL.absoluteString + "/vehicles" + "/\(vehicleId)" + "/travels/" + date.toStringWithYearMonthDay()
            let url = URL(string: urlString)!
            
            let finalURL = URL.make(url: url, queryItems: queryItems)
            return finalURL!
        }
    }
}

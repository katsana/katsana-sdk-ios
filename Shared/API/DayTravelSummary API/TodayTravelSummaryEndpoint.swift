//
//  TodayTravelSummaryEndpoint.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public enum TodayTravelSummaryEndpoint {
    case get(vehicleId: Int)

    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(vehicleId):
            var queryItems: [URLQueryItem]?
            
            let urlString = baseURL.absoluteString + "/vehicles" + "/\(vehicleId)" + "/summaries/today"
            let url = URL(string: urlString)!
            
            let finalURL = URL.make(url: url, queryItems: queryItems)
            return finalURL!
        }
    }
}

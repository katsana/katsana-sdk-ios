//
//  VehicleEndpoint.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 16/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public enum VehicleEndpoint {
    case get(vehicleId: Int? = nil, includes: [String]? = nil)

    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(vehicleId, includes):
            var queryItems: [URLQueryItem]?
            if let includes{
                queryItems = [URLQueryItem(name: "includes", value: includes.joined(separator: ","))].compactMap { $0 }
            }
            var url = URL.make(url: baseURL.appendingPathComponent("/vehicles"), queryItems: queryItems)!
            if let vehicleId{
                url = url.appendingPathComponent("/\(vehicleId)")
            }
            return url
        }
    }
}

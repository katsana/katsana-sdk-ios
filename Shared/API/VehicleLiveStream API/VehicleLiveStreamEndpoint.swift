//
//  VehicleLiveStreamEndpoint.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/08/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public enum VehicleLiveStreamsEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return URL.make(url: baseURL.appendingPathComponent("/operations/stream"), queryItems: nil)!
        }
    }
}

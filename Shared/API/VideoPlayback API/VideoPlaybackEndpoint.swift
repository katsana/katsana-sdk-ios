//
//  VideoPlaybackEndpoint.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 19/08/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public enum VideoPlaybackEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return URL.make(url: baseURL.appendingPathComponent("/operations/playback"), queryItems: nil)!
        }
    }
}

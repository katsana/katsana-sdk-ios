//
//  VideoPlaybackDataEndpoint.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 22/08/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public enum VideoPlaybackDataEndpoint {
    case get(playbackId: Int)

    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(playbackId):
            var url = URL.make(url: baseURL.appendingPathComponent("/operations/playback/\(playbackId)/download"), queryItems: nil)!
            return url
        }
    }
}

//
//  URL+QueryItems.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public extension URL{
    static func make(url: URL, queryItems: [URLQueryItem]? = nil) -> URL?{
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.path = url.path
        if let queryItems{
            components.queryItems = queryItems
        }
        return components.url
    }
}

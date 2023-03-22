//
//  UserEndpoint.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public enum UserProfileEndpoint {
    case get(includes: [String]? = nil)

    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(includes):
            var queryItems: [URLQueryItem]?
            if let includes{
                queryItems = [URLQueryItem(name: "includes", value: includes.joined(separator: ","))].compactMap { $0 }
            }
            let url = URL.make(url: baseURL.appendingPathComponent("/profile"), queryItems: queryItems)
            return url!
        }
    }
}



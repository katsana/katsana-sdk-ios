//
//  LoginEndpoint.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public enum LoginEndpoint {
//    case post(username: String, password: String, clientId: String, clientSecret: String, scope: String, grantType: String)
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            var queryItems: [URLQueryItem]?
            let urlString = baseURL.absoluteString + "/oauth/token"
            let url = URL(string: urlString)!
            
            let finalURL = URL.make(url: url, queryItems: queryItems)
            return finalURL!
        }
    }
}

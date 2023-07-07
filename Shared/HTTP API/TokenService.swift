//
//  TokenService.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public typealias AccessTokenResult = Swift.Result<AccessToken, Error>

public struct AccessToken: Equatable, Codable{
    public var name: String
    public let token: String
    
    public init(name:String, token: String) {
        self.name = name
        self.token = token
    }
}

public protocol TokenService{
    func getToken() -> AccessToken?
}

public protocol TokenCache {
    func save(token: AccessToken)
    func delete()
}


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
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
}

public protocol TokenService{
    func getToken(completion: @escaping (AccessTokenResult) -> Void)
}

public protocol TokenCache {
    typealias Result = Swift.Result<Void, Error>

    func save(user: String, token: AccessToken, completion: @escaping (Result) -> Void)
}


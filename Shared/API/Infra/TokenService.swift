//
//  TokenService.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public struct AccessToken: Equatable{
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
}

public protocol TokenService{
    typealias Result = Swift.Result<AccessToken, Error>
    
    func getToken(completion: @escaping (Result) -> Void)
}
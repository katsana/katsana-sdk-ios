//
//  KeychainTokenService.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class KeychainTokenService: TokenService{
    public var token: AccessToken?
    
    public enum Error: Swift.Error {
        case notFound
    }
    
    public func getToken(completion: @escaping (AccessTokenResult) -> Void) {
        if let token{
            completion(.success(token))
        }else{
            completion(.failure(Error.notFound))
        }
    }
}

//
//  KeychainTokenService.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class KeychainTokenService: TokenService, TokenCache{

    public enum Error: Swift.Error {
        case notFound
    }
    
    public func getToken(user: String) -> AccessToken? {
        if let token = UserDefaults.standard.value(forKey: user+"Token") as? String{
            return AccessToken(token: token)
        }
        return nil
    }
    
    public func save(user: String, token: AccessToken) {
        UserDefaults.standard.set(token.token, forKey: user+"Token")
    }
}

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
    
    public func getToken() -> AccessToken? {
        if let token = UserDefaults.standard.value(forKey: "Token") as? String, let tokenName = UserDefaults.standard.value(forKey: "TokenName") as? String{
            return AccessToken(name: tokenName, token: token)
        }
        return nil
    }
    
    public func save(token: AccessToken) {
        UserDefaults.standard.set(token.token, forKey: "Token")
        UserDefaults.standard.set(token.name, forKey: "TokenName")
    }
    
    public func delete() {
        UserDefaults.standard.removeObject(forKey: "Token")
        UserDefaults.standard.removeObject(forKey: "TokenName")

    }
}

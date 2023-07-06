//
//  LoginMapper.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class LoginMapper{
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public func map(_ data: Data, from response: HTTPURLResponse) throws -> AccessToken {
        do{
            let json = try JSON(data: data)
            return try mapJSON(json)
        }
        catch{
            throw Error.invalidData
        }
    }
    
    public func mapJSON(_ json: JSON) throws -> AccessToken {
        let token = json["access_token"].string
        let refreshToken = json["refresh_token"].string
        
        guard let token, let refreshToken else{
            throw Error.invalidData
        }
        return AccessToken(name: name, token: token)
    }
}

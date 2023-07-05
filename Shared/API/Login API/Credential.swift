//
//  LoginCredential.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public struct Credential{
    public let clientId: String
    public let clientSecret: String
    public let scope: String
    public let grantType: String
    
    public init(clientId: String, clientSecret: String, scope: String, grantType: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.scope = scope
        self.grantType = grantType
    }
    
    public func data() -> [String: String]{
        let dicto = ["client_id": clientId, "client_secret": clientSecret, "scope": scope, "grant_type": grantType]
//        let jsonData = try! JSONSerialization.data(withJSONObject: dicto, options: [])
        return dicto
    }
    
}

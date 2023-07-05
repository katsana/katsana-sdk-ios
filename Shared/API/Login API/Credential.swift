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
    
    func data() throws -> Data{
        let dicto = ["client_id": clientId, "client_secret": clientSecret, "scope": scope, "grant_type": grantType]
        let jsonData = try JSONSerialization.data(withJSONObject: dicto, options: .prettyPrinted)
        return jsonData
    }
    
}

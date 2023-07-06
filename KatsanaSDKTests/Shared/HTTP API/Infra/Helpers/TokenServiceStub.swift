//
//  TokenServiceStub.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import KatsanaSDK

class TokenServiceStub: TokenService{
    private let stub: AccessTokenResult
    
    init(stub: AccessTokenResult) {
        self.stub = stub
    }
    
    func getToken(user: String) -> AccessToken?{
        return try? stub.get()
    }
}

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
    private let stub: TokenService.Result
    
    init(stub: TokenService.Result) {
        self.stub = stub
    }
    
    func getToken(completion: @escaping (TokenService.Result) -> Void) {
        completion(stub)
    }
}

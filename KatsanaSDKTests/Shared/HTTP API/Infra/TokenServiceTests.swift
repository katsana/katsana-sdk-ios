//
//  TokenServiceTests.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

final class TokenServiceTests: XCTestCase {
    func test_get_failsOnFailure() {
        let sut = TokenServiceStub(stub: .failure(anyNSError()))
        XCTAssertEqual(sut.getToken(), nil)
    }
    
    func test_get_successOnSuccess() {
        let token = AccessToken(name: "any", token: "anytoken")
        
        let sut = TokenServiceStub(stub: .success(token))
        XCTAssertEqual(sut.getToken(), token)
    }
}

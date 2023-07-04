//
//  KatsanaAPITests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class KatsanaAPI{
    var isAuthenticated = false
    
    func login(email: String, password: String){
        isAuthenticated = true
    }
}

final class KatsanaAPITests: XCTestCase {
    
    func test_init_isNotAuthenticated() {
        let sut = makeSUT()
        
        XCTAssertTrue(!sut.isAuthenticated)
    }
    
    func test_login_authenticateWhenSuccess() {
        let sut = makeSUT()
        sut.login(email: "test", password: "1212")
        XCTAssertTrue(sut.isAuthenticated)
    }
    
    func makeSUT() -> KatsanaAPI{
        let sut = KatsanaAPI()
        return sut
    }
    
}

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
}

final class KatsanaAPITests: XCTestCase {
    
    func test_init_isNotAuthenticated() {
        let sut = makeSUT()
        
        XCTAssertTrue(!sut.isAuthenticated)
    }
    
    func makeSUT() -> KatsanaAPI{
        let sut = KatsanaAPI()
        return sut
    }
    
}

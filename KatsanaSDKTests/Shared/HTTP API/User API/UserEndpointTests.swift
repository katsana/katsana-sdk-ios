//
//  UserEndpointTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class UserEndpointTests: XCTestCase {
    
    func test_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = UserProfileEndpoint.get().url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/profile", "path")
    }
    
    func test_endpointURLGivenIncludes() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = UserProfileEndpoint.get(includes: ["plan", "company"]).url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/profile", "path")
        XCTAssertEqual(received.query?.contains("includes=plan,company"), true)
    }
    
}


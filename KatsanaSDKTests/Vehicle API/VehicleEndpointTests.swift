//
//  VehicleEndpointTests.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 16/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class VehicleEndpointTests: XCTestCase {
    
    func test_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = VehicleEndpoint.get().url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/vehicles", "path")
    }
    
    func test_endpointURLGivenIncludes() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = VehicleEndpoint.get(includes: ["features", "tags"]).url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/vehicles", "path")
        XCTAssertEqual(received.query?.contains("includes=features,tags"), true)
    }
    
    func test_endpointURL_withVehicleId() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = VehicleEndpoint.get(vehicleId: 50).url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/vehicles/50", "path")
    }
    
    func test_endpointURLGivenIncludes_withVehicleId() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = VehicleEndpoint.get(vehicleId: 50, includes: ["features"]).url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/vehicles/50", "path")
        XCTAssertEqual(received.query?.contains("includes=features"), true)
    }
    
}



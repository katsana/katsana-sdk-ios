//
//  TodayTravelSummaryEndpointTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class TodayTravelSummaryEndpointTests: XCTestCase {
    
    func test_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!

        let received = TodayTravelSummaryEndpoint.get(vehicleId: 1).url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/vehicles" + "/\(1)" + "/summaries/today", "path")
    }
    
}


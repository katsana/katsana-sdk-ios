//
//  TripSummaryEndpointTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class TripSummaryEndpointTests: XCTestCase {
    
    func test_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = TripSummaryEndpoint.get(vehicleId: 1, fromDate: Date().dateByAddingDays(-1), toDate: Date()).url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/vehicles" + "/\(1)" + "/summaries/duration", "path")
    }
    
    
    func test_endpointURL_withStartAndEndDate() {
        let baseURL = URL(string: "http://base-url.com")!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        let startDate = formatter.date(from: "2023/4/11")!
        let endDate = formatter.date(from: "2023/4/12")!

        let received = TripSummaryEndpoint.get(vehicleId: 1, fromDate: startDate, toDate: endDate).url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/vehicles" + "/\(1)" + "/summaries/duration", "path")
        XCTAssertEqual(received.query?.contains("start=2023/4/11"), true)
        XCTAssertEqual(received.query?.contains("end=2023/4/12"), true)

    }
    
}



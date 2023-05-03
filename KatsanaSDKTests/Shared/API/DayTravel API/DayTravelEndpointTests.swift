//
//  DayTravelEndpointTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class DayTravelEndpointTests: XCTestCase {
    
    func test_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let date = formatter.date(from: "2023/4/11")!

        let received = DayTravelEndpoint.get(vehicleId: 1, date: date).url(baseURL: baseURL)
        
        XCTAssertEqual(received.scheme, "http", "scheme")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/vehicles" + "/\(1)" + "/travels/2023/4/11", "path")
    }
    
}



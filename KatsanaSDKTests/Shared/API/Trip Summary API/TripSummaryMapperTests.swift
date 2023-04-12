//
//  TripSummaryMapperTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK

class TripSummaryMapperTests: XCTestCase {

    func test_map_deliversItemsOn2XXHTTPResponseWithJSONItems() throws {
        let json = makeTripSummary()
        let data = try! JSONSerialization.data(withJSONObject: json)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let date = formatter.date(from: "2023-01-09")!

        let result = try TripSummariesMapper.map(data, from: HTTPURLResponse(statusCode: 200)).first!

        XCTAssertEqual(result.date, date)
        XCTAssertEqual(result.distance, 2500)
        XCTAssertEqual(result.duration, 480)
        XCTAssertEqual(result.idleDuration, 630)
        XCTAssertEqual(result.maxSpeed, 90)
        XCTAssertEqual(result.tripCount, 5)
        XCTAssertEqual(result.violationCount, 10)
        XCTAssertEqual(result.score, 100)
    }
    
    // MARK:  Helper
    
    func makeTripSummary() -> [Any]{
        let text = """
[{"date":"2023-01-09","distance":2500,"duration":480,"idle_duration":630,"max_speed":90,"trip":5,"violation":10,"score":100}]
"""
        
        let json = try! convertStringToArray(text: text)
//        json["fleets"] = fleetsDicto
        return  json
    }
    
}

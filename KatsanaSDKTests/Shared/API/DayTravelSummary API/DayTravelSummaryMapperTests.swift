//
//  DayTravelSummaryMapperTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK

class DayTravelSummaryMapperTests: XCTestCase {

    func test_map_deliversItemsOn2XXHTTPResponseWithJSONItems() throws {
        let date = "2023-05-03"
        
        let json = makeDayTravelSummary(date: date)
        let data = try! JSONSerialization.data(withJSONObject: json)

        let result = try DayTravelSummaryMapper.map(data, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result.date, try! DayTravelSummaryMapper.dateFromString(date))
        XCTAssertEqual(result.distance, 100)
        XCTAssertEqual(result.duration, 66)
        XCTAssertEqual(result.idleDuration, 5)
        XCTAssertEqual(result.maxSpeed, 78)
        XCTAssertEqual(result.tripCount, 5)
        XCTAssertEqual(result.violationCount, 2)
        XCTAssertEqual(result.score, 99)

    }
    
    func makeDayTravelSummary(date: String) -> Any{
        let text = """
{"date": "\(date)",
"distance":100,
"duration":66,
"idle_duration":5,
"max_speed":78,
"trip":5,
"violation":2,
"score":99}
"""
        let json = try! convertStringToDictionary(text: text)

        return json
    }

}

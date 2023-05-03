//
//  DayTravelMapperTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK

class DayTravelMapperTests: XCTestCase {

    func test_map_deliversItemsOn2XXHTTPResponseWithJSONItems() throws {
        let json = makeDayTravel()
        let data = try! JSONSerialization.data(withJSONObject: json)

        let result = try DayTravelMapper.map(data, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result.distance, 10000)
        XCTAssertEqual(result.duration, 50)
        XCTAssertEqual(result.idleDuration, 30)
        XCTAssertEqual(result.maxSpeed, 53)
        XCTAssertEqual(result.trips.count, 1)
    }
    
    func makeDayTravel() -> Any{
        let startDate = "2022-11-17 02:28:11"
        let text = """
{
  "trips": [\(makeTripJSON(startDate: startDate))],
  "summary": {
    "max_speed": 53,
    "distance": 10000,
    "violation": 0
  },
  "duration": {
    "from": "2022-11-16 16:00:00",
    "to": "2022-11-17 15:59:59"
  }
}
"""
        let json = try! convertStringToDictionary(text: text)

        return json
    }

}

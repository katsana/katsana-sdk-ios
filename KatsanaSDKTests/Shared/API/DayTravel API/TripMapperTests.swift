//
//  TripMapperTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK

class TripMapperTests: XCTestCase {

    func test_map_deliversItemsOn2XXHTTPResponseWithJSONItems() throws {
        let startDate = "2022-11-17 02:28:11"
        let json = makeTrip(startDate: startDate)
        let data = try! JSONSerialization.data(withJSONObject: json)
        

        let result = try TripMapper.map(data, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result.startDate(), startDate.date(gmt: 0))
        XCTAssertEqual(result.distance, 100)
        XCTAssertEqual(result.duration, 50)
        XCTAssertEqual(result.idleDuration, 30)
        XCTAssertEqual(result.maxSpeed, 90)
        XCTAssertEqual(result.locations.count, 4)
        XCTAssertEqual(result.idles.count, 1)
        XCTAssertEqual(result.start.latitude, 3.1)
        XCTAssertEqual(result.start.longitude, 102.2)

        XCTAssertEqual(result.score, 99)
    }

}

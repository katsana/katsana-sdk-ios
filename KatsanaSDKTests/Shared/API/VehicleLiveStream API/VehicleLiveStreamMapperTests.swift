//
//  VehicleLiveStreamMapperTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/08/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK

class VehicleLiveStreamMapperTests: XCTestCase {

    func test_map_deliversItemsOn2XXHTTPResponseWithJSONItems() throws {
        let data = makeVehicleLiveStreams()

        let result = try VehicleLiveStreamsMapper.map(data, from: HTTPURLResponse(statusCode: 200))

        let first = result.first!
        
        XCTAssertEqual(first.vehicleId, 10)
        XCTAssertEqual(first.url, "https://live.anystream.com")
        XCTAssertEqual(first.horizontalRatio, 16)
        XCTAssertEqual(first.verticalRatio, 9)
        XCTAssertEqual(first.channels.count, 2)
        XCTAssertEqual(first.channels.first?.id, "1")
        XCTAssertEqual(first.channels.first?.name, "Road View")
        XCTAssertEqual(first.channels.first?.status, true)
    }
    
    // MARK:  Helper
    
    func makeVehicleLiveStreams() -> Data{
        let text = """
{
  "vehicles": [
    {
      "id": 10,
      "plate_number": "ABC123",
      "description": "Focus",
      "avatar": "https://katsana-carbon.s3.ap-southeast-1.amazonaws.com/pictures/device-489/6d1c304c-158c-11ed-b7d3-822132d3340c.thumb.jpg",
      "state": "offline",
      "dvr": {
        "channels": {
          "1": {
            "name": "Road View",
            "status": "On"
          },
          "2": {
            "name": "Cabin View",
            "status": "On"
          }
        },
        "ratio": [16, 9],
        "liveStreamURL": "https://live.anystream.com"
      }
    },
    {
      "id": 1024,
      "plate_number": "VJK 857",
      "description": "EV Kona Gentari - VJK 857",
      "avatar": "https://carbon.api.katsana.com/pictures/default.jpg",
      "state": "offline",
      "dvr": {
        "channels": {
          "1": {
            "name": "Front",
            "status": "On"
          },
          "2": {
            "name": "Rear",
            "status": "On"
          }
        },
        "ratio": [4, 3],
        "liveStreamURL": "https://live.katsana.com/embed.html?deviceid=ST011620&user=admin&password=99EE657EE2E45C3C8D7EB8CCF9277D5D722B966A7742416FBC06E24E4AE8303B&type=live"
      }
    }
  ],
  "datetime": "2023-07-31T04:45:38.702594Z"
}
"""
        
        return text.data(using: .utf8)!
    }
    
}

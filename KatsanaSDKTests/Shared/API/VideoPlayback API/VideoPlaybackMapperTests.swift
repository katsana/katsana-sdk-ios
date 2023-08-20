//
//  VideoPlaybackMapperTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 20/08/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK

class VideoPlaybackMapperTests: XCTestCase {

    func test_map_deliversItemsOn2XXHTTPResponseWithJSONItems() throws {
        let data = makeVehiclePlaybacks()

        let result = try VideoPlaybacksMapper.map(data, from: HTTPURLResponse(statusCode: 200), vehicleId: 10)
        
        let startTimeText = "2022-10-17 23:43:10"
        let endTimeText = "2022-10-17 23:43:25"
        XCTAssertEqual(result.count, 1)
        let first = result.first!
        XCTAssertEqual(first.id, 16)
        XCTAssertEqual(first.filename, "anyFilename.mp4")
        XCTAssertEqual(first.channelId, 5)
        XCTAssertEqual(first.deviceId, 10)
        XCTAssertEqual(first.vacronDeviceId, "VACRON_ID")
        XCTAssertEqual(first.startTime, VideoPlaybackMapper.dateFormatter.date(from: startTimeText))
        XCTAssertEqual(first.endTime, VideoPlaybackMapper.dateFormatter.date(from: endTimeText))
    }
    
    // MARK:  Helper
    
    func makeVehiclePlaybacks() -> Data{
        let text = """
{
  "vehicles": [
    {
      "id": 10,
      "plate_number": "ABC123",
      "description": "Focus",
      "avatar": "https://anyurl.com/thumb.jpg",
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
        "liveStreamURL": null,
        "playback": [
          {
            "filename": "anyFilename.mp4",
            "channel": 5,
            "date": "2022-10-17",
            "start_time": "23:43:10",
            "end_time": "23:43:25",
            "duration": 15,
            "device_id": 10,
            "vacron_device_id": "VACRON_ID",
            "user_id": 150,
            "id": 16,
            "status": "downloaded",
            "file_size": {
              "size": 372.57,
              "unit": "KB",
              "raw": 381514
            }
          }
        ]
      }
    },
    {
      "id": 11,
      "plate_number": "BAA611",
      "description": "EV Kona Gentari",
      "avatar": "https://anyurl.com/pictures/default.jpg",
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
        "liveStreamURL": null,
        "playback": []
      }
    }
  ],
  "datetime": "2023-07-31T07:44:25.082622Z"
}
"""
        
        return text.data(using: .utf8)!
    }
    
}

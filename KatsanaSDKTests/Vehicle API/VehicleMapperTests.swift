//
//  VehicleMapperTests.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 16/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK

class VehicleMapperMapperTests: XCTestCase {

    func test_map_deliversItemsOn2XXHTTPResponseWithJSONItems() throws {
        let json = makeVehicle()
        let data = makeJSON(json)

        let result = try VehicleMapper.map(data, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result.vehicleId, 10)
        XCTAssertEqual(result.websocketSupported, true)
        XCTAssertEqual(result.fleetIds.count, 3)
        XCTAssertEqual(result.features!.count, 2)
        XCTAssertEqual(result.imei, "anyImei")
        XCTAssertEqual(result.features!.count, 2)
        XCTAssertEqual(result.imageURL, "https://www.avatar.jpg")
    
        XCTAssertEqual(result.current!.latitude, 3.009)
        XCTAssertEqual(result.current!.longitude, 101.758)
        XCTAssertEqual(result.current!.state, "stopped")
        XCTAssertEqual(result.odometer, 192488)
        
        XCTAssertEqual(result.temperatureSensor!.value, 29)
        XCTAssertEqual(result.temperatureSensor!.status, "normal")
        XCTAssertNil(result.fuelSensor)
        
        XCTAssertEqual(result.sensors!.first!.name, "PAX")
    }
    
    // MARK:  Helper
    
    func makeVehicle() -> [String: Any]{
        let text = """
{
  "id": 10,
  "user_id": 16,
  "imei": "anyImei",
  "description": "Focus",
  "vehicle_number": "ABC1575",
  "manufacturer": "Ford",
  "model": "Focus",
  "meta": {
    "today": {
      "date": "2023-03-12",
      "max_speed": 16.738667
    },
    "latest": {
      "latitude": 3.0090849,
      "longitude": 101.7582616,
      "speed": 0,
      "state": "stopped",
      "ignition": 0,
      "voltage": 12332,
      "battery": 88,
      "gsm": 3,
      "tracked_at": "2023-03-16 02:53:44"
    },
    "websocket": true
  },
  "mode": "working",
  "current": {
    "latitude": 3.009,
    "longitude": 101.758,
    "speed": 0,
    "state": "stopped",
    "ignition": 0,
    "voltage": 12332,
    "battery": 88,
    "gsm": 3,
    "tracked_at": "2023-03-16 02:53:44"
  },
  "avatar": "https://www.avatar.jpg",
  "marker": "https://www.thumb.jpg",
  "today_max_speed": 16.738667,
  "odometer": 192488,
  "ends_at": "2037-12-31 16:00:00",
  "timezone": "Asia/Kuala_Lumpur",
  "profile": {
    "id": 478,
    "device_id": 489,
    "license_plate": "WYU1575-2",
    "vin_number": null,
    "engine_number": null,
    "manufacturer": "Ford",
    "vehicle_type": 1,
    "model": "Focus",
    "category": "motorcycle",
    "color": null,
    "year": null,
    "fuel_capacity": 0,
    "fuel_type": null,
    "insured_by": "Takaful Malaysia",
    "insured_expiry": "2019-12-31T00:00:00.000000Z",
    "score": 69.41,
    "meta": {
      "score": {
        "harsh_brake": 94.49977643933616,
        "harsh_corner": 73.5705846768891,
        "harsh_accelerate": 96.63103022014151,
        "speed": 83.24563846401489
      }
    },
    "created_at": "2018-03-14T14:29:12.000000Z",
    "updated_at": "2022-12-21T03:30:45.000000Z",
    "deleted_at": null
  },
  "plan": {
    "name": "",
    "expiry_date": "",
    "renewal_amount": ""
  },
  "features": [
    "immobilizer",
    "temperature"
  ],
  "insured": {
    "by": "Takaful Malaysia",
    "expiry": "2019-12-31"
  },
  "earliest_date": "2022-03-16",
  "fuel_percentage": null,
  "fleets": [
    4,
    10,
    3
  ],
  "sensors": {
    "fuel": null,
    "temperature": {
      "value": 29,
      "status": "normal"
    },
    "seatbelts": null,
    "others": [
      {
        "sensor": "Door",
        "name": "PAX",
        "type": "NC",
        "input": 3,
        "value": false,
        "event": "close"
      }
    ],
    "outputs": [
      {
        "sensor": "Relay",
        "config": "remote-immobilizer",
        "command-on": "setdigout ?1 ? 0",
        "command-off": "setdigout ?0 ? 0",
        "output": 2,
        "state": null
      }
    ]
  }
}
"""
        
        var json = convertStringToDictionary(text: text)!
//        json["fleets"] = fleetsDicto
        return  json
    }
    
}

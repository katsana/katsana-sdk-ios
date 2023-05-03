//
//  Trip+Helpers.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

func makeTrip(startDate: String) -> Any{

    let json = try! convertStringToDictionary(text: makeTripJSON(startDate: startDate))
//        json["fleets"] = fleetsDicto
    return  json
}

func makeTripJSON(startDate: String) -> String{
    let text = """
{
  "id": 5,
  "start": {
    "id": 634113,
    "latitude": 3.1,
    "longitude": 102.2,
    "odometer": 191304,
    "tracked_at": "\(startDate)"
  },
  "end": {
    "id": 634208,
    "latitude": 3.0813583,
    "longitude": 101.73286,
    "odometer": 191317,
    "tracked_at": "2022-11-17 02:54:34"
  },
  "distance": 100,
  "duration": 50,
  "max_speed": 90,
  "average_speed": 21.473072073913045,
  "idle_duration": 30,
  "score": 99,
  "idles": [
    {
      "id": 634113,
      "latitude": 3.0090999,
      "longitude": 101.7583183,
      "tracked_at": "2022-11-17 02:28:11"
    }
  ],
  "histories": [
    {
      "id": 634126,
      "latitude": 3.0083233,
      "longitude": 101.76094,
      "tracked_at": "2022-11-17 02:32:31",
      "speed": 20.518366
    },
    {
      "id": 634127,
      "latitude": 3.010865,
      "longitude": 101.7609783,
      "tracked_at": "2022-11-17 02:32:51",
      "speed": 23.758108
    },
    {
      "id": 634128,
      "latitude": 3.0125016,
      "longitude": 101.7608499,
      "tracked_at": "2022-11-17 02:33:11",
      "speed": 16.19871
    },
    {
      "id": 634129,
      "latitude": 3.0129283,
      "longitude": 101.760895,
      "tracked_at": "2022-11-17 02:33:17",
      "speed": 11.879054
    }]
}
"""
    return text
}

//
//  VehicleMapperTests.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 16/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class VehicleMapperMapperTests: XCTestCase {

    func test_map_deliversItemsJSONItems() throws {
        let fleet = Fleet(fleetId: 2, name: "Main Fleet", deviceCount: 10)
        let fleet2 = Fleet(fleetId: 6, name: "Secondary Fleet", deviceCount: 2)
        
        let (item, json) = makeUser(id: 220, email: "developer-demo@katsana.com", fleets: [fleet, fleet2])
        let data = makeJSON(json)

        let result = try UserMapper.map(data, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, item)
    }
    
    // MARK:  Helper
    
//    func makeVehicle(id: Int,
//                     imei: String,
//                     vehicleNumber: String,
//                          imageURL: String = "null",
//                          plan: UserPlan? = nil,
//                          fleets: [Fleet] = [],
//                          createdAt: String = "2019-11-05 04:47:52",
//                  updatedAt: String? = "2019-11-05 04:47:52") -> (model: KTUser, json: [String: Any]) {
//        
//        let item = KTUser(userId: "\(id)", email: email, imageURL: imageURL, plan: plan, company: nil, fleets: fleets, createdAt: createdAt.date(gmt: 0)!, updatedAt: updatedAt?.date(gmt: 0))
//        
//    }
    
}

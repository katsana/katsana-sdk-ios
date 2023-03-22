//
//  UserMapperTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class UserMapperMapperTests: XCTestCase {

    func test_map_deliversItemsOn2XXHTTPResponseWithJSONItems() throws {
        let fleet = Fleet(fleetId: 2, name: "Main Fleet", deviceCount: 10)
        let fleet2 = Fleet(fleetId: 6, name: "Secondary Fleet", deviceCount: 2)
        
        let (item, json) = makeUser(id: 220, email: "developer-demo@katsana.com", fleets: [fleet, fleet2])
        let data = makeJSON(json)

        let result = try UserMapper.map(data, from: HTTPURLResponse(statusCode: 200))
        let result2 = try UserMapper.map(data, from: HTTPURLResponse(statusCode: 201))

        XCTAssertEqual(result, item)
        XCTAssertEqual(result2, item)
    }
    
}

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
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeJSON([:])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try UserMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)

        XCTAssertThrowsError(
            try UserMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }


    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
        let fleet = Fleet(fleetId: 2, name: "Main Fleet", deviceCount: 10)
        let fleet2 = Fleet(fleetId: 6, name: "Secondary Fleet", deviceCount: 2)
        
        let (item, json) = makeUser(id: 220, email: "developer-demo@katsana.com", fleets: [fleet, fleet2])
        let data = makeJSON(json)

        let result = try UserMapper.map(data, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, item)
    }
    
    // MARK: - Helpers
        

    
}

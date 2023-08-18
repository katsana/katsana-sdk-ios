//
//  ActivityTest.swift
//  KatsanaSDKmacOSTests
//
//  Created by Wan Ahmad Lutfi on 01/02/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK
import CoreLocation

final class ActivityTest: XCTestCase {
    func test_createActivities_setProperly() throws {
        let sut = makeSUT()
        let activity = OldVehicleActivity()
        activity.type = .batteryCutoff
        activity.message = "test message"
        
        sut.cache(activity: activity, userId: "1")
        let activities = sut.vehicleActivities(userId: "1")
        let activities2 = sut.vehicleActivities(userId: "2")
        XCTAssertEqual(activities!.first!.type, .batteryCutoff)
        XCTAssertNil(activities2)
        sut.clearCache()
    }
    
    func test_createActivities_cachedProperly() throws {
        let sut = makeSUT()
        let activity = OldVehicleActivity()
        activity.type = .batteryCutoff
        activity.message = "test message"
        
        sut.cache(activity: activity, userId: "1")
        let activities = sut.loadCachedActivities()
        XCTAssertEqual(activities?["1"]?.first?.message, "test message")
        sut.clearCache()
    }
    
    func test_createAddress_cachedProperly() throws {
//        let sut = makeSUT()
//        let address = KTAddress(latitude: 10, longitude: 20)
//        address.streetName = "PT3000"
//
//        sut.cache(address: address)
//
//        XCTAssertEqual(sut.loadCachedAddresses().first!.streetName, "PT3000")
    }
    
    func makeSUT() -> KTCacheManager{
        return KTCacheManager()
    }

}

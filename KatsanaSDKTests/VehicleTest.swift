//
//  VehicleTest.swift
//  KatsanaSDKmacOSTests
//
//  Created by Wan Ahmad Lutfi on 31/01/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK
import URLMock
import Siesta

final class VehicleTest: XCTestCase {
    var service: Service!
    var cache: CacheManagerSpy!
    static var tempVehicles: [KTVehicle]!
    
    override class func setUp() {
        UMKMockURLProtocol.enable()
        UMKMockURLProtocol.setVerificationEnabled(true)
    }
    
    override class func tearDown() {
        UMKMockURLProtocol.setVerificationEnabled(false)
        UMKMockURLProtocol.disable()
        VehicleTest.tempVehicles = nil
    }

    override func setUp() {
        service = MockService.service()
    }

    func test_requestVehicles() throws {
        let sut = makeSUT(cache: CacheManagerSpy())
        let expectation = XCTestExpectation(description: "Request vehicles successfully")
        requestVehiclesWithSuccess(api: sut) { vehicles in
            XCTAssertEqual(vehicles.count > 0, true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_vehicleCurrentLocationCorrect() throws {
        let sut = makeSUT(cache: CacheManagerSpy())
        let expectation = XCTestExpectation(description: "Request locations successfully")
        requestVehiclesWithSuccess(api: sut) { vehicles in
            let first = vehicles.first!
            XCTAssertEqual(first.current!.latitude, 3)
            XCTAssertEqual(first.current!.longitude, 100)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_vehicleWebsocket_isTrue() throws {
        let sut = makeSUT(cache: CacheManagerSpy())
        let expectation = XCTestExpectation(description: "Request websocket successfully")
        requestVehiclesWithSuccess(api: sut) { vehicles in
            let first = vehicles.first!
            XCTAssertEqual(first.websocketSupported, true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_requestUser_currentVehiclesIsSet() throws {
        let sut = makeSUT(cache: CacheManagerSpy())
        let expectation = XCTestExpectation(description: "Current vehicles is set")
        requestVehiclesWithSuccess(api: sut) { vehicles in
            XCTAssertEqual(vehicles, sut.vehicles)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
//
    func test_requestUser_lastUserCachedEqual() throws {
        let cache = CacheManagerSpy()
        let sut = makeSUT(cache: cache)
        let expectation = XCTestExpectation(description: "Request user, last user set properly")
        requestVehiclesWithSuccess(api: sut) { vehicles in
            
            XCTAssertEqual(vehicles.first?.imei, cache.vehicles(userId: "0")?.first?.imei)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
//
    func test_requestUser_userCachedCorrectlyFromDisk() throws {
        let cache = CacheManagerSpy(writeToDisk: true)
        let sut = makeSUT(cache: cache)

        let expectation = XCTestExpectation(description: "Request user, user cached properly")
        requestVehiclesWithSuccess(api: sut) { vehicles in
            let cachedVehicles = cache.loadCachedVehicles()
            XCTAssertNotNil(vehicles)
            XCTAssertEqual(vehicles.first?.imei, cachedVehicles?.first?.imei)
            cache.clearCache()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    
    func makeSUT(cache: CacheManagerSpy) -> KatsanaAPI_Old{
        let api = KatsanaAPI_Old(cache: cache)
        api.API = service
        api.authToken = "testToken"
        api.configure()
        api.setupTransformer()
        return api
    }
    
    func requestVehiclesWithSuccess(api: KatsanaAPI_Old, completion: @escaping ([KTVehicle]) -> Void){
        MockService.mockResponse(path: "vehicles", expectedResponse: ["devices": [["id":489,"user_id":81,"imei":"123456","description":"Focus","vehicle_number":"ABC123","manufacturer":"Ford","model":"Focus", "meta": ["today":["date":"2023-01-12","max_speed":60], "websocket":true], "current": ["latitude":3,"longitude":100,"speed":0,"state":"stopped","ignition":0,"voltage":13052,"battery":91,"gsm":4,"tracked_at":"2023-01-12 07:46:37"]]]])
        
        //Using MockService have small delay, so if there already data, we just return temp vehicles
//        if VehicleTest.tempVehicles != nil{
//            completion(VehicleTest.tempVehicles)
//            return
//        }
        
        api.requestAllVehicles(options: nil) { vehicles in
//            VehicleTest.tempVehicles = vehicles
            completion(vehicles!)
        } failure: { error in
            XCTFail(error?.userMessage ?? "Error")
        }
    }
}

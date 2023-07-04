//
//  TripTest.swift
//  KatsanaSDKmacOSTests
//
//  Created by Wan Ahmad Lutfi on 31/01/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK
import URLMock
import Siesta

final class TripSummaryTest: XCTestCase {
    var service: Service!
    static var cache: CacheManagerSpy!
    
    override class func setUp() {
        UMKMockURLProtocol.enable()
        UMKMockURLProtocol.setVerificationEnabled(true)
        TripSummaryTest.cache = CacheManagerSpy(writeToDisk: true)
    }
    
    override class func tearDown() {
        UMKMockURLProtocol.setVerificationEnabled(false)
        UMKMockURLProtocol.disable()
        VehicleTest.tempVehicles = nil
        TripSummaryTest.cache.clearCache()
        TripSummaryTest.cache = nil
    }

    override func setUp() {
        service = MockService.service()
    }

//    func test_requestTripSummaries() throws {
//        let sut = makeSUT()
//        let expectation = XCTestExpectation(description: "Request trips summaries successfully")
//        requestTripsWithSuccess(api: sut) { vehicles in
//            XCTAssertEqual(vehicles.count > 0, true)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 0.1)
//    }
//    
//    func test_vehicleCurrentLocationCorrect() throws {
//        let sut = makeSUT()
//        let expectation = XCTestExpectation(description: "Request trips summaries successfully")
//        requestTripsWithSuccess(api: sut) { vehicles in
//            let first = vehicles.first!
//            XCTAssertEqual(first.distance, 40098)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 0.1)
//    }
//    
//    func test_requestTrips_isEqualToLatestTrips() throws {
//        let sut = makeSUT()
//
//        let expectation = XCTestExpectation(description: "Request user, user cached properly")
//        requestTripsWithSuccess(api: sut) { vehicles in
//            let cachedTravels = TripSummaryTest.cache!.latestTravels(vehicleId: 1, count: 1)
//            XCTAssertEqual(cachedTravels?.first!.distance, 40098)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 0.1)
//    }
//
//    func test_requestTrips_tripsCachedCorrectlyFromDisk() throws {
//        let cache = CacheManagerSpy(writeToDisk: true)
//        let sut = makeSUT()
//
//        let expectation = XCTestExpectation(description: "Request user, user cached properly")
//        requestTripsWithSuccess(api: sut) { vehicles in
//            let cachedTravels = cache.loadCachedTrips()
//            XCTAssertEqual(cachedTravels?.first!.distance, 40098)
//            cache.clearCache()
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 0.1)
//    }
    
    
    func makeSUT() -> KatsanaAPI_Old{
        let api = KatsanaAPI_Old(cache: TripSummaryTest.cache)
        api.API = service
        api.authToken = "testToken"
        api.configure()
        api.setupTransformer()
        return api
    }
    
    func requestTripsWithSuccess(api: KatsanaAPI_Old, completion: @escaping ([KTTrip]) -> Void){
        MockService.mockResponse(path: "vehicles/1/travels/summaries/duration?start=1970-01-01+07:30:10&end=1970-01-01+07:31:40", expectedResponse: [["date":"2023-01-10","distance":40098,"duration":5641,"idle_duration":1787,"max_speed":62.095055,"trip":5,"violation":0,"score":66]])
        
        let date = Date(timeIntervalSince1970: 10)
        let date2 = Date(timeIntervalSince1970: 100)
        
        api.requestTripSummaries(vehicleId: 1, fromDate: date, toDate: date2) { summaries in
            completion(summaries!)
        } failure: { error in
            XCTFail(error?.userMessage ?? "Error")
        }
    }
}

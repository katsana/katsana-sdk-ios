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

final class TripTest: XCTestCase {
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

    func test_requestTravelDay() throws {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Request travels successfully")
        requestTravelsWithSuccess(api: sut) { vehicles in
            XCTAssertEqual(vehicles.trips.count > 0, true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_requestTravelDay_locationsParsedCorrectly() throws {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Request travels successfully")
        requestTravelsWithSuccess(api: sut) { vehicles in
            let trip = vehicles.trips.first
            XCTAssertEqual(trip!.locations.first?.latitude, 3.0083233)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
//    func test_requestTravelDay_locationsCachedCorrectly() throws {
//        let sut = makeSUT()
//        let expectation = XCTestExpectation(description: "Request travels successfully")
//        requestTravelsWithSuccess(api: sut) { travel in
//            let date = "2022-11-17 02:28:11".date(gmt: 0)!
//            let cachedTravel = TripSummaryTest.cache!.travelDetail(vehicleId: "1", date: date)
//            XCTAssertEqual(cachedTravel!.distance, travel.distance)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 0.1)
//    }

    func makeSUT() -> KatsanaAPI{
        let api = KatsanaAPI(cache: TripSummaryTest.cache)
        api.API = service
        api.authToken = "testToken"
        api.configure()
        api.setupTransformer()
        return api
    }
    
    func requestTravelsWithSuccess(api: KatsanaAPI, completion: @escaping (KTDayTravel) -> Void){
        let date = Date(timeIntervalSince1970: 10)
        let path = "vehicles/1/travels/" + date.toStringWithYearMonthDay()
        
        MockService.mockResponse(path: path, expectedResponse: ["trips":[["id":7812,"start":["id":634113,"latitude":3.0090999,"longitude":101.7583183,"odometer":191304,"tracked_at":"2022-11-17 02:28:11"],"end":["id":634208,"latitude":3.0813583,"longitude":101.73286,"odometer":191317,"tracked_at":"2022-11-17 02:54:34"],"distance":13763,"duration":1583,"max_speed":50.216,"average_speed":21.473072073913045,"idle_duration":460,"score":87,"idles":[["id":634113,"latitude":3.0090999,"longitude":101.7583183,"tracked_at":"2022-11-17 02:28:11"],["id":634180,"latitude":3.0758866,"longitude":101.7557333,"tracked_at":"2022-11-17 02:46:42"],["id":634203,"latitude":3.0813466,"longitude":101.7328083,"tracked_at":"2022-11-17 02:52:54"]],"histories":[["id":634126,"latitude":3.0083233,"longitude":101.76094,"tracked_at":"2022-11-17 02:32:31","speed":20.518366],["id":634194,"latitude":3.0818083,"longitude":101.734005,"tracked_at":"2022-11-17 02:51:09","speed":5.39957],["id":634195,"latitude":3.08173,"longitude":101.7339833,"tracked_at":"2022-11-17 02:51:13","speed":4.319656],["id":634196,"latitude":3.0816399,"longitude":101.73389,"tracked_at":"2022-11-17 02:51:17","speed":9.719226],["id":634197,"latitude":3.0815983,"longitude":101.7328866,"tracked_at":"2022-11-17 02:51:37","speed":3.7796988],["id":634199,"latitude":3.0815483,"longitude":101.7326233,"tracked_at":"2022-11-17 02:52:17","speed":5.939527],["id":634200,"latitude":3.081455,"longitude":101.7326683,"tracked_at":"2022-11-17 02:52:25","speed":4.319656],["id":634201,"latitude":3.0814099,"longitude":101.7328033,"tracked_at":"2022-11-17 02:52:32","speed":4.859613],["id":634202,"latitude":3.0813633,"longitude":101.7328116,"tracked_at":"2022-11-17 02:52:34","speed":3.2397418]],"violations":[],"harsh":["accelerate":0,"braking":0,"cornering":0]],["id":7813,"start":["id":634220,"latitude":3.081285,"longitude":101.73256,"odometer":191318,"tracked_at":"2022-11-17 03:01:16"],"end":["id":634333,"latitude":3.1618766,"longitude":101.617745,"odometer":191339,"tracked_at":"2022-11-17 03:28:21"],"distance":21181,"duration":1625,"max_speed":53.45574,"average_speed":27.753789027368438,"idle_duration":175,"score":63,"idles":[["id":634220,"latitude":3.081285,"longitude":101.73256,"tracked_at":"2022-11-17 03:01:16"]],"histories":[["id":634229,"latitude":3.0813483,"longitude":101.7325916,"tracked_at":"2022-11-17 03:04:11","speed":3.7796988],["id":634230,"latitude":3.0815783,"longitude":101.732575,"tracked_at":"2022-11-17 03:04:21","speed":4.319656],["id":634580,"latitude":3.007045,"longitude":101.76246,"tracked_at":"2022-11-17 08:46:11","speed":19.978409],["id":634848,"latitude":3.0321566,"longitude":101.76379,"tracked_at":"2022-11-17 12:55:56","speed":4.319656],["id":634849,"latitude":3.0321949,"longitude":101.7636783,"tracked_at":"2022-11-17 12:56:16","speed":2.699785],["id":634850,"latitude":3.0322366,"longitude":101.76366,"tracked_at":"2022-11-17 12:56:19","speed":3.7796988],["id":634851,"latitude":3.032505,"longitude":101.76345,"tracked_at":"2022-11-17 12:56:39","speed":0],["id":634852,"latitude":3.0324583,"longitude":101.7633733,"tracked_at":"2022-11-17 12:56:50","speed":3.2397418],["id":634853,"latitude":3.0324166,"longitude":101.7633733,"tracked_at":"2022-11-17 12:56:52","speed":5.939527],["id":634854,"latitude":3.03152,"longitude":101.7638533,"tracked_at":"2022-11-17 12:57:08","speed":7.5593977],["id":634900,"latitude":3.008075,"longitude":101.7582133,"tracked_at":"2022-11-17 13:07:45","speed":12.419011],["id":634901,"latitude":3.009045,"longitude":101.7581666,"tracked_at":"2022-11-17 13:08:05","speed":4.319656]],"violations":[],"harsh":["accelerate":0,"braking":0,"cornering":0]]],"summary":["max_speed":53.45574,"distance":92402,"violation":0],"duration":["from":"2022-11-16 16:00:00","to":"2022-11-17 15:59:59"]])
        
        api.requestTravel(for: date, vehicleId: 1, loadLocations: true, forceLoad: true) { history in
            completion(history!)
        } failure: { error in
            XCTFail(error?.userMessage ?? "Error")
        }
    }
}

//
//  KatsanaSDKTests.swift
//  KatsanaSDKTests
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class KatsanaSDKTests: XCTestCase {
    
    var asyncExpect:XCTestExpectation?
    var vehicleId = "772"
    
    override func setUp() {
        super.setUp()
        asyncExpect = expectation(description: "longRunningFunction")
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let path = "/Users/Lutfi/testCredential.plist"
        let credential = NSDictionary(contentsOfFile: path)
        if credential != nil {
            let email = credential?["username"] as! String
            let pass =  credential?["password"] as! String
            let baseURLPath = credential?["baseURL"] as! String
            let baseURL = URL(string: baseURLPath)
            KatsanaAPI.configureShared(baseURL: baseURL!)
            
            KatsanaAPI.shared.login(email: email, password: pass) { (success) in
                print("logon")
                self.asyncExpect?.fulfill()
            }
            waitForExpectations(timeout: 5, handler: nil)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testvehicles() {
        asyncExpect = expectation(description: "longRunningFunction")
        KatsanaAPI.shared.requestAllVehicles { (vehicles, error) in
            print("vehicles test success \(vehicles)")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
//    func testvehicle() {
//        asyncExpect = expectation(description: "longRunningFunction")
//        KatsanaAPI.shared.requestVehicle(vehicleId: vehicleId) { (vehicle, error) in
//            print("vehicle test success \(vehicle)")
//        }
//        waitForExpectations(timeout: 5, handler: nil)
//    }
//    
//    func testSummaryToday() {
//        asyncExpect = expectation(description: "longRunningFunction")
//        KatsanaAPI.shared.requestTripSummaryToday(vehicleId: vehicleId) { (history, error) in
//            print("trip summary today \(history)")
//        }
//        waitForExpectations(timeout: 5, handler: nil)
//    }
//    
//    func testTripHistoryToday() {
//        asyncExpect = expectation(description: "longRunningFunction")
////        KatsanaAPI.shared.requestTripHistoryToday(vehicleId: vehicleId) { (history, error) in
////            print("trip history today \(history)")
////        }
//        waitForExpectations(timeout: 5, handler: nil)
//    }
//    
//    func testTripHistoryForDate() {
//        asyncExpect = expectation(description: "longRunningFunction")
//        KatsanaAPI.shared.requestTripHistory(for: Date(), vehicleId: vehicleId) { (history, error) in
//            print("trip history at date \(history)")
//        }
//        waitForExpectations(timeout: 5, handler: nil)
//    }
//    
//    func testUploadProfileImage() {
//        let path = "/Users/Lutfi/test.jpg"
//        let image = UIImage(contentsOfFile: path)
//        asyncExpect = expectation(description: "longRunningFunction")
//        KatsanaAPI.shared.saveCurrentUserProfileImage(image: image) { (user, error) in
//            if error == nil{
//                print("Image saved")
//            }
//        }
//        
//        
//        waitForExpectations(timeout: 15, handler: nil)
//    }
    
    func testUploadVehicleProfileImage() {
        let path = "/Users/Lutfi/test.jpg"
        let image = UIImage(contentsOfFile: path)
        asyncExpect = expectation(description: "longRunningFunction")
        KatsanaAPI.shared.requestAllVehicles { (vehicles, error) in
            KatsanaAPI.shared.saveVehicleProfileImage(vehicleId: self.vehicleId, image: image) { (vehicle, error) in
                if error == nil{
                    print("Image saved")
                }
            }
        }
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func testRefreshToken() -> Void {
        asyncExpect = expectation(description: "longRunningFunction")
        KatsanaAPI.shared.refreshToken { (success, error) in
            
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
}

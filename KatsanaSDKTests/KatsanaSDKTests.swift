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
    var vehicleId = "105"
    
    override func setUp() {
        super.setUp()
        asyncExpect = expectation(description: "longRunningFunction")
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let path = "/Users/Lutfi/testCredential.plist"
        let credential = NSDictionary(contentsOfFile: path)
        if credential != nil {
            let email = credential?["username"] as! String
            let pass =  credential?["password"] as! String
            let clientId = credential?["client_id"] as! String
            let clientSecret = credential?["client_secret"] as! String
            
            let baseURLPath = credential?["baseURL"] as! String
            let baseURL = URL(string: baseURLPath)
            KatsanaAPI.configure(baseURL: baseURL!, clientId: clientId, clientSecret: clientSecret)
            
            KatsanaAPI.shared.login(email: email, password: pass, completion: { (user) in
                print("logon")
                self.asyncExpect?.fulfill()
            }, failure: { (err) in
                
            })
            waitForExpectations(timeout: 10, handler: nil)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLogin() -> Void {
        
    }
    
    func testExample() {
        //        asyncExpect = expectation(description: "longRunningFunction")
        //        KatsanaAPI.shared.login()
        //        // This is an example of a functional test case.
        //        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //         waitForExpectations(timeout: 10, handler: nil)
    }
}

//
//  UserTest.swift
//  KatsanaSDKmacOSTests
//
//  Created by Wan Ahmad Lutfi on 30/01/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK
import URLMock
import Siesta

final class UserTest: XCTestCase {
    var service: Service!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        UMKMockURLProtocol.enable()
        UMKMockURLProtocol.setVerificationEnabled(true)
    }

    override func tearDownWithError() throws {
        UMKMockURLProtocol.setVerificationEnabled(false)
        UMKMockURLProtocol.disable()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    override func setUp() {
        service = MockService.service()
    }

    func test_requestUser() throws {
        let sut = makeSUT()
        MockService.mockResponse(path: "profile", expectedResponse: ["email": "test@yahoo.com"])
        
        let expectation = XCTestExpectation(description: "Open a file asynchronously.")
        sut.requestUser { user in
            expectation.fulfill()
        } failure: { error in
            XCTFail(error?.userMessage ?? "Error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_requestUser_currentUserIsSet() throws {
        let sut = makeSUT()
        MockService.mockResponse(path: "profile", expectedResponse: ["email": "test@yahoo.com"])
        
        let expectation = XCTestExpectation(description: "Open a file asynchronously.")
        sut.requestUser { user in
            XCTAssertEqual(user, nil)
            expectation.fulfill()
        } failure: { error in
            XCTFail(error?.userMessage ?? "Error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    
    func makeSUT() -> KatsanaAPI{
        let api = KatsanaAPI()
        api.API = service
        api.configure()
        api.setupTransformer()
        return api
    }

}

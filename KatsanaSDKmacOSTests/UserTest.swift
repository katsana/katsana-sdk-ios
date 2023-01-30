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
    var cache: KTCacheManager!

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
        
        let expectation = XCTestExpectation(description: "Request user successfully")
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
        
        let expectation = XCTestExpectation(description: "Current user is set")
        sut.requestUser { user in
            XCTAssertEqual(user, sut.currentUser)
            expectation.fulfill()
        } failure: { error in
            XCTFail(error?.userMessage ?? "Error")
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_requestUser_lastUserCachedEqual() throws {
        let expectation = XCTestExpectation(description: "Request user, user cached properly")
        requestUserWithSuccess { user in
            XCTAssertEqual(user.email, self.cache!.lastUser()?.email)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    
    func makeSUT() -> KatsanaAPI{
        self.cache = MockCache()
        let api = KatsanaAPI(cache: self.cache)
        api.API = service
        api.configure()
        api.setupTransformer()
        return api
    }
    
    func requestUserWithSuccess(completion: @escaping (KTUser) -> Void){
        let sut = makeSUT()
        MockService.mockResponse(path: "profile", expectedResponse: ["email": "test@yahoo.com"])
        sut.requestUser { user in
            completion(user)
        } failure: { error in
            XCTFail(error?.userMessage ?? "Error")
        }
    }

}

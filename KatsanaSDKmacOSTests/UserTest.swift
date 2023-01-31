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
    var cache: MockCache!
    
    override class func setUp() {
        UMKMockURLProtocol.enable()
        UMKMockURLProtocol.setVerificationEnabled(true)
    }
    
    override class func tearDown() {
        UMKMockURLProtocol.setVerificationEnabled(false)
        UMKMockURLProtocol.disable()
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        
//        cache?.clearCache()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    override func setUp() {
        service = MockService.service()
    }

    func test_requestUser() throws {
        let sut = makeSUT(cache: MockCache())
        let expectation = XCTestExpectation(description: "Request user successfully")
        requestUserWithSuccess(api: sut) { user in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_requestUser_currentUserIsSet() throws {
        let sut = makeSUT(cache: MockCache())
        let expectation = XCTestExpectation(description: "Current user is set")
        requestUserWithSuccess(api: sut) { user in
            XCTAssertEqual(user, sut.currentUser)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_requestUser_lastUserCachedEqual() throws {
        let cache = MockCache()
        let sut = makeSUT(cache: cache)
        let expectation = XCTestExpectation(description: "Request user, last user set properly")
        requestUserWithSuccess(api: sut) { user in
            XCTAssertEqual(user.email, cache.lastUser()?.email)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_requestUser_userCachedCorrectlyFromDisk() throws {
        let cache = MockCache(writeToDisk: true)
        let sut = makeSUT(cache: cache)
        
        let expectation = XCTestExpectation(description: "Request user, user cached properly")
        requestUserWithSuccess(api: sut) { user in
            let cachedUser = cache.loadCachedUser()
            XCTAssertNotNil(cachedUser)
            XCTAssertEqual(user.email, cachedUser!.email)
            XCTAssertEqual(user.createdAt, cachedUser!.createdAt)
            cache.clearCache()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    
    func makeSUT(cache: MockCache) -> KatsanaAPI{
        let api = KatsanaAPI(cache: cache)
        api.API = service
        api.configure()
        api.setupTransformer()
        return api
    }
    
    func requestUserWithSuccess(api: KatsanaAPI, completion: @escaping (KTUser) -> Void){
        MockService.mockResponse(path: "profile", expectedResponse: ["email": "test@yahoo.com", "userId": "1", "created_at": "2019-11-05 04:47:52"])
        api.requestUser { user in
            completion(user)
        } failure: { error in
            XCTFail(error?.userMessage ?? "Error")
        }
    }

}

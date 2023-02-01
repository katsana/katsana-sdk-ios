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
    var cache: CacheManagerSpy!
    static var tempUser: KTUser!
    
    override class func setUp() {
        UMKMockURLProtocol.enable()
        UMKMockURLProtocol.setVerificationEnabled(true)
    }
    
    override class func tearDown() {
        UMKMockURLProtocol.setVerificationEnabled(false)
        UMKMockURLProtocol.disable()
        UserTest.tempUser = nil
    }

    override func setUp() {
        service = MockService.service()
    }

    func test_requestUser() throws {
        let sut = makeSUT(cache: CacheManagerSpy())
        let expectation = XCTestExpectation(description: "Request user successfully")
        requestUserWithSuccess(api: sut) { user in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_requestUser_currentUserIsSet() throws {
        let sut = makeSUT(cache: CacheManagerSpy())
        let expectation = XCTestExpectation(description: "Current user is set")
        requestUserWithSuccess(api: sut) { user in
            XCTAssertEqual(user.email, sut.currentUser.email)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_requestUser_lastUserCachedEqual() throws {
        let cache = CacheManagerSpy()
        let sut = makeSUT(cache: cache)
        let expectation = XCTestExpectation(description: "Request user, last user set properly")
        requestUserWithSuccess(api: sut) { user in
            XCTAssertEqual(user.email, cache.lastUser()?.email)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_requestUser_userCachedCorrectlyFromDisk() throws {
        let cache = CacheManagerSpy(writeToDisk: true)
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
    
    
    func makeSUT(cache: CacheManagerSpy) -> KatsanaAPI{
        let api = KatsanaAPI(cache: cache)
        api.API = service
        api.authToken = "testToken"
        api.configure()
        api.setupTransformer()
        return api
    }
    
    func requestUserWithSuccess(api: KatsanaAPI, completion: @escaping (KTUser) -> Void){
        MockService.mockResponse(path: "profile", expectedResponse: ["email": "test@yahoo.com", "userId": "1", "created_at": "2019-11-05 04:47:52"])
        
        //Using MockService have small delay, so if there already data, we just return temp vehicles
//        if let user = UserTest.tempUser{
//            completion(user)
//            return
//        }
        
        api.loadProfile { result in
            switch result{
            case .success(let user):
                completion(user)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

    }

}

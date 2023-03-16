//
//  KatsanaSDKEndToEndTests.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

final class KatsanaSDKEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETUserResult_matchesTestData() {
        switch getUserResult(params: ["fleets", "plan", "company"]) {
        case let .success(user)?:
            XCTAssertGreaterThanOrEqual(user.email.count, 1)
            XCTAssertGreaterThanOrEqual(user.fleets.count, 1)
            XCTAssertNotNil(user.plan)
            XCTAssertNotNil(user.company)
        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")
            
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    func makeSUT() -> KatsanaServiceFactory{
        let tokenService = TokenServiceStub(stub: .success(AccessToken(token: Secret.token)))
        let client = AuthenticatedHTTPClientDecorator(decoratee: ephemeralClient(), tokenService: tokenService)
        let factory = KatsanaServiceFactory(baseURL: Secret.baseURL, client: client)
        
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(factory)
        trackForMemoryLeaks(tokenService)
        
        return factory
        
    }
    
    
    private func getUserResult(params: [String]?, file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<KTUser, Error>? {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<KTUser, Error>?
        let loader = sut.makeUserProfileLoader(includes: params)
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private var testServerURL: URL {
        return URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }
    
    private func ephemeralClient(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }
    
}

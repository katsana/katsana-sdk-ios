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
    
    func test_endToEndTestServerGETUser_matchesTestData() {
        let sut = makeSUT()
        switch getResult(loader: {
            sut.makeUserProfileLoader(includes: ["fleets", "plan", "company"])
        }) {
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
    
    func test_endToEndTestServerGETVehicle_matchesTestData() {
        let sut = makeSUT()
        switch getResult(loader: {
            sut.makeVehicleLoader(vehicleId: 489, includes: ["features","insured","earliest_date","fuel","fleets","sensors"])
        }) {
        case let .success(user)?:
            XCTAssertEqual(user.features, ["immobilizer", "temperature"])
            XCTAssertEqual(user.userId, 81)
            XCTAssertEqual(user.sensors?.first?.name, "PAX")
            XCTAssertGreaterThanOrEqual(user.fleetIds.count, 1)
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
    
    
    private func getResult<Resource>(loader: () -> RemoteLoader<Resource>, file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<Resource, Error>? {
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: Swift.Result<Resource, Error>?
        let loader = loader()
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func ephemeralClient(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }
    
}

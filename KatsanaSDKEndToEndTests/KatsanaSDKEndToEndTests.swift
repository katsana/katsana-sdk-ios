//
//  KatsanaSDKEndToEndTests.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

final class KatsanaSDKEndToEndTests: XCTestCase, ResourceStoreManagerDelegate {
    
    func test_endToEndTestServerGETUser_matchesTestData() {
        let sut = makeSUT()
        switch getResult(loader: {
            sut.makeUserProfileLoader(includes: ["fleets", "plan", "company"])
        }) {
        case let .success(user)?:
            XCTAssertGreaterThanOrEqual(user.email.count, 1)
            XCTAssertGreaterThanOrEqual(user.fleets!.count, 1)
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
    
    func test_endToEndTestServerGETVehicles_matchesTestData() {
        let sut = makeSUT()
        switch getResult(loader: {
            sut.makeVehiclesLoader()
        }) {
        case let .success(vehicles)?:
            XCTAssertGreaterThanOrEqual(vehicles.count, 10)
        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")
            
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }

    
    // MARK: - Helpers
    
    func makeSUT() -> APIPublisherFactory{
        let storeManager = ResourceStoreManager(delegate: self)
        let tokenService = TokenServiceStub(stub: .success(AccessToken(token: Secret.token)))
        let client = AuthenticatedHTTPClientDecorator(decoratee: ephemeralClient(), tokenService: tokenService)
        let factory = APIPublisherFactory(baseURL: Secret.baseURL, baseStoreURL: localStoreURL, client: client, storeManager: storeManager)
        
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
    
    private lazy var localStoreURL: URL = {
        let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectoryPath = arrayPaths[0]
        return cacheDirectoryPath
    }()
    
    func makeStore<Resource, S>(_ type: Resource.Type) -> KatsanaSDK.AnyResourceStore<Resource> where Resource : Decodable, Resource : Encodable, Resource : Equatable, S : KatsanaSDK.AnyResourceStore<Resource> {
        let classname = String(describing: Resource.self) + "test"
        let url = localStoreURL.appendingPathComponent(classname + ".store")
        let store = CodableResourceStore<Resource>(storeURL: url)
        let anyStore = AnyResourceStore(store)
        return anyStore
    }
    
}

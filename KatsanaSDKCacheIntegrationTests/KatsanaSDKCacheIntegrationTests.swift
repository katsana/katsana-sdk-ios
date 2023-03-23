//
//  KatsanaSDKCacheIntegrationTests.swift
//  KatsanaSDKCacheIntegrationTests
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

final class KatsanaSDKCacheIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_loadFeed_deliversNoItemsOnEmptyCache() {
        let feedLoader = makeResourceLoader()
        expect(feedLoader, toLoad: nil)
    }
    
    func test_loadFeed_deliversItemsSavedOnASeparateInstance() {
        let loaderToPerformSave = makeResourceLoader()
        let loaderToPerformLoad = makeResourceLoader()
        let resource = anyResource()
        
        save(resource, with: loaderToPerformSave)
        
        expect(loaderToPerformLoad, toLoad: resource)
    }
    
    func test_saveFeed_overridesItemsSavedOnASeparateInstance() {
        let loaderToPerformFirstSave = makeResourceLoader()
        let loaderToPerformLastSave = makeResourceLoader()
        let loaderToPerformLoad = makeResourceLoader()
        let firstFeed = anyResource()
        let latestFeed = anyResource2()
        
        save(firstFeed, with: loaderToPerformFirstSave)
        save(latestFeed, with: loaderToPerformLastSave)
        
        expect(loaderToPerformLoad, toLoad: latestFeed)
    }
    
    
    // MARK: Helpers
    
    typealias CodableResourceStoreType = CodableResourceStore<String>
    typealias LocalLoaderType = LocalLoader<String, CodableResourceStoreType>
    
    private func makeResourceLoader(currentDate: Date = Date(), file: StaticString = #file, line: UInt = #line) -> LocalLoaderType {
        let storeURL = testSpecificStoreURL()
        let store = CodableResourceStoreType(storeURL: storeURL)
        let sut = LocalLoaderType(store: store, currentDate: { currentDate })
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    
    private func save(_ resource: String, with loader: LocalLoaderType, file: StaticString = #file, line: UInt = #line){
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(resource) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save feed successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func validateCache(with loader: LocalLoaderType, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.validateCache() { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to validate feed successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }

    private func expect(_ sut: LocalLoaderType, toLoad expectedResource: String?, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedResource, file: file, line: line)

            case let .failure(error):
                XCTFail("Expected successful resource result, got \(error) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func anyResource() -> String{
        return "test data"
    }
    
    private func anyResource2() -> String{
        return "test data2"
    }

}

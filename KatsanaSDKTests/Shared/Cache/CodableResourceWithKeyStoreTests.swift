//
//  CodableResourceWithKeyStoreTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 05/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class CodableResourceWithKeyStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyResource())
    }
    
    func test_retrieveResource_deliversNotFoundWhenStoredResourceKeyDoesNotMatch() {
        let sut = makeSUT()
        let key = "a key"
        let nonMatchingKey = "other key"

        insert(anyResource(), for: key, into: sut)

        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingKey)
    }

    func test_retrieveResource_deliversFoundDataWhenThereIsAStoredResourceMatchingKey() {
        let sut = makeSUT()
        let storedData = anyResource()
        let matchingKey = "a key"

        insert(storedData, for: matchingKey, into: sut)

        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingKey)
    }

    func test_retrieveResource_deliversLastInsertedValue() {
        let sut = makeSUT()
        let firstStoredData = "first data"
        let lastStoredData = "last data"
        let key = "a key"

        insert(firstStoredData, for: key, into: sut)
        insert(lastStoredData, for: key, into: sut)

        expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: key)
    }
    
    func test_retrieveResource_hasNoSideEffectsWhenSaveOtherResource() {
        let sut = makeSUT()
        let aStoredData = "a data"
        let otherStoredData = "other data"
        let key = "a key"
        let otherKey = "other key"

        insert(aStoredData, for: key, into: sut)
        insert(otherStoredData, for: otherKey, into: sut)

        expect(sut, toCompleteRetrievalWith: found(aStoredData), for: key)
        expect(sut, toCompleteRetrievalWith: found(otherStoredData), for: otherKey)
    }

    
    // - MARK: Helpers
    
    typealias CodableResourceWithKeyStoreType = CodableResourceStore<String>

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableResourceWithKeyStoreType {
        let sut = CodableResourceWithKeyStoreType(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func notFound() -> Result<CodableResourceWithKeyStoreType.Resource?, Error> {
        return .success(.none)
    }
    
    private func found(_ resource: CodableResourceWithKeyStoreType.Resource) -> Result<CodableResourceWithKeyStoreType.Resource?, Error> {
        return .success(resource)
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func anyResource() -> CodableResourceWithKeyStoreType.Resource {
        return "any resource)"
    }
    
    private func expect(_ sut: CodableResourceWithKeyStoreType, toCompleteRetrievalWith expectedResult: Result<String?, Error>, for key: String,  file: StaticString = #filePath, line: UInt = #line) {
        let receivedResult = Result { try sut.retrieve(resourceForKey: key) }

        switch (receivedResult, expectedResult) {
        case let (.success( receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            
        default:
            XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    private func insert(_ resource: CodableResourceWithKeyStoreType.Resource, for key: String, into sut: CodableResourceWithKeyStoreType, file: StaticString = #filePath, line: UInt = #line) {
        do {
            try sut.insert(resource, for: key)
        } catch {
            XCTFail("Failed to insert \(resource) with error \(error)", file: file, line: line)
        }
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
}

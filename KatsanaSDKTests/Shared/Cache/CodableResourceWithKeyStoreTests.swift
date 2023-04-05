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
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: notFound(), for: anyResource())
    }
    
//    func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() {
//        let sut = makeSUT()
//        let url = URL(string: "http://a-url.com")!
//        let nonMatchingURL = URL(string: "http://another-url.com")!
//
//        insert(anyData(), for: url, into: sut)
//
//        expect(sut, toCompleteRetrievalWith: notFound(), for: nonMatchingURL)
//    }
//
//    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
//        let sut = makeSUT()
//        let storedData = anyData()
//        let matchingURL = URL(string: "http://a-url.com")!
//
//        insert(storedData, for: matchingURL, into: sut)
//
//        expect(sut, toCompleteRetrievalWith: found(storedData), for: matchingURL)
//    }
//
//    func test_retrieveImageData_deliversLastInsertedValue() {
//        let sut = makeSUT()
//        let firstStoredData = Data("first".utf8)
//        let lastStoredData = Data("last".utf8)
//        let url = URL(string: "http://a-url.com")!
//
//        insert(firstStoredData, for: url, into: sut)
//        insert(lastStoredData, for: url, into: sut)
//
//        expect(sut, toCompleteRetrievalWith: found(lastStoredData), for: url)
//    }
//
//    func test_sideEffects_runSerially() {
//        let sut = makeSUT()
//        let url = anyURL()
//
//        let op1 = expectation(description: "Operation 1")
//        sut.insert([localImage(url: url)], timestamp: Date()) { _ in
//            op1.fulfill()
//        }
//
//        let op2 = expectation(description: "Operation 2")
//        sut.insert(anyData(), for: url) { _ in    op2.fulfill() }
//
//        let op3 = expectation(description: "Operation 3")
//        sut.insert(anyData(), for: url) { _ in op3.fulfill() }
//
//        wait(for: [op1, op2, op3], timeout: 5.0, enforceOrder: true)
//    }
    
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
}

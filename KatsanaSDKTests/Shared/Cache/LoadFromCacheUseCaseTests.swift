//
//  LoadFromCacheUseCases.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 22/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import Foundation
import KatsanaSDK

class LoadFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_load_deliversNoResourceOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(nil), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_load_deliversCachedResourceOnNonExpiredCache() {
        let resource = "test data"
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusResourceCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(resource), when: {
            store.completeRetrieval(with: resource, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_load_deliversNoResourceOnCacheExpiration() {
        let resource = "test data"
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusResourceCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(nil), when: {
            store.completeRetrieval(with: resource, timestamp: expirationTimestamp)
        })
    }
    
    func test_load_deliversNoResourceOnExpiredCache() {
        let resource = "test data"
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusResourceCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(nil), when: {
            store.completeRetrieval(with: resource, timestamp: expirationTimestamp)
        })
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let resource = "test data"
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusResourceCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetrieval(with: resource, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let resource = "test data"
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusResourceCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetrieval(with: resource, timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnExpiredCache() {
        let resource = "test data"
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusResourceCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetrieval(with: resource, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    typealias CacheResourceStoreSpyType = CacheResourceStoreSpy<String>
    typealias LocalLoaderType = LocalLoader<String, CacheResourceStoreSpyType>
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalLoaderType, store: CacheResourceStoreSpyType) {
        let store = CacheResourceStoreSpyType()
        let sut = LocalLoaderType(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalLoaderType, toCompleteWith expectedResult: LocalLoaderType.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
    
}

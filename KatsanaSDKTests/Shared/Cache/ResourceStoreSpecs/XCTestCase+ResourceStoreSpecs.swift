//
//  XCTestCase+ResourceStoreSpecs.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

extension ResourceStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache<R: ResourceStore>(on sut: R, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache<R: ResourceStore>(on sut: R, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }

//    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
//        let feed = uniqueImageFeed().local
//        let timestamp = Date()
//
//        insert((feed, timestamp), to: sut)
//
//        expect(sut, toRetrieve: .success(.some((feed: feed, timestamp: timestamp))), file: file, line: line)
//    }
//
//    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
//        let feed = uniqueImageFeed().local
//        let timestamp = Date()
//
//        insert((feed, timestamp), to: sut)
//
//        expect(sut, toRetrieveTwice: .success(.some((feed: feed, timestamp: timestamp))), file: file, line: line)
//    }
//
//    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
//        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
//
//        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
//    }
//
//    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
//        insert((uniqueImageFeed().local, Date()), to: sut)
//
//        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
//
//        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
//    }
//
//    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
//        insert((uniqueImageFeed().local, Date()), to: sut)
//
//        let latestFeed = uniqueImageFeed().local
//        let latestTimestamp = Date()
//        insert((latestFeed, latestTimestamp), to: sut)
//
//        expect(sut, toRetrieve: .success(.some((feed: latestFeed, timestamp: latestTimestamp))), file: file, line: line)
//    }
//
//    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
//        let deletionError = deleteCache(from: sut)
//
//        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
//    }
//
//    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
//        deleteCache(from: sut)
//
//        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
//    }
//
//    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
//        insert((uniqueImageFeed().local, Date()), to: sut)
//
//        let deletionError = deleteCache(from: sut)
//
//        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
//    }
//
//    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
//        insert((uniqueImageFeed().local, Date()), to: sut)
//
//        deleteCache(from: sut)
//
//        expect(sut, toRetrieve: .success(.none), file: file, line: line)
//    }
//
//    func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
//        var completedOperationsInOrder = [XCTestExpectation]()
//
//        let op1 = expectation(description: "Operation 1")
//        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
//            completedOperationsInOrder.append(op1)
//            op1.fulfill()
//        }
//
//        let op2 = expectation(description: "Operation 2")
//        sut.deleteCachedFeed { _ in
//            completedOperationsInOrder.append(op2)
//            op2.fulfill()
//        }
//
//        let op3 = expectation(description: "Operation 3")
//        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
//            completedOperationsInOrder.append(op3)
//            op3.fulfill()
//        }
//
//        waitForExpectations(timeout: 5.0)
//
//        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
//    }

}

extension ResourceStoreSpecs where Self: XCTestCase {
    @discardableResult
//    func deleteCache(from sut: FeedStore) -> Error? {
//        let exp = expectation(description: "Wait for cache deletion")
//        var deletionError: Error?
//        sut.deleteCachedFeed { result in
//            if case let .failure(error) = result { deletionError = error}
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 3.0)
//        return deletionError
//    }

    func expect<R: ResourceStore>(_ sut: R, toRetrieveTwice expectedResult: R.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect<R: ResourceStore>(_ sut: R, toRetrieve expectedResult: R.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.none) , .success(.none)),
                (.failure, .failure):
                break
                
            case let (.success(.some((expectedFeed, expectedTimestamp))), .success(.some((retrievedFeed, retrievedTimestamp)))):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
//    @discardableResult
//    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
//        let exp = expectation(description: "Wait for cache insertion")
//        var insertionError: Error?
//        sut.insert(cache.feed, timestamp: cache.timestamp) { result in
//            if case let .failure(error) = result { insertionError = error}
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 1.0)
//        return insertionError
//    }
}


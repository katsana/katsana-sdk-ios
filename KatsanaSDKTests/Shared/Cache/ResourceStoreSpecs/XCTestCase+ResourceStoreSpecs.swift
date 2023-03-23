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

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache<R: ResourceStore>(resource: R.Resource, on sut: R, file: StaticString = #file, line: UInt = #line) {
        let timestamp = Date()

        insert((resource, timestamp), to: sut)

        expect(sut, toRetrieve: .success(.some((resource: resource, timestamp: timestamp))), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache<R: ResourceStore>(resource: R.Resource, on sut: R, file: StaticString = #file, line: UInt = #line) {
        let timestamp = Date()

        insert((resource, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .success(.some((resource: resource, timestamp: timestamp))), file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnEmptyCache<R: ResourceStore>(resource: R.Resource, on sut: R, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((resource, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnNonEmptyCache<R: ResourceStore>(resource: R.Resource, resource2: R.Resource, on sut: R, file: StaticString = #file, line: UInt = #line) {
        insert((resource, Date()), to: sut)

        let insertionError = insert((resource2, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }

    func assertThatInsertOverridesPreviouslyInsertedCacheValues<R: ResourceStore>(resource: R.Resource, resource2: R.Resource, on sut: R, file: StaticString = #file, line: UInt = #line) {
        insert((resource, Date()), to: sut)

        let latestResource = resource2
        let latestTimestamp = Date()
        insert((latestResource, latestTimestamp), to: sut)

        expect(sut, toRetrieve: .success(.some((resource: latestResource, timestamp: latestTimestamp))), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnEmptyCache<R: ResourceStore>(on sut: R, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache<R: ResourceStore>(on sut: R, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut)

        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache<R: ResourceStore>(resource: R.Resource, on sut: R, file: StaticString = #file, line: UInt = #line) {
        insert((resource, Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteEmptiesPreviouslyInsertedCache<R: ResourceStore>(resource: R.Resource, on sut: R, file: StaticString = #file, line: UInt = #line) {
        insert((resource, Date()), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatSideEffectsRunSerially<R: ResourceStore>(resource: R.Resource, resource2: R.Resource, on sut: R, file: StaticString = #file, line: UInt = #line) {
        var completedOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")
        sut.insert(resource, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedResource { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(resource2, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
    }

}

extension ResourceStoreSpecs where Self: XCTestCase {
    @discardableResult
    func deleteCache<R: ResourceStore>(from sut: R) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedResource { result in
            if case let .failure(error) = result { deletionError = error}
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        return deletionError
    }

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
    
    @discardableResult
    func insert<R: ResourceStore, Resource>(_ cache: (resource: Resource, timestamp: Date), to sut: R) -> Error? where Resource == R.Resource{
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.resource, timestamp: cache.timestamp) { result in
            if case let .failure(error) = result { insertionError = error}
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
}


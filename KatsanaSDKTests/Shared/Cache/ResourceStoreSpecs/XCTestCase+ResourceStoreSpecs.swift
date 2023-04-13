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

}

extension ResourceStoreSpecs where Self: XCTestCase {
    @discardableResult
    func deleteCache<R: ResourceStore>(from sut: R) -> Error? {
        var deletionError: Error?
        do{
            try sut.deleteCachedResource()
        }catch{
            deletionError = error
        }
        return deletionError
    }

    func expect<R: ResourceStore>(_ sut: R, toRetrieveTwice expectedResult: R.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect<R: ResourceStore>(_ sut: R, toRetrieve expectedResult: R.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        do{
            let resource = try sut.retrieve()
            let result = try expectedResult.get()
            XCTAssertEqual(resource?.resource, result?.resource)
            XCTAssertEqual(resource?.timestamp, result?.timestamp)

        }catch{
            switch expectedResult{
            case .failure:
                ()
            case .success(_):
                XCTFail("Expected to retrieve \(expectedResult)", file: file, line: line)
            }
        }
    }
    
    @discardableResult
    func insert<R: ResourceStore, Resource>(_ cache: (resource: Resource, timestamp: Date), to sut: R) -> Error? where Resource == R.Resource{
        do{
            try sut.insert(cache.resource, timestamp: cache.timestamp)
        }catch{
            return error
        }
        return nil
    }
}


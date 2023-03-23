//
//  CacheResourceUseCaseTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

final class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation(){
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages.count, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()

        sut.save(anyResource()){_ in}

        XCTAssertEqual(store.receivedMessages, [.deleteCachedResource])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        sut.save(anyResource()){_ in}
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receivedMessages, [.deleteCachedResource])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let item = anyResource()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(item){_ in}
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedResource, .insert(item, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    // MARK: - Helpers
    
    typealias CacheResourceStoreSpyType = CacheResourceStoreSpy<String>
    typealias LocalLoaderType = LocalLoader<String, CacheResourceStoreSpyType>
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalLoaderType, store: CacheResourceStoreSpyType) {
        let store = CacheResourceStoreSpyType()
        let sut = LocalLoaderType(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalLoaderType, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")

        var receivedError: Error?
        sut.save(anyResource()) { result in
            if case let .failure(error) = result { receivedError = error}
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func anyResource() -> String{
        return "test data"
    }
    
    private func anyResource2() -> String{
        return "test data"
    }
}


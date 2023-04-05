//
//  LoadResourceWithKeyFromCacheUseCaseTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class ResourceWithKeyStoreSpy<Resource>: ResourceWithKeyStore where Resource: Equatable{
    
    enum Message: Equatable {
        case insert(resource: Resource, for: String)
        case retrieve(resourceFor: String)
    }
    
    private(set) var receivedMessages = [Message]()
    private var retrievalResult: Result<Resource?, Error>?
    private var insertionResult: Result<Void, Error>?
    
    func insert(_ resource: Resource, for key: String) throws {
        receivedMessages.append(.insert(resource: resource, for: key))
        try insertionResult?.get()
    }
    
    func retrieve(resourceForKey key: String) throws -> Resource? {
        receivedMessages.append(.retrieve(resourceFor: key))
        return try retrievalResult?.get()
    }
    
    
    func completeRetrieval(with error: Error) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrieval(with resource: Resource?) {
        retrievalResult = .success(resource)
    }
    
    func completeInsertion(with error: Error) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully() {
        insertionResult = .success(())
    }
}

class LoadResourceWithKeyFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadResourceFromKey_requestsStoredResourceForKey() {
        let (sut, store) = makeSUT()
        let key = anyKey()

        _ = try? sut.loadResource(from: key)

        XCTAssertEqual(store.receivedMessages, [.retrieve(resourceFor: key)])
    }

    func test_loadResourceFromKey_failsOnStoreError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyNSError()
            store.completeRetrieval(with: retrievalError)
        })
    }

    func test_loadResourceFromKey_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: notFound(), when: {
            store.completeRetrieval(with: .none)
        })
    }

    func test_loadResourceFromKey_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyResource()

        expect(sut, toCompleteWith: .success(foundData), when: {
            store.completeRetrieval(with: foundData)
        })
    }

    // MARK: - Helpers
    
    typealias ResourceWithKeyStoreSpyType = ResourceWithKeyStoreSpy<String>
    typealias LocalLoaderType = LocalResourceWithKeyLoader<ResourceWithKeyStoreSpyType>

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalLoaderType, store: ResourceWithKeyStoreSpyType) {
        let store = ResourceWithKeyStoreSpyType()
        let sut = LocalLoaderType(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func failed() -> Result<LocalLoaderType.R, Error> {
        return .failure(LocalLoaderType.LoadError.failed)
    }

    private func notFound() -> Result<LocalLoaderType.R, Error> {
        return .failure(LocalLoaderType.LoadError.notFound)
    }
    
    private func expect(_ sut: LocalLoaderType, toCompleteWith expectedResult: Result<LocalLoaderType.R, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        action()

        let receivedResult = Result { try sut.loadResource(from: anyKey()) }

        switch (receivedResult, expectedResult) {
        case let (.success(receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)

        case (.failure(let receivedError as LocalLoaderType.LoadError),
              .failure(let expectedError as LocalLoaderType.LoadError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)

        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
    
    func anyKey() -> String {
        return "any key"
    }
    
    func anyResource() -> String {
        return "any resource"
    }
    
}

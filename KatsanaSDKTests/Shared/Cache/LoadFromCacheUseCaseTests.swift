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

public typealias CachedResource<Resource> = (resource: Resource, timestamp: Date)

public protocol FeedStore{
    associatedtype Resource where Resource: Equatable
    
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrievalResult = Result<CachedResource<Resource>?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: Resource, timestamp: Date, completion: @escaping InsertionCompletion)

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}

class FeedStoreSpy<R>: FeedStore where R: Equatable{
    typealias Resource = R
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert(Resource, Date)
        case retrieve
    }

    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    func insert(_ feed: Resource, timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        receivedMessages.append(.retrieve)
    }
}

public final class LocalLoader<Resource, FeedStoreType: FeedStore> where Resource: Equatable, Resource == FeedStoreType.Resource{
    private let store: FeedStoreType
    private let currentDate: () -> Date

    public init(store: FeedStoreType, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public typealias LoadResult = Swift.Result<Resource, Error>

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
//            guard let self = self else { return }
//
//            switch result {
//            case let .failure(error):
//                completion(.failure(error))
//
//            case let .success(.some(cache)): // where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
//                completion(.success(cache.feed.toModels()))

//            case .success:
//                completion(.success([]))
//            }
        }
    }
}

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
    
    // MARK: - Helpers
    
    typealias FeedStoreSpyType = FeedStoreSpy<String>
    typealias LocalLoaderType = LocalLoader<String, FeedStoreSpyType>

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalLoaderType, store: FeedStoreSpyType) {
        let store = FeedStoreSpyType()
        let sut = LocalLoaderType(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}

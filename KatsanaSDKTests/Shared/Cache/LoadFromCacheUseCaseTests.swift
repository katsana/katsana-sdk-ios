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

public protocol FeedStore{
    
}

class FeedStoreSpy<Resource>: FeedStore where Resource: Equatable{
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert(Resource, Date)
        case retrieve
    }

    private(set) var receivedMessages = [ReceivedMessage]()
}

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

class LoadFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }
    
    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy<String>) {
        let store = FeedStoreSpy<String>()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}

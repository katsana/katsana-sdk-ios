//
//  CacheResourceStoreSpy.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import KatsanaSDK

class CacheResourceStoreSpy<R>: ResourceStore where R: Equatable{
    typealias Resource = R
    
    enum ReceivedMessage: Equatable {
        case deleteCachedResource
        case insert(Resource, Date)
        case retrieve
    }

    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<CachedResource<R>?, Error>?
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    func deleteCachedResource() throws {
        receivedMessages.append(.deleteCachedResource)
        try deletionResult?.get()
    }
    
    func insert(_ resource: R, timestamp: Date) throws {
        receivedMessages.append(.insert(resource, timestamp))
        try insertionResult?.get()
    }
    
    func retrieve() throws -> KatsanaSDK.CachedResource<R>? {
        receivedMessages.append(.retrieve)
        return try retrievalResult?.get()
    }
    
    func deleteCachedResource(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedResource)
    }
    
    func completeDeletion(with error: Error) {
        deletionResult = .failure(error)
    }
    
    func completeDeletionSuccessfully() {
        deletionResult = .success(())
    }

    
    func insert(_ resource: Resource, timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(resource, timestamp))
    }
    
    func completeInsertion(with error: Error) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully() {
        insertionResult = .success(())
    }
    
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrievalWithEmptyCache() {
        retrievalResult = .success(.none)
    }
    
    func completeRetrieval(with resource: Resource, timestamp: Date, at index: Int = 0) {
        retrievalResult = .success(CachedResource(resource: resource, timestamp: timestamp))
    }
}

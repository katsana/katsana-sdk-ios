//
//  CacheResourceStoreSpy.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import KatsanaSDK

class CacheResourceStoreSpy<R>: CacheResourceStore where R: Equatable{
    typealias Resource = R
    
    enum ReceivedMessage: Equatable {
        case deleteCachedResource
        case insert(Resource, Date)
        case retrieve
    }

    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    func deleteCachedResource(completion: @escaping DeletionCompletion) {
        
    }
    
    func insert(_ resource: Resource, timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }
    
    func completeRetrieval(with resource: Resource, timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.success(CachedResource<Resource>(resource: resource, timestamp: timestamp)))
    }
}

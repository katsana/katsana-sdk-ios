//
//  CacheResourceStore.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public typealias CachedResource<Resource> = (resource: Resource, timestamp: Date)

public protocol ResourceStore{
    associatedtype Resource where Resource: Equatable
    
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrievalResult = Result<CachedResource<Resource>?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedResource() throws
    func insert(_ resource: Resource, timestamp: Date) throws
    func retrieve() throws -> CachedResource<Resource>?
}



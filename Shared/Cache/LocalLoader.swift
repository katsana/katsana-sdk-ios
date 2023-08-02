//
//  LocalLoader.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public enum LocalLoaderError: Swift.Error{
    case notFound
}

public final class LocalLoader<Resource, S: ResourceStore>: ResourceLoader where Resource: Equatable, S.Resource == Resource{
    public typealias LoadResource = Resource
    
    private let store: S
    private let cachePolicy: ResourceCachePolicy
    private let currentDate: () -> Date
    
    public init(store: S, cachePolicy: ResourceCachePolicy = .defaultPolicy, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
        self.cachePolicy = cachePolicy
    }

    public func load(completion: @escaping (LoadResult) -> Void) {
        do{
            if let cache = try store.retrieve(), self.cachePolicy.validate(cache.timestamp, against: currentDate()) {
                completion(.success(cache.resource))
            }else{
                completion(.failure(LocalLoaderError.notFound))

            }
        }catch{
            completion(.failure(error))
        }
    }
    
    public func load() throws -> LoadResource{
        if let cache = try store.retrieve(), self.cachePolicy.validate(cache.timestamp, against: currentDate()) {
            return cache.resource
        }else{
            throw LocalLoaderError.notFound
        }
    }
}

extension LocalLoader: ResourceCache {
    public typealias SaveResource = Resource

    public func save(_ resource: Resource, completion: @escaping (SaveResult) -> Void) {
        do{
            try store.deleteCachedResource()
            try store.insert(resource, timestamp: currentDate())
            completion(.success(()))
        }
        catch{
            completion(.failure(error))
        }
    }
    
    public func save(_ resource: Resource) throws {
        try store.deleteCachedResource()
        try store.insert(resource, timestamp: currentDate())
    }
}

extension LocalLoader {
    private struct InvalidCache: Error {}
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        do {
            if let cache = try store.retrieve(), !self.cachePolicy.validate(cache.timestamp, against: currentDate()) {
                throw InvalidCache()
            }
            completion(.success(()))
        } catch {
            do{
                try store.deleteCachedResource()
                completion(.success(()))
            }catch{
                completion(.failure(error))
            }
        }
    }
}

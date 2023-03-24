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
    private let store: S
    private let currentDate: () -> Date
    
    public init(store: S, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cache)) where ResourceCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.resource))
            case .success:
                completion(.failure(LocalLoaderError.notFound))
            }
        }
    }
}

extension LocalLoader: ResourceCache {
    public typealias SaveResource = Resource

    public func save(_ resource: Resource, completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedResource { [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult{
            case .success:
                self.cache(resource, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ resource: Resource, with completion: @escaping (SaveResult) -> Void) {
        store.insert(resource, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

extension LocalLoader {
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedResource(completion: completion)
                
            case let .success(.some(cache)) where !ResourceCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedResource(completion: completion)
                
            case .success:
                completion(.success(()))
            }
        }
    }
}

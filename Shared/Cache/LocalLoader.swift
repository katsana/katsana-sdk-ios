//
//  LocalLoader.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public final class LocalLoader<Resource, CacheResourceStoreType: CacheResourceStore> where Resource: Equatable, Resource == CacheResourceStoreType.Resource{
    private let store: CacheResourceStoreType
    private let currentDate: () -> Date

    public init(store: CacheResourceStoreType, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public typealias LoadResult = Swift.Result<Resource?, Error>

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cache)) where ResourceCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.resource))
            case .success:
                completion(.success(nil))
            }
        }
    }
}

//
//  InMemoryResourceStore.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

private var InMemoryResourceStoreCaches = [String: Any]()

public class InMemoryResourceStore<R>: ResourceStore where R: Equatable, R: Codable{
    public typealias Resource = R
    
    private struct Cache<R>{
        let resource: R
        let timestamp: Date
    }
    
    public init() {
    }
    
    public func deleteCachedResource() throws {
        let key = String(describing: R.self)
        InMemoryResourceStoreCaches[key] = nil
    }
    
    public func insert(_ resource: R, timestamp: Date) throws {
        let key = String(describing: R.self)
        InMemoryResourceStoreCaches[key] = Cache(resource: resource, timestamp: timestamp)
    }
    
    public func retrieve() throws -> KatsanaSDK.CachedResource<R>? {
        let key = String(describing: R.self)

        if let cache = InMemoryResourceStoreCaches[key] as? Cache<R>{
            return (cache.resource, cache.timestamp)
        }
        return .none
    }
    
}
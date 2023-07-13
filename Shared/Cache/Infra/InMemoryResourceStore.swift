//
//  InMemoryResourceStore.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class InMemoryResourceStore<R>: ResourceStore where R: Equatable, R: Codable{
    public typealias Resource = R
    
    private struct Cache<R>{
        let resource: R
        let timestamp: Date
    }
    
    private var cache: Cache<R>?
    
    public init() {
    }
    
    public func deleteCachedResource() throws {
        cache = nil
    }
    
    public func insert(_ resource: R, timestamp: Date) throws {
        cache = Cache(resource: resource, timestamp: timestamp)
    }
    
    public func retrieve() throws -> KatsanaSDK.CachedResource<R>? {
        if let cache{
            return (cache.resource, cache.timestamp)
        }
        return .none
    }
    
}

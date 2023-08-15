//
//  InMemoryResourceStore.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

fileprivate let globalBackgroundSyncronizeDataQueue = DispatchQueue(
    label: "globalSyncQueue")

private var InMemoryResourceStoreCaches = [String: Any]()
private let inMemoryResourceStoreLock = NSLock()


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
        inMemoryResourceStoreLock.lock()
        InMemoryResourceStoreCaches[key] = nil
        inMemoryResourceStoreLock.unlock()
    }
    
    public func insert(_ resource: R, timestamp: Date) throws {
        let key = String(describing: R.self)
        inMemoryResourceStoreLock.lock()
        InMemoryResourceStoreCaches[key] = Cache(resource: resource, timestamp: timestamp)
        inMemoryResourceStoreLock.unlock()
    }
    
    public func retrieve() throws -> KatsanaSDK.CachedResource<R>? {
        let key = String(describing: R.self)

        inMemoryResourceStoreLock.lock()
        if let cache = InMemoryResourceStoreCaches[key] as? Cache<R>{
            inMemoryResourceStoreLock.unlock()
            return (cache.resource, cache.timestamp)
        }else{
            inMemoryResourceStoreLock.unlock()
        }
        return .none
    }
    
}

extension InMemoryResourceStore: ResourceWithKeyStore{
    enum LoadError: Error {
        case failed
        case notFound
    }
    
    func identifier(_ key: String) -> String{
        return key + String(describing: R.self)
    }
    
    public func insert(_ resource: R, for key: String) throws {
        inMemoryResourceStoreLock.lock()
        InMemoryResourceStoreCaches[identifier(key)] = resource
        inMemoryResourceStoreLock.unlock()
    }
    
    public func retrieve(resourceForKey key: String) throws -> R? {
        inMemoryResourceStoreLock.lock()
        let resource = InMemoryResourceStoreCaches[identifier(key)] as? R
        inMemoryResourceStoreLock.unlock()
        return resource
    }
    
}



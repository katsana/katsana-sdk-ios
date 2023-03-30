//
//  ResourceStoreManager.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 27/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol ResourceStoreManagerDelegate{
    func makeStore<Resource, S: AnyResourceStore<Resource>>(_ type: Resource.Type) -> AnyResourceStore<Resource> where Resource: Equatable, Resource: Codable
}

public class ResourceStoreManager{
    private var stores = [Any]()
    private let delegate: ResourceStoreManagerDelegate
    
    public init(delegate: ResourceStoreManagerDelegate) {
        self.delegate = delegate
    }
    
    public func getStore<R>(type: R.Type) -> AnyResourceStore<R> where R: Equatable, R: Codable{
        var store: Any?
        for aStore in stores{
            if let aStore = aStore as? AnyResourceStore<R>{
                return aStore
            }
        }
        store = delegate.makeStore(type)
        stores.append(store!)
        return store as! AnyResourceStore<R>
    }
    
    public func deleteCachedResource<R>(type: R.Type,  completion: @escaping ResourceStore.DeletionCompletion) where R: Equatable, R: Codable{
        let store = getStore(type: type)
        store.deleteCachedResource(completion: completion)
    }
    
    public func insert<R>(type: R.Type, resource: R, timestamp: Date, completion: @escaping ResourceStore.InsertionCompletion) where R: Equatable, R: Codable {
        let store = getStore(type: type)
        store.insert(resource, timestamp: timestamp, completion: completion)
    }
    
    public func retrieve<R>(type: R.Type, completion: @escaping (Result<CachedResource<R>?, Error>) -> Void) where R: Equatable, R: Codable {
        let store = getStore(type: type)
        store.retrieve(completion: completion)
    }
}
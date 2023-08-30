//
//  ResourceCache.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol ResourceCache {
    associatedtype SaveResource
    typealias SaveResult = Swift.Result<Void, Error>

    func save(_ resource: SaveResource, completion: @escaping (SaveResult) -> Void)
}

public class AnyResourceCache<Resource>: ResourceCache {
    private let saverObject:  (Resource, @escaping (Result<Void, Error>) -> Void) -> ()

    public init<L: ResourceCache>(wrappedLoader: L) where L.SaveResource == Resource {
        self.saverObject = wrappedLoader.save
    }
    
    public func save(_ resource: Resource, completion: @escaping (Result<Void, Error>) -> Void) {
        saverObject(resource, completion)
    }
}

public extension ResourceCache{
    func eraseToAnyResourceCache() -> AnyResourceCache<SaveResource>{
        return AnyResourceCache(wrappedLoader: self)
    }
}



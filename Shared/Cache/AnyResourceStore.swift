//
//  AnyResourceStore.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class AnyResourceStore<Resource>: ResourceStore where Resource: Equatable{
    public typealias Resource = Resource
    
    private let insertionObject:  (Resource, Date) throws -> ()
    private let deletionObject:  () throws -> ()
    private let retrieveObject:  () throws -> CachedResource<Resource>?

    public init<L: ResourceStore>(_ wrapped: L) where L.Resource == Resource{
        self.deletionObject = wrapped.deleteCachedResource
        self.insertionObject = wrapped.insert
        self.retrieveObject = wrapped.retrieve
    }
    
    public func deleteCachedResource() throws {
        try deletionObject()
    }
    
    public func insert(_ resource: Resource, timestamp: Date) throws {
        try insertionObject(resource, timestamp)
    }
    
    public func retrieve() throws -> CachedResource<Resource>? {
        try retrieveObject()
    }

}

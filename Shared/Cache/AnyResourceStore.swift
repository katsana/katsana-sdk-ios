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
    
    private let insertionObject:  (Resource, Date, @escaping InsertionCompletion) -> ()
    private let deletionObject:  (@escaping DeletionCompletion) -> ()
    private let retrieveObject:  (@escaping RetrievalCompletion) -> ()

    public init<L: ResourceStore>(_ wrapped: L) where L.Resource == Resource{
        self.deletionObject = wrapped.deleteCachedResource
        self.insertionObject = wrapped.insert
        self.retrieveObject = wrapped.retrieve
    }
    
    public func deleteCachedResource(completion: @escaping DeletionCompletion) {
        deletionObject(completion)
    }
    
    public func insert(_ resource: Resource, timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionObject(resource, timestamp, completion)
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        retrieveObject(completion)
    }

}

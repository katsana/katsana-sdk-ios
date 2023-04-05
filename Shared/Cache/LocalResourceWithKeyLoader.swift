//
//  LocalResourceWithKeyLoader.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class LocalResourceWithKeyLoader<S: ResourceWithKeyStore>{
    private let store: S
    
    public init(store: S) {
        self.store = store
    }
}

extension LocalResourceWithKeyLoader: ResourceWithKeyCache{
    public typealias R = S.Resource
    
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ resource: R, for key: String) throws{
        do {
            try store.insert(resource, for: key)
        } catch {
            throw SaveError.failed
        }
    }
}

extension LocalResourceWithKeyLoader: ResourceWithKeyLoader {
    public typealias RL = S.Resource
    
    public enum LoadError: Error {
        case failed
        case notFound
    }

    public func loadResource(from key: String) throws -> RL{
        do {
            if let resource = try store.retrieve(resourceForKey: key) {
                return resource
            }
        } catch {
            throw LoadError.failed
        }
        throw LoadError.notFound
    }
}

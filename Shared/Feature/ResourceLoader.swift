//
//  ResourceLoader.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol ResourceLoader{
    associatedtype LoadResource
    typealias LoadResult = Result<LoadResource, Swift.Error>
    
    func load(completion: @escaping (LoadResult) -> Void)
    
}

public class AnyResourceLoader<Resource>: ResourceLoader {
    public typealias LoadResource = Resource
    
    private let loaderObject:  (@escaping (Result<Resource, any Error>) -> Void) -> ()

    public init<L: ResourceLoader>(wrappedLoader: L) where L.LoadResource == Resource {
        self.loaderObject = wrappedLoader.load
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        loaderObject(completion)
    }

}


//
//  AnyLocalLoader.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class AnyLocalLoader<R>: ResourceLoader, ResourceCache {
    public typealias LoadResource = R
    public typealias SaveResource = R
    
    private let wrapped: Any
    private let loaderObject:  (@escaping (Result<R, any Error>) -> Void) -> ()
    private var saverObject:  (R,(@escaping (Result<Void, any Error>) -> Void)) -> ()
    

    public init<L: ResourceLoader & ResourceCache>(wrappedLoader: L) where L.LoadResource == R, L.SaveResource == R, L: Any {
        self.wrapped = wrappedLoader
        self.loaderObject = wrappedLoader.load
        self.saverObject = wrappedLoader.save
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        loaderObject(completion)
    }
    
    public func save(_ resource: R, completion: @escaping (SaveResult) -> Void) {
        saverObject(resource, completion)
    }

}

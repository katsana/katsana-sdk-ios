//
//  ResourceWithParameterStore.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol ResourceWithKeyStore {
    associatedtype Resource where Resource: Equatable
    
    func insert(_ resource: Resource, for key: String) throws
    func retrieve(resourceForKey key: String) throws -> Resource?
    
//    @available(*, deprecated)
//    func insert(_ resource: Resource, for key: String, completion: @escaping (InsertionResult) -> Void)
//
//    @available(*, deprecated)
//    func retrieve(resourceForParameter key: String, completion: @escaping (RetrievalResult) -> Void)
}

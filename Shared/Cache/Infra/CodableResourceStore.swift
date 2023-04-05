//
//  CodableResourceStore.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class CodableResourceStore<R>: ResourceStore where R: Equatable, R: Codable{
    public typealias Resource = R
    
    private struct Cache<R2>: Codable where R2: Codable{
        let resource: R2
        let timestamp: Date
    }
        
    private let storeURL: URL
    private let queue = DispatchQueue(label: "\(CodableResourceStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func deleteCachedResource(completion: @escaping DeletionCompletion){
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(()))
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ resource: Resource, timestamp: Date, completion: @escaping InsertionCompletion){
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(resource: resource, timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion){
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }

            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache<Resource>.self, from: data)
                completion(.success((cache.resource, cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension CodableResourceStore: ResourceWithKeyStore{
    enum LoadError: Error {
        case failed
        case notFound
    }
    
    public func insert(_ resource: R, for key: String) throws {
        var resources: [String: R] = (try? retrieveAll()) ?? [String: R]()
        resources[key] = resource
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(resources)
        try encoded.write(to: storeURL)
    }
    
    public func retrieve(resourceForKey key: String) throws -> R? {
        let storeURL = self.storeURL

        guard let data = try? Data(contentsOf: storeURL) else {
            throw LoadError.failed
        }
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode([String: Resource].self, from: data)
            let resource = cache[key]
            return resource
        } catch {
            throw error
        }
    }
    
    private func retrieveAll() throws -> [String: R] {
        let storeURL = self.storeURL

        guard let data = try? Data(contentsOf: storeURL) else {
            throw LoadError.failed
        }
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode([String: Resource].self, from: data)
            return cache
        } catch {
            throw error
        }
    }
    
}

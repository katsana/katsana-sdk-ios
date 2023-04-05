//
//  AddressStore.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 04/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class CodableAddressStore: ResourceStore{
    public typealias Resource = [KTAddress]
    
    private struct Cache: Codable {
        let resource: Resource
        let timestamp: Date
    }
        
    private let storeURL: URL
    private let queue = DispatchQueue(label: "\(CodableAddressStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
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
        queue.async(flags: .barrier) {[weak self] in
            guard let self else {return}
            
            self.retrieveAddress(runSerially: true) { result in
                do {
                    let encoder = JSONEncoder()
                    let foundCache = try? result.get()
                    var newCache: Cache?
                    if let foundCache{
                        var newResource = [KTAddress]()
                        newResource.append(contentsOf: foundCache.resource)
                        if let first = resource.first{
                            newResource.insert(first, at: 0)
                        }
                        newCache = Cache(resource: newResource, timestamp: timestamp)
                    }else{
                        newCache = Cache(resource: resource, timestamp: timestamp)
                    }
                    let encoded = try encoder.encode(newCache)
                    try encoded.write(to: storeURL)
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        retrieveAddress(completion: completion)
    }
    
    private func retrieveAddress(runSerially: Bool = false, completion: @escaping RetrievalCompletion){
        let storeURL = self.storeURL
        
        func handleRetrieve(){
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success((cache.resource, cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
        
        if runSerially{
            handleRetrieve()
        }else{
            queue.async {
                handleRetrieve()
            }
        }
    }
    
    public func retrieveAddress(with coordinate: (latitude: Double, longitude: Double), completion: @escaping (KTAddress?) -> Void){
        self.retrieve { result in
            if let addresses = try? result.get()?.resource{
                for address in addresses{
                    let coord = Coordinate(latitude: address.latitude, longitude: address.longitude)
                    let otherCoord = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    
                    if coord == otherCoord{
                        completion(address)
                    }
                }
            }else{
                completion(nil)
            }
        }
    }
}


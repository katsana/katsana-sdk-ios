//
//  AddressStore.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 04/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class CodableAddressStore: ResourceStore{
    public typealias Resource = KTAddress
    
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
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success((cache.resource, cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

struct Coordinate{
    let latitude: Double
    let longitude: Double
}

//private extension Double{
//    static let epsilon = 0.005
//
//    func coordinateValueEqual(_ location: Double) -> Bool {
//        if fabs(self - location) < CLLocationCoordinate2D.epsilon {
//            return true
//        }
//        return false
//    }
//}

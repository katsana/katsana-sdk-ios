//
//  CombineHelpers.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 29/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import Combine

public extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
    
    func getPublisher(urlRequest: URLRequest) -> Publisher {
        var task: HTTPClientTask?
        
        return Deferred {
            Future { completion in
                task = self.send(urlRequest, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

public extension ReverseGeocodingClient {
    typealias Publisher = AnyPublisher<KTAddress, Error>
    
    func getPublisher(coordinate: (latitude: Double, longitude: Double)) -> Publisher {
        var task: ReverseGeocodingClientTask?
        return Deferred {
            Future { completion in
               task = self.getAddress(coordinate, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel()})
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func caching<R: ResourceCache>(to cache: R) -> AnyPublisher<Output, Failure> where Output == R.SaveResource{
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher{
    func mapToArray() -> AnyPublisher<[Output], Error> {
        return self
            .map { response -> [Output] in
                return [response]
            }
            .mapError({ error in
                return error
            })
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output: Collection{
    func mapToFirstElementFromArray() -> AnyPublisher<Output.Element, Error> {
        return self
            .map { response -> Output.Element in
                return response.first!
            }
            .mapError({ error in
                return error
            })
            .eraseToAnyPublisher()
    }
}

extension ResourceCache {
    func saveIgnoringResult(_ resource: SaveResource) {
        save(resource) { _ in}
    }
}

public extension AnyLocalLoader {
    
    func loadPublisher() -> AnyPublisher<AnyLocalLoader.LoadResource, Error> {
        Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

public extension LocalResourceWithKeyLoader {
    
    func loadPublisher(key: String) -> AnyPublisher<S.Resource, Error> {
        return Deferred {
            Future { completion in
                completion(Result {
                    try self.loadResource(from:key)
                })
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func caching<R: ResourceWithKeyCache>(to cache: R, using key: String) -> AnyPublisher<Output, Failure> where Output == R.R{
        handleEvents(receiveOutput: { resource in
            cache.saveIgnoringResult(resource, for: key)
        }).eraseToAnyPublisher()
    }
}

extension ResourceWithKeyCache {
    func saveIgnoringResult(_ resource: R, for key: String) {
        try? save(resource, for: key)
    }
}



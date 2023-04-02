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
        return Deferred {
            Future { completion in
                self.getAddress(coordinate, completion: completion)
            }
        }
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

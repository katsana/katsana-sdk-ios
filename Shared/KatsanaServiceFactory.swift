//
//  KatsanaServiceFactory.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import Combine

open class KatsanaServiceFactory{
    let baseURL: URL
    public let baseStoreURL: URL
    let client: HTTPClient
    let reverseGeocodingClient: ReverseGeocodingClient = AppleReverseGeocodingClient()
    let storeManager: ResourceStoreManager
    
    public init(baseURL: URL, baseStoreURL: URL, client: HTTPClient, storeManager: ResourceStoreManager) {
        self.baseURL = baseURL
        self.baseStoreURL = baseStoreURL
        self.client = client
        self.storeManager = storeManager
    }
    
    public func makeUserProfileLoader(includes params: [String]? = nil) -> RemoteLoader<KTUser>{
        let url = UserProfileEndpoint.get(includes: params).url(baseURL: baseURL)
        let remoteLoader = RemoteLoader(url: url, client: client, mapper: UserMapper.map)
        return remoteLoader
    }
    
    public func makeVehicleLoader(vehicleId: Int, includes params: [String]? = nil) -> RemoteLoader<KTVehicle>{
        let url = VehicleEndpoint.get(vehicleId: vehicleId, includes: params).url(baseURL: baseURL)
        return RemoteLoader(url: url, client: client, mapper: VehicleMapper.map)
    }
    
    public func makeVehiclesLoader(includes params: [String]? = nil) -> RemoteLoader<[KTVehicle]>{
        let url = VehicleEndpoint.get(includes: params).url(baseURL: baseURL)
        return RemoteLoader(url: url, client: client, mapper: VehiclesMapper.map)
    }
    
    public func makeLocalLoader<Resource>(_ type: Resource.Type, maxCacheAgeInSeconds: Int) -> AnyLocalLoader<Resource> where Resource: Equatable, Resource: Codable{
        let store = storeManager.getStore(type: type)
        return makeLocalLoader(type, maxCacheAgeInSeconds: maxCacheAgeInSeconds, store: {store})
    }
    
    private func makeLocalLoader<Resource, S: ResourceStore>(_ type: Resource.Type, maxCacheAgeInSeconds: Int, store: ()->S) -> AnyLocalLoader<Resource> where S.Resource == Resource{

        let theStore = store()
        
        let policy = ResourceCachePolicy { maxCacheAgeInSeconds }
        let loader = LocalLoader(store: theStore, cachePolicy: policy, currentDate: Date.init)
        return AnyLocalLoader(wrappedLoader: loader)
    }
    
}

extension KatsanaServiceFactory{
    public func makePublisher<Resource>(
        request:URLRequest,
        includes params: [String]? = nil,
        maxCacheAgeInSeconds: Int = 60,
        mapper: @escaping (Data, HTTPURLResponse) throws -> Resource)
    -> AnyPublisher<Resource, Error> where Resource: Equatable, Resource: Codable{
        let localLoader = makeLocalLoader(Resource.self, maxCacheAgeInSeconds: maxCacheAgeInSeconds)
        let client = self.client
        
        return localLoader
            .loadPublisher()
            .fallback(to: {
                return client
                    .getPublisher(urlRequest: request)
                    .tryMap(mapper)
                    .caching(to: localLoader)
            })
    }
    
    public func makeVehiclesPublisher(includes params: [String]? = nil) -> AnyPublisher<[KTVehicle], Error>{
        let url = VehicleEndpoint.get(includes: params).url(baseURL: baseURL)
        return makePublisher(request: URLRequest(url: url), mapper: VehiclesMapper.map)
    
//        return client
//            .getPublisher(urlRequest: URLRequest(url: url))
//            .tryMap(VehiclesMapper.map)
//            .caching(to: localLoader)
//            .fallback(to: localLoader.loadPublisher)
//            .eraseToAnyPublisher()

    }
    
    public func makeUserPublisher(includes params: [String]? = nil) -> AnyPublisher<KTUser, Error>{
        let url = UserProfileEndpoint.get(includes: params).url(baseURL: baseURL)
        return makePublisher(request: URLRequest(url: url), mapper: UserMapper.map)
    }
    
    public func makeAddressPublisher(coordinate: (latitude: Double, longitude: Double)) -> AnyPublisher<KTAddress, Error>{
        let classname = String(describing: KTAddress.self)
        let url = baseStoreURL.appendingPathComponent(classname + ".store")
        
        let store = CodableResourceStore<KTAddress>(storeURL: url)
        let localLoader = makeLocalLoader(KTAddress.self, maxCacheAgeInSeconds: 60*60*60*24*7, store: {store})
        
        let client = reverseGeocodingClient
        
        struct NotFoundError: Error {}
        
//        return localLoader
//            .loadPublisher()
//            .tryFilter({ addresses in
//                for address in addresses{
//                    if Coordinate(address.latitude, address.longitude) == Coordinate(coordinate.latitude, coordinate.longitude){
//                        return true
//                    }
//                }
//                throw NotFoundError()
//            })
//            .fallback(to: {
//                return client
//                    .getPublisher(coordinate: coordinate)
//                    .mapToArray()
//                    .caching(to: localLoader)
//            })
//            .mapToFirstElementFromArray()
        
        return reverseGeocodingClient
            .getPublisher(coordinate: coordinate)
    }
    
    func mapAddress(address: KTAddress) -> [KTAddress]{
        return [KTAddress(latitude: 0, longitude: 0)]
    }
    
    
}


//
//  KatsanaServiceFactory.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

open class KatsanaServiceFactory{
    let baseURL: URL
    let baseStoreURL: URL
    let client: HTTPClient
    
    public init(baseURL: URL, baseStoreURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.baseStoreURL = baseStoreURL
        self.client = client
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
    
    public func makeLocalLoader<Resource>(_ type: Resource.Type, maxCacheAgeInSeconds: Float) -> LocalLoader<Resource, CodableResourceStore<Resource>>{
        let classname = String(describing: Resource.self)
        let url = baseStoreURL.appendingPathComponent(classname + ".store")
        let loader = LocalLoader(store: CodableResourceStore<Resource>(storeURL: url), currentDate: Date.init)
        return loader
    }
    
}

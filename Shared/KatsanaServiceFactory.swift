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
    public let baseStoreURL: URL
    let client: HTTPClient
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

//
//  KatsanaServiceFactory.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import Combine

open class APIPublisherFactory{
    public let baseURL: URL
    public let baseStoreURL: URL
    public let client: HTTPClient
    let reverseGeocodingClient: ReverseGeocodingClient = AppleReverseGeocodingClient()
    let storeManager: ResourceStoreManager
        
    public lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.katsana.infra.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
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
    
    public func makeInMemoryLoader<Resource>(_ type: Resource.Type) -> AnyLocalLoader<Resource> where Resource: Equatable, Resource: Codable{
        let store = InMemoryResourceStore<Resource>()
        return makeLocalLoader(type, maxCacheAgeInSeconds: 24*60*60*7, store: {store})
    }
    
    private func makeLocalLoader<Resource, S: ResourceStore>(_ type: Resource.Type, maxCacheAgeInSeconds: Int, store: ()->S) -> AnyLocalLoader<Resource> where S.Resource == Resource{

        let theStore = store()
        
        let policy = ResourceCachePolicy { maxCacheAgeInSeconds }
        let loader = LocalLoader(store: theStore, cachePolicy: policy, currentDate: Date.init)
        return AnyLocalLoader(wrappedLoader: loader)
    }
    
}

extension APIPublisherFactory{
    public func makePublisher<Resource>(
        request:URLRequest,
        includes params: [String]? = nil,
        maxCacheAgeInSeconds: Int = 60*60,
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
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    public func makePublisherWithCachedKey<Resource>(
        request:URLRequest,
        includes params: [String]? = nil,
        maxCacheAgeInSeconds: Int = 60*60,
        cacheKey: String,
        mapper: @escaping (Data, HTTPURLResponse) throws -> Resource)
    -> AnyPublisher<Resource, Error> where Resource: Equatable, Resource: Codable{
        let url = baseStoreURL.appendingPathComponent(String(describing: Resource.self) + ".store")
        let store = CodableResourceStore<Resource>(storeURL: url)
        let localLoader = LocalResourceWithKeyLoader(store: store)
        let client = self.client
        
        return localLoader
            .loadPublisher(key: cacheKey)
            .fallback(to: {
                return client
                    .getPublisher(urlRequest: request)
                    .tryMap(mapper)
                    .caching(to: localLoader, using: cacheKey)
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    public func makeVehiclesPublisher(includes params: [String]? = nil, updater: AnyResourceEmitter<KTVehicle>? = nil) -> AnyPublisher<[KTVehicle], Error>{
        let url = VehicleEndpoint.get(includes: params).url(baseURL: baseURL)
        let inMemoryLoader = makeInMemoryLoader([KTVehicle].self)
        let localLoader = makeLocalLoader([KTVehicle].self, maxCacheAgeInSeconds: 60*60*24)
        let client = self.client
        
        let publisher = inMemoryLoader
            .loadPublisher()
            .fallback(to: localLoader.loadPublisher)
            .caching(to: inMemoryLoader)
            .fallback(to: {
                return client
                    .getPublisher(urlRequest: URLRequest(url: url))
                    .tryMap(VehiclesMapper.map)
                    .caching(to: localLoader)
                    .caching(to: inMemoryLoader)
            })
        
        
        
        return publisher
            .mergePublisher(updater?
                .loadPublisher(loader: inMemoryLoader.loadPublisher(), scheduler: scheduler)
                .caching(to: inMemoryLoader)
                .caching(to: localLoader)
            )
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    public func makeUserPublisher(includes params: [String]? = nil) -> AnyPublisher<KTUser, Error>{
        let url = UserProfileEndpoint.get(includes: params).url(baseURL: baseURL)
        return makePublisher(request: URLRequest(url: url), mapper: UserMapper.map)
    }
    
    public func makeTodayTravelSummaryPublisher(vehicleId: Int) -> AnyPublisher<KTDayTravelSummary, Error>{
        let url = TodayTravelSummaryEndpoint.get(vehicleId: vehicleId).url(baseURL: baseURL)
        let key = "\(vehicleId)"
        return makePublisherWithCachedKey(request:  URLRequest(url: url), maxCacheAgeInSeconds: 60*5, cacheKey: key, mapper: DayTravelSummaryMapper.map)
    }
    
    public func makeDayTravelPublisher(vehicleId: Int, date: Date) -> AnyPublisher<KTDayTravel, Error>{
        let url = DayTravelEndpoint.get(vehicleId: vehicleId, date: date).url(baseURL: baseURL)
        let key = "\(vehicleId)_\(String(describing: date))"
        return makePublisherWithCachedKey(request:  URLRequest(url: url), cacheKey: key, mapper: DayTravelMapper.map)
    }
    
    public func makeTripSummaryPublisher(vehicleId: Int, startDate: Date, endDate: Date) -> AnyPublisher<[KTDayTravelSummary], Error>{
        let url = TripSummaryEndpoint.get(vehicleId: vehicleId, fromDate: startDate, toDate: endDate).url(baseURL: baseURL)
        
        return client
            .getPublisher(urlRequest: URLRequest(url: url))
            .tryMap(TripSummariesMapper.map)
            .eraseToAnyPublisher()
    }
    
    public func makeVehicleLiveStreamsPublisher() -> AnyPublisher<[VehicleLiveStream], Error>{
        let url = VehicleLiveStreamsEndpoint.get.url(baseURL: baseURL)
        return makePublisher(request: URLRequest(url: url), mapper: VehicleLiveStreamsMapper.map)
    }
    
    public func makeVehicleLiveStreamPublisher() -> AnyPublisher<VehicleLiveStream, Error>{
        let url = VehicleLiveStreamEndpoint.get.url(baseURL: baseURL)
        return makePublisher(request: URLRequest(url: url), maxCacheAgeInSeconds: 60*5, mapper: VehicleLiveStreamMapper.map)
    }
    
    public func makeAddressPublisher(coordinate: (latitude: Double, longitude: Double)) -> AnyPublisher<KTAddress, Error>{
        let classname = String(describing: KTAddress.self)
        let url = baseStoreURL.appendingPathComponent(classname + ".store")
        
        let inMemoryStore = InMemoryResourceStore<KTAddress>()
        let store = CodableResourceStore<KTAddress>(storeURL: url)
        
        let inMemoryLoader = LocalResourceWithKeyLoader(store: inMemoryStore)
        let localLoader = LocalResourceWithKeyLoader(store: store)

        let client = reverseGeocodingClient
        
        let key = Coordinate(coordinate.latitude, coordinate.longitude).stringRepresentation()
        
        return inMemoryLoader.loadPublisher(key: key)
            .fallback(to: {
                localLoader
                    .loadPublisher(key: key)
                    .caching(to: inMemoryLoader, using: key)
            })
            .fallback(to: {
                return client
                    .getPublisher(coordinate: coordinate)
                    .caching(to: localLoader, using: key)
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    public func makeImagePublisher(client: HTTPClient, url: URL, defaultImageData: Data?) -> AnyPublisher<Data, Error>{
        let name = url.pathComponents.count > 2 ? (url.pathComponents[url.pathComponents.count-2] + "_" + url.lastPathComponent) : url.absoluteString
        let storeURL = baseStoreURL.appendingPathComponent(name)
        
        let store = CodableResourceStore<Data>(storeURL: storeURL)
        let localLoader = LocalResourceWithKeyLoader(store: store)

        let request = URLRequest(url: url)
        let key = url.absoluteString
        
        let anError = NSError()
        
        return localLoader
            .loadPublisher(key: key)
            .fallback(to: {
                return client
                    .getPublisher(urlRequest: request)
                    .tryMap({ data, response in
                        if !(200...299).contains(response.statusCode){
                            if (400...410).contains(response.statusCode), let defaultImageData{
                                try? localLoader.save(defaultImageData, for: key)
                                return defaultImageData
                            }
                            throw anError
                        }
                        return data
                    })
                    .caching(to: localLoader, using: key)
                    .eraseToAnyPublisher()
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
}

private let vehicleEmitterSubject = PassthroughSubject<[KTVehicle],Error>()

extension AnyResourceEmitter where Resource == KTVehicle{
    func loadPublisher(loader: AnyPublisher<[KTVehicle], Error>, scheduler: AnyDispatchQueueScheduler) -> AnyPublisher<[KTVehicle], Error>{
        didEmitResource = { vehicle in
            let _ = loader.sink { completion in
            } receiveValue: { vehicles in
                var theVehicles = vehicles
                let idx = theVehicles.firstIndex { aVehicle in
                    return aVehicle.imei == vehicle.imei
                }
                if let idx{
                    theVehicles[idx] = vehicle
                    vehicleEmitterSubject.send(theVehicles)
                }
            }
        }
        return vehicleEmitterSubject.subscribe(on: scheduler).eraseToAnyPublisher()
    }
}

extension AnyPublisher<[KTVehicle], Error> {
    func mergePublisher(_ publisher: AnyPublisher<[KTVehicle], Error>?) -> AnyPublisher<[KTVehicle], Error>{
        guard let publisher else{
            return self
        }
        return merge(with: publisher).eraseToAnyPublisher()
    }
}


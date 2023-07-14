//
//  APIPublisherFactoryTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 14/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import Combine
@testable import KatsanaSDK

final class APIPublisherFactoryTests: XCTestCase, ResourceStoreManagerDelegate {
    override func setUpWithError() throws {
        try? InMemoryResourceStore<[KTVehicle]>().deleteCachedResource()
        let classname = String(describing: [KTVehicle].self)
        let url = localStoreURL.appendingPathComponent("sdk_tests_" + classname + ".store")
        try? FileManager().removeItem(at: url)
    }

    override func tearDownWithError() throws {
        try? InMemoryResourceStore<[KTVehicle]>().deleteCachedResource()
        let classname = String(describing: [KTVehicle].self)
        let url = localStoreURL.appendingPathComponent("sdk_tests_" + classname + ".store")
        try? FileManager().removeItem(at: url)
    }
    
    
    func test_makeVehiclesPublisher_updaterWorksCorrectly(){
        let (sut, stub) = makeSUT()
        let updater = VehicleUpdaterStub()
        let publisher = sut.makeVehiclesPublisher(updater: updater)
        
        stub.addStubForAnyURL(data: self.makeVehiclesData())
        
        let exp = expectation(description: "Wait for load completion")
        exp.expectedFulfillmentCount = 4
        
        var count = 0
        let cancellable = publisher.sink { completion in
        } receiveValue: { vehicles in
            XCTAssertEqual(vehicles.count, 2)
            let firstVehicle = vehicles.first
            if count == 0{
                XCTAssertEqual(firstVehicle?.vehicleNumber, "SS2575")
            }
            else if count == 1{
                XCTAssertEqual(firstVehicle?.vehicleNumber, "test1")
            }
            exp.fulfill()
            count += 1
        }
        
        func makeVehicle(_ vehicleNumber: String) -> KTVehicle{
            let vehicle = KTVehicle(vehicleId: 1, userId: 80, imei: "1123456")
            vehicle.vehicleNumber = vehicleNumber
            return vehicle
        }
        
        updater.send(makeVehicle("test1"))
        updater.send(makeVehicle("test2"))
        updater.send(makeVehicle("test3"))
        
        wait(for: [exp], timeout: 1)
    }
    
    
    // MARK: Helper
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (APIPublisherFactory, HTTPClientStub) {
        let spy = HTTPClientStub()
        let factory = APIPublisherFactory(baseURL: anyURL(), baseStoreURL: anyURL(), client: spy, storeManager: ResourceStoreManager(delegate: self))
        factory.scheduler = .immediateOnMainQueue
        return (factory, spy)
    }
    
    func makeStore<Resource, S>(_ type: Resource.Type) -> KatsanaSDK.AnyResourceStore<Resource> where Resource : Decodable, Resource : Encodable, Resource : Equatable, S : KatsanaSDK.AnyResourceStore<Resource> {
        let classname = String(describing: Resource.self)
        let url = localStoreURL.appendingPathComponent("sdk_tests_" + classname + ".store")
        let store = CodableResourceStore<Resource>(storeURL: url)
        let anyStore = AnyResourceStore(store)
        return anyStore
    }
    
    private lazy var localStoreURL: URL = {
        let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectoryPath = arrayPaths[0]
        return cacheDirectoryPath
    }()
    
    func makeVehiclesData() -> Data {
        let user = """
{
  "devices": [
    {
      "id": 1,
      "user_id": 80,
      "imei": "1123456",
      "description": "Focus",
      "vehicle_number": "SS2575",
      "manufacturer": "Ford",
      "model": "Focus",
      "mode": "working",
      "current": {
        "latitude": 3.0339383,
        "longitude": 101.767635,
        "speed": 36.717075,
        "state": "moving",
        "ignition": 1,
        "voltage": 14316,
        "battery": 90,
        "gsm": 3,
        "tracked_at": "2023-03-21 07:21:05"
      },
      "earliest_date": "2022-03-21",
      "fleets": [
        1,
        2
      ]
    },
    {
      "id": 2,
      "user_id": 81,
      "imei": "987654",
      "description": "FMS232 Device",
      "vehicle_number": "FMS232",
      "meta": {
        "today": {
          "date": "2020-06-17",
          "max_speed": 0
        },
        "websocket": true
      },
      "mode": "working",
      "current": {
        "latitude": 3.0089633,
        "longitude": 101.75814,
        "speed": 0,
        "state": "offline",
        "ignition": 0,
        "voltage": 0,
        "battery": null,
        "gsm": 4,
        "tracked_at": "2020-06-17 04:50:07"
      }
    }
  ]
}
"""
        let json = try! convertStringToDictionary(text: user)
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

class HTTPClientStub: HTTPClient{
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    
    var stubs = [URL: Data]()
    var otherURLStub: Data?
    
    func addStub(url: URL, data: Data){
        stubs[url] = data
    }
    
    func addStubForAnyURL(data: Data){
        otherURLStub = data
    }
    
    func send(_ urlRequest: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> KatsanaSDK.HTTPClientTask {
        if let stub = stubs[urlRequest.url!]{
            completion(.success((stub, .init(statusCode: 200))))
        }else if let otherURLStub{
            completion(.success((otherURLStub, .init(statusCode: 200))))
        }else{
            completion(.failure(anyNSError()))
        }
        return Task { [weak self] in
        }
    }
}

class VehicleUpdaterStub: VehicleUpdater{
    var didUpdateVehicle: ((KTVehicle) -> Void)?
    
    func send(_ vehicle: KTVehicle){
        didUpdateVehicle?(vehicle)
    }
    
}

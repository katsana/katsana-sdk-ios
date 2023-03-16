//
//  KatsanaServicesTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 14/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

final class KatsanaServicesFactoryTests: XCTestCase {

    func test_loadUserProfile_deliverUserProfile() throws {
        
        let (sut, client) = makeSUT()
        let loader = sut.makeUserProfileLoader()
        let (user, json) = makeUser(id: 232, email: anyEmail())
        expect(loader, toCompleteWith: .success(user)) {
            let data = makeJSON(json)
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_loadVehicles_deliverVehicles() throws {
        let (sut, client) = makeSUT()
        let loader = sut.makeVehiclesLoader()
        let (vehicle1, json1) = makePartialVehicle(vehicleId: 1, userId: 20, imei: "imei1")
        let (vehicle2, json2) = makePartialVehicle(vehicleId: 2, userId: 30, imei: "imei2")
        let theJson = ["devices": [json1, json2]]
        
        expect(loader, toCompleteWith: .success([vehicle1, vehicle2])) {
            let data = makeJSON(theJson)
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    // MARK: Helper
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: KatsanaServiceFactory, client: HTTPClientSpy){
        let url = URL(string: "https://anyurl.com/")!
        let client = HTTPClientSpy()
        
        let factory = KatsanaServiceFactory(baseURL: url, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(factory, file: file, line: line)
        
        return (factory, client)
    }
    
    
    private func expect<Resource>(_ sut: RemoteLoader<Resource>, toCompleteWith expectedResult: RemoteLoader<Resource>.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) where Resource: Equatable {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func anyEmail() -> String{
        return "any@email.com"
    }

}

//class KatsanaServicesSpy: KatsanaServices{
//    let client: URLSessionHTTPClient
//    
//    init(session: URLSession = URLSession(configuration: .ephemeral)) {
//        self.client = URLSessionHTTPClient(session: session)
//    }
//    
//    func getUserProfile(completion: Result<KTUser, Error>) {
//        
//    }
//    
//}

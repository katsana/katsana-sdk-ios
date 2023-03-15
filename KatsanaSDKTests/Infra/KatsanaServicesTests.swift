//
//  KatsanaServicesTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 14/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class KatsanaServiceFactory{
    let baseURL: URL
    let client: HTTPClient
    
    init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    func makeUserProfileLoader(includes params: [String]? = nil) -> RemoteLoader<KTUser>{
        let url = UserProfileEndpoint.get(includes: params).url(baseURL: baseURL)
        return RemoteLoader(url: url, client: client, mapper: UserMapper.map)
    }
    
}

final class KatsanaServicesTests: XCTestCase {

    func test_loadUserProfile_deliverUserProfile() throws {
        let url = URL(string: "https://api.katsana.com/")!
        let client = HTTPClientSpy()
        
        let factory = KatsanaServiceFactory(baseURL: url, client: client)
        let (user, json) = makeUser(id: 232, email: anyEmail())
        
        let loader = factory.makeUserProfileLoader()
        expect(loader, toCompleteWith: .success(user)) {
            let data = makeJSON(json)
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    // MARK: Helper
    
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

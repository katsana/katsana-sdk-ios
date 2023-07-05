//
//  LoginServiceTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

public protocol LoginService{
    func login(email: String, password: String, completion: @escaping (TokenService.Result) -> Void)
}

class HTTPLoginService: LoginService{
    let baseURL: URL
    let credential: Credential
    let httpClient: HTTPClient
    
    init(baseURL: URL, credential: Credential, httpClient: HTTPClient) {
        self.credential = credential
        self.baseURL = baseURL
        self.httpClient = httpClient
    }
    
    func login(email: String, password: String, completion: @escaping (Result<AccessToken, Error>) -> Void) {
        let url = LoginEndpoint.get.url(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? credential.data()
        
        httpClient.send(request) {result in
            switch result{
            case .success((let data, let response)):
                do{
                    let token = try LoginMapper.map(data, from: response)
                    completion(.success(token))
                }
                catch{
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

final class HTTPLoginServiceTests: XCTestCase {
    func test_init_doesNotSendRequest() {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.requests.count, 0)
    }
    
    // MARK: Helper
    
    func makeSUT() -> (HTTPLoginService, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = HTTPLoginService(baseURL: anyURL(), credential: anyCredential(), httpClient: client)
        return (sut, client)
    }
    
//    private func expect(_ sut: TokenServiceStub, toCompleteWith expectedResult: TokenService.Result, file: StaticString = #file, line: UInt = #line){
//        let exp = expectation(description: "Wait for load completion")
//
//        sut.getToken { receivedResult in
//            switch (receivedResult, expectedResult) {
//            case let (.success(receivedData), .success(expectedData)):
//                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
//
//            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
//                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
//
//            default:
//                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
//            }
//
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 1.0)
//    }
//    
    func anyCredential() -> Credential{
        return Credential(clientId: "", clientSecret: "", scope: "", grantType: "")
    }
}

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
    func login(email: String, password: String, completion: @escaping (AccessTokenResult) -> Void)
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
        httpClient.send(loginRequest()) {result in
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
    
    func loginRequest() -> URLRequest{
        let url = LoginEndpoint.get.url(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? credential.data()
        return request
    }
    
}

final class HTTPLoginServiceTests: XCTestCase {
    func test_init_doesNotSendRequest() {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.requests.count, 0)
    }
    
    func test_login_sendLoginRequest() {
        let (sut, client) = makeSUT()
        let request = sut.loginRequest()
        sut.login(email: "any", password: "any"){_ in}
        
        XCTAssertEqual(client.requests, [request])
    }
    
    func test_loginTwice_sendLoginRequestTwice() {
        let (sut, client) = makeSUT()
        let request = sut.loginRequest()
        sut.login(email: "any", password: "any"){_ in}
        sut.login(email: "any", password: "any"){_ in}
        
        XCTAssertEqual(client.requests, [request, request])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
//        expect(sut, toCompleteWith: .fail) {
//            let clientError = NSError(domain: "Test", code: 0)
//            client.complete(with: clientError)
//        }
    }
    
    // MARK: Helper
    
    func makeSUT(credential: Credential? = nil) -> (HTTPLoginService, HTTPClientSpy){
        let client = HTTPClientSpy()
        let acredential = credential ?? anyCredential()
        let sut = HTTPLoginService(baseURL: anyURL(), credential: acredential, httpClient: client)
        return (sut, client)
    }
    
    private func expect(_ sut: LoginService, toCompleteWith expectedResult: AccessTokenResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.login(email: "any", password: "any") { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
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
    
    func anyCredential() -> Credential{
        return Credential(clientId: "", clientSecret: "", scope: "", grantType: "")
    }
}

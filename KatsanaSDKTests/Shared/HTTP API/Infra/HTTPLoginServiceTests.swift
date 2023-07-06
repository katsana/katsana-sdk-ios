//
//  LoginServiceTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

final class HTTPLoginServiceTests: XCTestCase {
    func test_init_doesNotSendRequest() {
        let (_, client) = makeSUT()
        XCTAssertEqual(client.requests.count, 0)
    }
    
    func test_login_sendLoginRequest() {
        let (sut, client) = makeSUT()
        let request = sut.loginRequest(email: "any", password: "any")
        sut.login(email: "any", password: "any"){_ in}
        
        XCTAssertEqual(client.requests, [request])
    }
    
    func test_loginTwice_sendLoginRequestTwice() {
        let (sut, client) = makeSUT()
        let request = sut.loginRequest(email: "any", password: "any")
        sut.login(email: "any", password: "any"){_ in}
        sut.login(email: "any", password: "any"){_ in}
        
        XCTAssertEqual(client.requests, [request, request])
    }
    
    func test_login_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let error = anyNSError()
        expect(sut, toCompleteWith: .failure(error)) {
            client.complete(with: error)
        }
    }
    
    func test_load_deliversErrorOnResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(LoginMapper.Error.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let json = makeLoginData()
        let mapper = LoginMapper(name: "any")
        let token = try! mapper.map(json, from: .init(statusCode: 200))
        
        expect(sut, toCompleteWith: .success(token), when: {
            client.complete(withStatusCode: 200, data: json)
        })
    }

//    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
//        let client = HTTPClientSpy()
//        let acredential = anyCredential()
//        var sut: HTTPLoginService? = HTTPLoginService(baseURL: anyURL(), credential: acredential, httpClient: client)
//
//        var capturedResults = [AccessTokenResult]()
//        sut?.login(email: "any", password: "any") { capturedResults.append($0) }
//
//        sut = nil
//        client.complete(withStatusCode: 200, data: makeLoginData())
//
//        XCTAssertTrue(capturedResults.isEmpty)
//    }
    
    // MARK: Helper
    
    func makeSUT(credential: Credential? = nil) -> (HTTPLoginService, HTTPClientSpy){
        let client = HTTPClientSpy()
        let acredential = credential ?? anyCredential()
        let sut = HTTPLoginService(baseURL: anyURL(), credential: acredential, httpClient: client)
        
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        
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
    
    func makeInvalidLoginData() -> Data{
        let text = """
{"invalid":"aTokenString","invalid2":"aRefreshTokenString"}
"""
        return Data(text.utf8)
    }
    
    func makeLoginData() -> Data{
        let text = """
{"token_type":"Bearer","expires_in":31622400,"access_token":"aTokenString","refresh_token":"aRefreshTokenString"}
"""
        return Data(text.utf8)
    }
}

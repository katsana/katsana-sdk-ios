//
//  AuthenticatedHTTPClientDecorator.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

final class AuthenticatedHTTPClientDecoratorTests: XCTestCase {
    
    func test_sendRequest_withFailedTokenRequest_fails(){
        let unsignedRequest = testRequest()
        let (sut, client) = makeSUT(tokenResult: .failure(anyNSError()))
        
        _ = sut.send(unsignedRequest, completion: {_ in})
        
        XCTAssertEqual(client.requests, [])
    }
    
    func test_sendRequest_withSuccessTokenSuccess_signRequestWithToken(){
        
        let request = testRequest()
        let token = anyToken()
        let (sut, client) = makeSUT(tokenResult: .success(token))
        
        let signedRequest = sut.signedRequest(for: request, token: token)
        _ = sut.send(request, completion: {_ in})
        
        XCTAssertEqual(client.requests, [signedRequest])
    }
    
    func test_sendRequest_withSuccessTokenRequest_completesWithDecorateeResult() throws{
        let request = testRequest()
        let values = (Data("anyData".utf8), HTTPURLResponse(statusCode: 200))
        
        let token = anyToken()
        let (sut, client) = makeSUT(tokenResult: .success(token))
        
        var receivedResult: HTTPClient.Result?
        _ = sut.send(request, completion: { receivedResult = $0})
        client.complete(withStatusCode: 200, data: values.0)
        
        let receivedValues = try XCTUnwrap(receivedResult).get()
        XCTAssertEqual(receivedValues.0, values.0)
        XCTAssertEqual(receivedValues.1.statusCode, values.1.statusCode)
    }

    
    // MARK: Helpers
    
    func makeSUT(tokenResult: AccessTokenResult, file: StaticString = #filePath, line: UInt = #line) -> (sut: AuthenticatedHTTPClientDecorator, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let tokenStub = TokenServiceStub(stub: tokenResult)
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, tokenService: tokenStub, username: {"any"})
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(tokenStub, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    func testRequest() -> URLRequest{
        return URLRequest(url: URL(string: "/test")!)
    }
    
    func anyToken() -> AccessToken{
        return AccessToken(name: "any", token: "any")
    }

}



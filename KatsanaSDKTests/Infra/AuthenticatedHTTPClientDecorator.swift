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
    
    func test_sendRequest_withNoTokenReturnEmptyRequest(){
        let unsignedRequest = testRequest()
        let (sut, client) = makeSUT(tokenResult: .failure(anyNSError()))
        
        _ = sut.send(unsignedRequest, completion: {_ in})
        
        XCTAssertEqual(client.requests, [])
    }
    
    func test_sendRequest_withTokenReturnSuccesfulRequest(){
        
        let request = testRequest()
        let (sut, client) = makeSUT(tokenResult: .success(AccessToken(token: "anyToken")))

        _ = sut.send(request, completion: {_ in})
        
        XCTAssertEqual(client.requests.count, 1)
    }

    
    // MARK: Helpers
    
    func makeSUT(tokenResult: TokenService.Result, file: StaticString = #filePath, line: UInt = #line) -> (sut: AuthenticatedHTTPClientDecorator, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let tokenStub = TokenServiceStub(stub: tokenResult)
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, tokenService: tokenStub)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(tokenStub, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    func testRequest() -> URLRequest{
        return URLRequest(url: URL(string: "/test")!)
    }

}



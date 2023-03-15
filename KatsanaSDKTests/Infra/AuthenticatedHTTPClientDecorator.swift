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
        let client = HTTPClientSpy()
        let unsignedRequest = testRequest()
        
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client)
        _ = sut.send(unsignedRequest, completion: {_ in})
        
        XCTAssertEqual(client.requests, [])
    }
    
    func test_sendRequest_withTokenReturnRequest(){
        let client = HTTPClientSpy()
        let request = testRequest()
        
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client)
        sut.sign(AccessToken(token: "anyToken"))
        let signedRequest = try? sut.signedRequest(for: request)
        
        _ = sut.send(request, completion: {_ in})
        
        XCTAssertEqual(client.requests, [signedRequest])
    }

    
    // MARK: Helpers
    
    func testRequest() -> URLRequest{
        return URLRequest(url: URL(string: "/test")!)
    }

}

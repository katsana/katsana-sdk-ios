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
        let tokenStub = TokenServiceStub(stub: .failure(anyNSError()))
        
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, tokenService: tokenStub)
        _ = sut.send(unsignedRequest, completion: {_ in})
        
        XCTAssertEqual(client.requests, [])
    }
    
    func test_sendRequest_withTokenReturnSuccesfulRequest(){
        let client = HTTPClientSpy()
        let request = testRequest()
        let tokenStub = TokenServiceStub(stub: .success(AccessToken(token: "anyToken")))
        
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, tokenService: tokenStub)

        _ = sut.send(request, completion: {_ in})
        
        XCTAssertEqual(client.requests.count, 1)
    }

    
    // MARK: Helpers
    
    func testRequest() -> URLRequest{
        return URLRequest(url: URL(string: "/test")!)
    }

}

class TokenServiceStub: TokenService{
    let stub: Result<AccessToken, Error>
    
    init(stub: Result<KatsanaSDK.AccessToken, Error>) {
        self.stub = stub
    }
    
    func getToken(completion: (Result<KatsanaSDK.AccessToken, Error>) -> Void) {
        completion(stub)
    }
    
    
}

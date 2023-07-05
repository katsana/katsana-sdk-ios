//
//  KatsanaAPITests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class KatsanaAPI{
    let tokenService: TokenService
    
    var isAuthenticated = false
    
    init(tokenService: TokenService) {
        self.tokenService = tokenService
    }
    
    func login(email: String, password: String, completion: @escaping (TokenService.Result) -> Void){
        tokenService.getToken {[weak self] result in
            self?.isAuthenticated = ((try? result.get()) != nil)
            completion(result)
        }
    }
}

final class KatsanaAPITests: XCTestCase {
    
    func test_init_isNotAuthenticated() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isAuthenticated)
    }
    
    func test_login_changeToAuthenticatedWhenSuccess() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")

        sut.login(email: "test", password: "1212") { result in
            if let _ = try? result.get(){
                //Do nothing
            }else{
                XCTFail("Expected to success")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(sut.isAuthenticated)
    }
    
    func test_login_doesNotAuthenticateWhenFailure() {
        let tokenStub = TokenServiceStub(stub: .failure(anyNSError()))
        let sut = makeSUT(tokenService: tokenStub)
        let exp = expectation(description: "Wait for load completion")
        
        sut.login(email: "test", password: "wrongPass") { result in
            if let _ = try? result.get(){
                XCTFail("Expected to fail")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        XCTAssertFalse(sut.isAuthenticated)
    }
    
    func makeSUT(tokenService: TokenService? = nil) -> KatsanaAPI{
        let theTokenService = tokenService ?? TokenServiceStub(stub: .success(AccessToken(token: "any")))
        let sut = KatsanaAPI(tokenService: theTokenService)
        return sut
    }
    
}

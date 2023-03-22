//
//  TokenServiceTests.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

final class TokenServiceTests: XCTestCase {
    func test_get_failsOnFailure() {
        let sut = TokenServiceStub(stub: .failure(anyNSError()))
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_get_successOnSuccess() {
        let token = AccessToken(token: "anytoken")
        
        let sut = TokenServiceStub(stub: .success(token))
        expect(sut, toCompleteWith: .success(token))
    }
    
    // MARK: Helper
    
    private func expect(_ sut: TokenServiceStub, toCompleteWith expectedResult: TokenService.Result, file: StaticString = #file, line: UInt = #line){
        let exp = expectation(description: "Wait for load completion")

        sut.getToken { receivedResult in
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
        wait(for: [exp], timeout: 1.0)
    }
}

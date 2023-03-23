//
//  XCTestCase+FailableInsertResourceStoreSpecs.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

extension FailableInsertResourceStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError<R: ResourceStore>(resource: R.Resource, on sut: R, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((resource, Date()), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError<R: ResourceStore>(resource: R.Resource, on sut: R, file: StaticString = #file, line: UInt = #line) {
        insert((resource, Date()), to: sut)
        
        expect(sut, toRetrieve: .success(.none) , file: file, line: line)
    }
}


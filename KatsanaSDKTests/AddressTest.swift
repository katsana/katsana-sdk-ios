//
//  AddressTest.swift
//  KatsanaSDKmacOSTests
//
//  Created by Wan Ahmad Lutfi on 01/02/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
@testable import KatsanaSDK
import URLMock
import Siesta
import CoreLocation

final class AddressTest: XCTestCase {
    func test_createAddress_setProperly() throws {
        let sut = makeSUT()
        let address = KTAddress(latitude: 10, longitude: 20)
        address.streetName = "PT3000"
        
        sut.cache(address: address)
        
        let expectation = XCTestExpectation(description: "Request address successfully")
        sut.address(for: CLLocationCoordinate2D(latitude: 10, longitude: 20), completion: { theAddress in
            if let theAddress{
                XCTAssertEqual(theAddress.streetName, "PT3000")
                expectation.fulfill()
            }else{
                XCTFail()
            }
        })
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_createAddress_cachedProperly() throws {
        let sut = makeSUT()
        let address = KTAddress(latitude: 10, longitude: 20)
        address.streetName = "PT3000"
        
        sut.cache(address: address)
        
        XCTAssertEqual(sut.loadCachedAddresses().first!.streetName, "PT3000")
    }
    
    func makeSUT() -> KTCacheManager{
        return KTCacheManager()
    }

}

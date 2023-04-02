//
//  CLPlaceMarkAddressMapperTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 02/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK
import CoreLocation
import Intents
import Contacts

class CLPlaceMarkAddressMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        
        let placemark = makeCLPlacemark(location: anyLocation(), name: "test")
        let address = try! CLPlaceMarkAddressMapper.map(placemark)
        
        XCTAssertNotNil(placemark.location)
        
        XCTAssertEqual(placemark.location!.coordinate.latitude, anyLocation().coordinate.latitude)
        XCTAssertEqual(placemark.location!.coordinate.longitude, anyLocation().coordinate.longitude)
    }
    
    // MARK: - Helpers
    
    private func makeCLPlacemark(location: CLLocation, name: String) -> CLPlacemark {
        let placemark = CLPlacemark(location: anyLocation(),
                                     name: "any name",
                                     postalAddress: nil)
        
        return placemark
    }
    
    func anyLocation() -> CLLocation{
        return CLLocation(latitude: anyCoordinate().latitude, longitude: anyCoordinate().longitude)
    }
    
    func address(with location: CLLocation) -> KTAddress{
        return KTAddress(latitude: anyLocation().coordinate.latitude, longitude: anyLocation().coordinate.longitude)
    }
    
}

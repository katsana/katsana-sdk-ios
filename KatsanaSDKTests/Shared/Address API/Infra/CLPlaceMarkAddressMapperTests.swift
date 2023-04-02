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
import MapKit

class CLPlaceMarkAddressMapperTests: XCTestCase {
    
    func test_map_placemarkSuccessfully() throws {
        
        let placemark = makeCLPlacemark(location: anyLocation())
        let address = try! CLPlaceMarkAddressMapper.map(placemark)
        
        XCTAssertNotNil(placemark.location)
        XCTAssertEqual(address.latitude, anyLocation().coordinate.latitude)
        XCTAssertEqual(address.longitude, anyLocation().coordinate.longitude)
        XCTAssertEqual(address.streetName, "any thoroughfare")
//        XCTAssertEqual(placemark.subThoroughfare, "any subThoroughfare")
        XCTAssertEqual(address.city, "any locality")
        XCTAssertEqual(address.sublocality, "any subLocality")
        XCTAssertEqual(address.postcode, "any postalCode")
        XCTAssertEqual(address.state, "any administrativeArea")
        XCTAssertEqual(address.locality, "any locality")
        XCTAssertEqual(address.subAdministrativeArea, "any subAdministrativeArea")
    }
    
    // MARK: - Helpers
    
    
    
    private func makeCLPlacemark(location: CLLocation) -> CLPlacemark {
        let placemark = StubCLPlacemark(location: location, thoroughfare: "any thoroughfare", subThoroughfare: "any subThoroughfare", locality: "any locality", subLocality: "any subLocality", administrativeArea: "any administrativeArea", subAdministrativeArea: "any subAdministrativeArea", postalCode: "any postalCode", country: "any country")
        
        return placemark
    }
    
    func anyLocation() -> CLLocation{
        return CLLocation(latitude: anyCoordinate().latitude, longitude: anyCoordinate().longitude)
    }
    
    func address(with location: CLLocation) -> KTAddress{
        return KTAddress(latitude: anyLocation().coordinate.latitude, longitude: anyLocation().coordinate.longitude)
    }
    
}

private class StubCLPlacemark: MKPlacemark{
    
    convenience init(location: CLLocation, thoroughfare: String = "", subThoroughfare: String = "", locality: String = "", subLocality: String = "", administrativeArea: String = "", subAdministrativeArea: String = "", postalCode: String = "", country: String = "") {
        
        //It seems when setting the dictionary, it may have conflict with internal name, so we add `a` as prefix to avoid that for some keys.
        self.init(coordinate: location.coordinate, addressDictionary: ["thoroughfare": thoroughfare, "aSubThoroughfare": subThoroughfare, "locality": locality, "aSubLocality": subLocality, "administrativeArea": administrativeArea, "aSubAdministrativeArea": subAdministrativeArea, "aPostalCode": postalCode, "country": country])
    }
    
    open override var thoroughfare: String? { getValue(key: "thoroughfare")}
    open override var subThoroughfare: String?  {return getValue(key: "aSubThoroughfare")}
    open override var locality: String?  {return getValue(key: "locality")}
    open override var subLocality: String?  {return getValue(key: "aSubLocality")}
    open override var administrativeArea: String?  {return getValue(key: "administrativeArea")}
    open override var subAdministrativeArea: String?  {return getValue(key: "aSubAdministrativeArea")}
    open override var postalCode: String?  {return getValue(key: "aPostalCode")}
    open override var country: String?  {return getValue(key: "country")}
    
    func getValue(key: String) -> String?{
        let val = addressDictionary![key] as? String
        if let val, val.count > 0{
            return val
        }
        return nil
    }
    
}



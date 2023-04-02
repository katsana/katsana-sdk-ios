//
//  CLPlaceMarkMapper.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 02/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import CoreLocation

public class CLPlaceMarkAddressMapper{
    public enum Error: Swift.Error {
        case noLocation
    }
    
    public static func map(_ placemark: CLPlacemark) throws -> KTAddress {
        guard let location = placemark.location else{
            throw Error.noLocation
        }
        
        let address = KTAddress()
        address.latitude = location.coordinate.latitude
        address.longitude = location.coordinate.longitude
        address.streetName = placemark.thoroughfare
        address.postcode = placemark.postalCode
        
        address.country = placemark.country
        address.city = placemark.locality
        address.state = placemark.administrativeArea
        address.sublocality = placemark.subLocality
        address.locality = placemark.locality
        address.subAdministrativeArea = placemark.subAdministrativeArea
        return address
    }
}

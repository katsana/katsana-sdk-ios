//
//  Address.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 27/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import CoreLocation

open class Address: NSObject {
    open var latitude: Double
    open var longitude: Double
    open var streetNumber: String!
    open var streetName: String!
    open var locality: String!
    open var sublocality: String!
    open var postcode: Int = -1
    open var country: String!
    
    open var address: String!
    open var updateDate = Date()
    
    override open class func fastCodingKeys() -> [Any]?{
        return ["latitude", "longitude", "streetNumber", "streetName", "locality", "sublocality", "postcode", "country", "address", "updateDate"]
    }
    
    override public init() {
        self.latitude = 0
        self.longitude = 0
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    
    open func optimizedAddress() -> String {
        var components = [String]()
        if let streetNumber = streetNumber, streetNumber.characters.count > 0 {
            components.append(streetNumber)
        }
        if let streetName = streetName, streetName.characters.count > 0 {
            components.append(streetName)
        }
        if let sublocality = sublocality, sublocality.characters.count > 0{
            components.append(sublocality)
        }
        var address = components.joined(separator: ", ")
        if address.characters.count == 0 {
            return self.address
        }
        return address
    }
    
//    func optimizedAddressWithCountry() -> String {
//        var components = [String]()
//        if let streetNumber = streetNumber, streetNumber.characters.count > 0 {
//            components.append(streetNumber)
//        }
//        if let streetName = streetName, streetName.characters.count > 0 {
//            components.append(streetName)
//        }
//        if let sublocality = sublocality, sublocality.characters.count > 0{
//            components.append(sublocality)
//        }
//        var address = components.joined(separator: ", ")
//        if address.characters.count == 0 {
//            return self.address
//        }
//        return address
//    }
    
    open func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}

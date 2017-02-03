//
//  Address.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 27/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import UIKit
import CoreLocation

public class Address: NSObject {
    public var latitude: Double
    public var longitude: Double
    public var streetNumber: String!
    public var streetName: String!
    public var locality: String!
    public var sublocality: String!
    public var postcode: Int = -1
    public var country: String!
    
    public var address: String!
    public var updateDate = Date()
    
    override public class func fastCodingKeys() -> [Any]?{
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
    
    
    public func optimizedAddress() -> String {
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
    
    public func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}

//
//  Address.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 27/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import UIKit

public class Address: NSObject {
    var latitude: Double!
    var longitude: Double!
    var streetNumber: String!
    var streetName: String!
    var locality: String!
    var sublocality: String!
    var postcode: Int!
    var country: String!
    
    var address: String!
    var updateDate = Date()
    
    func optimizedAddress() -> String {
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
    
    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}

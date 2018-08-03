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
    open var subAdministrativeArea: String!
    open var postcode: Int = -1
    open var city: String!
    open var state: String!
    open var country: String!
    
    open var address: String!
    open var updateDate = Date()
    
    override open class func fastCodingKeys() -> [Any]?{
        return ["latitude", "longitude", "streetNumber", "streetName", "locality", "sublocality", "city", "postcode", "country", "address", "updateDate", "state", "subAdministrativeArea"]
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
        if let streetNumber = streetNumber, streetNumber.count > 0 {
            components.append(streetNumber)
        }
        if let streetName = streetName, streetName.count > 0 {
            components.append(streetName)
        }
        if let sublocality = sublocality, sublocality.count > 0{
            components.append(sublocality)
        }
        if let city = city, city.count > 0{
            if let sublocality = sublocality, city == sublocality{
                //Do nothing
            }else{
                components.append(city)
            }
        }
        var address = components.joined(separator: ", ")
        if address.count == 0 {
            if self.address != nil {
                address = self.address
            }
        }
        return address
    }
    
    open func fullAddress() -> String {
        var components = [String]()
        if let streetNumber = streetNumber, streetNumber.count > 0 {
            components.append(streetNumber)
        }
        if let streetName = streetName, streetName.count > 0 {
            components.append(streetName)
        }
        if let sublocality = sublocality, sublocality.count > 0{
            components.append(sublocality)
        }
        if postcode > 0{
            let post = "\(postcode)"
            components.append(post)
        }
        if let locality = locality, locality.count > 0{
            components.append(locality)
        }
        if let city = city, city.count > 0{
            components.append(city)
        }
        
        if let state = state, state.count > 0{
            components.append(state)
        }
        var address = components.joined(separator: ", ")
        if address.count == 0 {
            if self.address != nil {
                address = self.address
            }
        }
        return address
    }
    
    open func pointOfInterest() -> String{
        if let sublocality = sublocality, sublocality.count > 0{
            return sublocality
        }
        if let subAdministrativeArea = subAdministrativeArea, subAdministrativeArea.count > 0{
            return subAdministrativeArea
        }
        if let locality = locality, locality.count > 0{
            return locality
        }
        if let city = city, city.count > 0{
            return city
        }
        if let state = state{
            return state
        }
        return ""
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

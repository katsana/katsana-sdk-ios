//
//  Address.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 27/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import CoreLocation

open class KTAddress: Codable {
    
    open var latitude: Double
    open var longitude: Double
    open var streetNumber: String?
    open var streetName: String?
    open var locality: String?
    open var sublocality: String?
    open var subAdministrativeArea: String?
    open var postcode: String?
    open var city: String?
    open var state: String?
    open var country: String?
    
    open var address: String?
    open var updateDate = Date()
    
    public init() {
        self.latitude = 0
        self.longitude = 0
    }
    
    public init(latitude: Double, longitude: Double) {
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
                address = self.address!
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
        if let postcode{
            components.append(postcode)
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
                address = self.address!
            }
        }
        return address
    }
    
    var _pointOfInterest : String!
    open func pointOfInterest() -> String{
        if let s = _pointOfInterest {
            return s
        }
        
        var place = ""
        if let streetName = streetName, streetName.count > 0{
            place = streetName
        }
        else if let sublocality = sublocality, sublocality.count > 0{
            if let city = city, city.contains(sublocality){
                place = city
            }else{
                place = sublocality
            }
        }
        else if let subAdministrativeArea = subAdministrativeArea, subAdministrativeArea.count > 0{
            place = subAdministrativeArea
        }
        else if let locality = locality, locality.count > 0{
            place = locality
        }
        else if let city = city, city.count > 0{
            place = city
        }
        else if let state = state{
            place = state
        }
        if place.hasPrefix("Kampung") {
            place = place.replacingOccurrences(of: "Kampung", with: "Kg")
        }
        _pointOfInterest = place
        return place
    }
    
    var _district : String!
    open func district() -> String{
        if let s = _district {
            return s
        }
        
        var place = ""
        if let city = city, city.count > 0{
            place = city
        }
        else if let locality = locality, locality.count > 0{
            place = locality
        }
        else if let state = state{
            place = state
        }
        if place.hasPrefix("Kampung") {
            place = place.replacingOccurrences(of: "Kampung", with: "Kg")
        }
        _pointOfInterest = place
        return place
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

extension KTAddress: Equatable{
    public static func == (lhs: KTAddress, rhs: KTAddress) -> Bool {
        if lhs.latitude == rhs.latitude, lhs.longitude == rhs.longitude, lhs.optimizedAddress() == rhs.optimizedAddress(){
            return true
        }
        return false
    }
}

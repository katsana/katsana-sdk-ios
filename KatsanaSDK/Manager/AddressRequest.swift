//
//  AddressRequest.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import CoreLocation

/// Class to request address from server. We are not using Siesta API because Siesta cache response in memory. Address may be called multiple times and we need to cache in KMKTCacheManager to save it in hdd
class AddressRequest {
    let api: KatsanaAPI
    let cacheManager: KTCacheManager
    
    init(api: KatsanaAPI, cacheManager: KTCacheManager) {
        self.api = api
        self.cacheManager = cacheManager
    }
        
   func requestAddress(for location:CLLocationCoordinate2D, completion: @escaping (KTAddress?, Error?) -> Void) -> Void {
        cacheManager.address(for: location) { (address) in
            if address != nil{
                completion(address, nil)
            }else{
                self.appleGeoAddress(from: location, completion: { (address) in
                    self.cacheManager.cache(address: address)
                    completion(address, nil)
                    
                    let optimizedAddress = address.optimizedAddress()
                    var useAppleAddress = true
                    let comps = optimizedAddress.components(separatedBy: ",")
                    if let first = comps.first{
                        if first.count < 2{
                            useAppleAddress = false
                        }
                    }
                    if (optimizedAddress.count) <= 10 || !useAppleAddress, let handler = self.api.addressHandler{
                        handler(location, {googleAddress in
                            if let googleAddress = googleAddress{
                                self.cacheManager.cache(address: googleAddress)
                                completion(googleAddress, nil)
                            }else{
                                completion(address, nil)
                            }
                        })
                    }else{
                        self.cacheManager.cache(address: address)
                        completion(address, nil)
                    }
                
                }, failure: { (error) in
                    if let handler = self.api.addressHandler{
                        handler(location, {address in
                            if let address = address{
                                completion(address, nil)
                            }else{
                                completion(nil, error)
                            }
                        })
                    }else{
                        completion(nil, error)
                    }
                })
            }
        }
    }
    
    func platformGeoAddress(from location:CLLocationCoordinate2D, completion:@escaping (KTAddress) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let path = api.baseURL().absoluteString + "address/"
        let latitude = String(format: "%.6f", location.latitude)
        let longitude = String(format: "%.6f", location.longitude)
        Just.get(
            path,
            params: ["latitude" : latitude, "longitude" : longitude]
        ) { r in
            if r.ok {
                let content = r.content
                let json = JSON(data: content!)
                if json != JSON.null{
                    let address = ObjectJSONTransformer.AddressObject(json: json)
                    DispatchQueue.main.sync{completion(address)}
                }else{
                    DispatchQueue.main.sync{failure(nil)}
                }
            }else{
                DispatchQueue.main.sync{failure(r.APIError())}
            }
        }
    }
    
    func appleGeoAddress(from location:CLLocationCoordinate2D, completion:@escaping (KTAddress) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(clLocation, completionHandler: { (placemarks, error) in
            if let error = error{
                failure(error)
            }else{
                if let dicto = placemarks?.first?.addressDictionary{
                    let address = KTAddress()
                    address.latitude = location.latitude
                    address.longitude = location.longitude
                    address.streetName = dicto["Street"] as? String
                    let postcode = dicto["ZIP"] as? String
                    if let postcode = postcode, let postcodeInt = Int(postcode){
                        address.postcode = postcodeInt
                    }
                    address.country = dicto["Country"] as? String
                    address.city = dicto["City"] as? String
                    address.state = dicto["State"] as? String
                    address.sublocality = dicto["SubLocality"] as? String
                    address.locality = dicto["Locality"] as? String
                    address.state = dicto["State"] as? String
                    address.subAdministrativeArea = dicto["SubAdministrativeArea"] as? String
                    
                    var addressComps = dicto["FormattedAddressLines"] as? [String]
                    addressComps?.removeLast()
                    let addressStr = addressComps?.joined(separator: ", ")
                    address.address = addressStr
                    completion(address)
                }
                
            }
        })
    }
    
//    let address = Address()
//    address.latitude = json["latitude"].doubleValue
//    address.longitude = json["longitude"].doubleValue
//    let streetNumber = json["street_number"].stringValue
//    address.streetNumber = streetNumber
//    address.streetName = json["street_name"].stringValue
//    address.locality = json["locality"].stringValue
//    address.sublocality = json["sublocality"].stringValue
//    address.postcode = json["postcode"].intValue
//    address.country = json["country"].stringValue
//    address.address = json["address"].stringValue
    
}

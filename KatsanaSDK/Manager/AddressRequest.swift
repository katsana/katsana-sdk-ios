//
//  AddressRequest.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import CoreLocation

/// Class to request address from server. We are not using Siesta API because Siesta cache response in memory. Address may be called multiple times and we need to cache in KMCacheManager to save it in hdd
class AddressRequest: NSObject {

   class func requestAddress(for location:CLLocationCoordinate2D, completion: @escaping (Address?, Error?) -> Void) -> Void {
        CacheManager.shared.address(for: location) { (address) in
            if address != nil{
                completion(address, nil)
            }else{
                self.appleGeoAddress(from: location, completion: { (address) in
                    let optimizedAddress = address.optimizedAddress()
                    var useAppleAddress = true
                    let comps = optimizedAddress.components(separatedBy: ",")
                    if let first = comps.first{
                        if first.count < 2{
                            useAppleAddress = false
                        }
                    }
                    if (optimizedAddress.count) <= 10 || !useAppleAddress{
                        self.platformGeoAddress(from: location, completion: { (address) in
                            completion(address, nil)
                            //Save requested address to cache
                            CacheManager.shared.cache(address: address)
                        })
                    }else{
                        CacheManager.shared.cache(address: address)
                        completion(address, nil)
                    }
                
                }, failure: { (error) in
                    self.platformGeoAddress(from: location, completion: { (address) in
                        completion(address, nil)
                        //Save requested address to cache
                        CacheManager.shared.cache(address: address)
                    }, failure: { (error) in
                        completion(nil, error)
                    })
                })
            }
        }
    }
    
    class func platformGeoAddress(from location:CLLocationCoordinate2D, completion:@escaping (Address) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let path = KatsanaAPI.shared.baseURL().absoluteString + "address/"
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
    
    class func appleGeoAddress(from location:CLLocationCoordinate2D, completion:@escaping (Address) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(clLocation, completionHandler: { (placemarks, error) in
            if let error = error{
                failure(error)
            }else{
                if let dicto = placemarks?.first?.addressDictionary{
                    let address = Address()
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

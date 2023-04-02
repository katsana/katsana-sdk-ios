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
    var baseURL: URL
    let cacheManager: KTCacheManager
    public var addressHandler : ((CLLocationCoordinate2D, _ completion: @escaping (KTAddress?) -> Void) -> Void)!
    
    init(baseURL: URL, cacheManager: KTCacheManager) {
        self.baseURL = baseURL
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
                    if (optimizedAddress.count) <= 10 || !useAppleAddress, let handler = self.addressHandler{
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
                    if let handler = self.addressHandler{
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
        let path = baseURL.absoluteString + "address/"
        let latitude = String(format: "%.6f", location.latitude)
        let longitude = String(format: "%.6f", location.longitude)
        Just.get(
            path,
            params: ["latitude" : latitude, "longitude" : longitude], asyncCompletionHandler:  { r in
                if r.ok {
                    let content = r.content
                    do{
                        let json = try JSON(data: content!)
                        if json != JSON.null{
                            let address = ObjectJSONTransformer.AddressObject(json: json)
                            DispatchQueue.main.sync{completion(address)}
                        }else{
                            DispatchQueue.main.sync{failure(nil)}
                        }
                    }
                    catch{
                        DispatchQueue.main.sync{failure(error)}
                    }
                    
                }else{
                    DispatchQueue.main.sync{failure(r.APIError())}
                }
            })
    }
    
    func appleGeoAddress(from location:CLLocationCoordinate2D, completion:@escaping (KTAddress) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(clLocation, completionHandler: { (placemarks, error) in
            if let error = error{
                failure(error)
            }else{
                if let placemark = placemarks?.first{
                    do{
                        let address = try CLPlaceMarkAddressMapper.map(placemark)
                        completion(address)
                    }catch{
                        failure(error)
                    }
                    
                    
//                    var addressComps = dicto["FormattedAddressLines"] as? [String]
//                    addressComps?.removeLast()
//                    let addressStr = addressComps?.joined(separator: ", ")
//                    address.address = addressStr
                    
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

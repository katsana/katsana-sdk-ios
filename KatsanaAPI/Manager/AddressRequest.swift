//
//  AddressRequest.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit

/// Class to request address from server. We are not using Siesta API because Siesta automatically cache response. Address may be called multiple times and need not cached because the address is checked with KMCacheManager
class AddressRequest: NSObject {

   class func requestAddress(for location:CLLocationCoordinate2D, completion: @escaping (KMAddress?, Error?) -> Void) -> Void {
        KMCacheManager.sharedInstance().address(for: location) { (address) in
            if address != nil{
                completion(address, nil)
            }else{
                let path = KatsanaAPI.shared.baseURL().absoluteString + "address/"
                Just.get(
                    path,
                    params: ["latitude" : "\(location.latitude)", "longitude" : "\(location.longitude)"]
                ) { r in
                    if r.ok {
                        let content = r.content
                        let json = JSON(data: content!)
                        if json != nil{
                            var address = ObjectJSONTransformer.AddressObject(json: json)
                            if (address.optimizedAddress().characters.count) <= 10{
                                self.appleGeoAddress(from: location, completion: { (appleAddress) in
                                    address = appleAddress!
                                    completion(address, nil)
                                    //Save requested address to cache
                                    KMCacheManager.sharedInstance().cacheData(address, identifier: nil)
                                })
                            }else{
                                KMCacheManager.sharedInstance().cacheData(address, identifier: nil)
                                DispatchQueue.main.sync{completion(address, nil)}
                            }
                        }else{
                            DispatchQueue.main.sync{completion(nil, nil)}
                        }
                        
                    }else{
                        DispatchQueue.main.sync{completion(address, r.error)}
                    }
                }
            }
        }
    }
    
   class func appleGeoAddress(from location:CLLocationCoordinate2D, completion:@escaping (KMAddress?) -> Void) -> Void {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(clLocation, completionHandler: { (placemarks, error) in
            let placemark = placemarks?.first
            var addressComps = placemark?.addressDictionary?["FormattedAddressLines"] as? [String]
            addressComps?.removeLast()
            let addressStr = addressComps?.joined(separator: ", ")
            
            let address = KMAddress()
            address.latitude = location.latitude
            address.longitude = location.longitude
            address.address = addressStr
            completion(address)
        })
    }
    
}

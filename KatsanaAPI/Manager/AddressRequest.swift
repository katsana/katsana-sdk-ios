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

    public func requestAddress(for location:CLLocationCoordinate2D, completion: @escaping (KMAddress?, Error?) -> Void) -> Void {
        let token = KatsanaAPI.shared.authToken
        
        KMCacheManager.sharedInstance().address(for: location) { (address) in
            if address != nil{
                completion(address, nil)
            }else{
                let path = KatsanaAPI.shared.baseURL().absoluteString + "/address/"
                Just.get(
                    path,
                    params: ["latitude" : "\(location.latitude)", "longitude" : "\(location.longitude)"],
                    data: ["token": token]
                ) { r in
                    if r.ok {
                        let content = r.content
                        let str = try? JSONSerialization.jsonObject(with: content!, options: JSONSerialization.ReadingOptions(rawValue: 0))
                        
                        
                        completion(nil, nil)
                    }else{
                        completion(nil, r.error)
                    }
                }
                
                
//                resource.loadIfNeeded()?.onSuccess({ [weak self] (entity) in
//                    var address : KMAddress? = resource.typedContent()
//                    if address != nil && (address?.optimizedAddress().characters.count)! > 0{
//                        self?.appleGeoAddress(from: location, completion: { (appleAddress) in
//                            address = appleAddress
//                            completion(address, nil)
//                            //Save requested address to cache
//                            KMCacheManager.sharedInstance().cacheData(address, identifier: nil)
//                        })
//                    }else{
//                        completion(address, nil)
//                        //Save requested address to cache
//                        KMCacheManager.sharedInstance().cacheData(address, identifier: nil)
//                    }
//                    }).onFailure({ (error) in
//                        completion(nil, error)
//                    })
            }
        }
    }
    
    func appleGeoAddress(from location:CLLocationCoordinate2D, completion:@escaping (KMAddress?) -> Void) -> Void {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(clLocation, completionHandler: { (placemarks, error) in
            let placemark = placemarks?.first
            var addressComps = placemark?.addressDictionary?["FormattedAddressLines"] as? [String]
            addressComps?.removeLast()
            let addressStr = addressComps?.joined(separator: ", ")
            
            let address = KMAddress()
            address.latitude = CGFloat(location.latitude)
            address.longitude = CGFloat(location.longitude)
            address.address = addressStr
            completion(address)
        })
    }
    
}

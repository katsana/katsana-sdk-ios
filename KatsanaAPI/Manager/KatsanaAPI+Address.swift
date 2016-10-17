//
//  KatsanaAPI+Address.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//
import CoreLocation

extension KatsanaAPI {
    
    func requestAddress(for location:CLLocationCoordinate2D, completion: @escaping (KMAddress?, Error?) -> Void) -> Void {
        KMCacheManager.sharedInstance().address(for: location) { (address) in
            if address != nil{
                completion(address, nil)
            }else{
                let path = "address/"
                let resource = self.API.resource(path).withParam("latitude", "\(location.latitude)").withParam("longitude", "\(location.longitude)");
                resource.loadIfNeeded()?.onSuccess({ [weak self] (entity) in
                    var address : KMAddress? = resource.typedContent()
                    if address != nil && (address?.optimizedAddress().characters.count)! > 0{
                        self?.appleGeoAddress(from: location, completion: { (appleAddress) in
                            address = appleAddress
                            completion(address, nil)
                            KMCacheManager.sharedInstance().cacheData(address, identifier: nil)
                        })
                    }else{
                        completion(address, nil)
                        KMCacheManager.sharedInstance().cacheData(address, identifier: nil)
                    }
                    }).onFailure({ (error) in
                        completion(nil, error)
                    })
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

//
//  KatsanaAPI+Address.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//
import CoreLocation

extension KatsanaAPI {
    public func requestAddress(for location:CLLocationCoordinate2D, completion: @escaping (KMAddress?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        AddressRequest.requestAddress(for: location) { (address, error) in
            if error != nil{
                failure(error)
            }else{
                completion(address)
            }
        }
    }
}

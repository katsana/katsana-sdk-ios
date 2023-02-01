//
//  KatsanaAPI+Address.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//
import CoreLocation

extension KatsanaAPI {
    public func requestAddress(for location:CLLocationCoordinate2D, completion: @escaping (KTAddress?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        addressRequester.requestAddress(for: location) { (address, error) in
            if error != nil{
                self.log?.error("Error getting address from Katsana platform \(location), \(String(describing: error))")
                failure(error)
            }else{
                completion(address)
            }
        }
    }
}

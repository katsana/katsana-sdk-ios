//
//  KMKatsanaAPI+Logic.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation

extension KatsanaAPI {

    func vehicleWith(vehicleId: String) -> KMVehicle! {
        for vehicle in vehicles {
            if vehicle.vehicleId == vehicleId {
                return vehicle
            }
        }
        return nil
    }
    
}

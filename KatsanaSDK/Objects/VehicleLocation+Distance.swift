//
//  VehicleLocation+Distance.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import CoreLocation

extension VehicleLocation{
    ///Returns the distance (in meters) from the receiver’s location to the specified location.
    public func distanceTo(coordinate: Coordinate) -> Float {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = location.distance(from: otherLocation)
        return Float(distance)
    }
}

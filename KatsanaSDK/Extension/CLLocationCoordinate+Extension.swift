//
//  CLLocationCoordinate+Extension.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 27/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import Foundation
import CoreLocation


public extension CLLocationCoordinate2D{
    static let epsilon = 0.005
    
    func equal(_ location: CLLocationCoordinate2D) -> Bool {
        if fabs(latitude - location.latitude) < CLLocationCoordinate2D.epsilon && fabs(longitude - location.longitude) < CLLocationCoordinate2D.epsilon {
            return true
        }
        return false
        
    }
}

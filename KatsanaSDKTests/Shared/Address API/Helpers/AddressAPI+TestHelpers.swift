//
//  TestHelpers.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 02/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import KatsanaSDK

func anyCoordinate() -> (latitude: Double, longitude: Double) {
    return (3.0089633, 101.75814)
}

func anyAddress() -> KTAddress {
    let address = KTAddress(latitude: 3.0089633, longitude: 101.75814)
    return address
}


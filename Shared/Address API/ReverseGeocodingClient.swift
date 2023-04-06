//
//  ReverseGeoAddressClient.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 02/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol ReverseGeocodingClientTask {
    func cancel()
}

public protocol ReverseGeocodingClient {
    typealias Result = Swift.Result<KTAddress, Error>
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func getAddress(_ coordinate: (latitude: Double, longitude: Double), completion: @escaping (Result) -> Void) -> ReverseGeocodingClientTask
    
}

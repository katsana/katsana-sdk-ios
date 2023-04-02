//
//  AppleReverseGeocodingClient.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 02/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import CoreLocation

public class AppleReverseGeocodingClient: ReverseGeocodingClient{
    let geocoder: CLGeocoder
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public init(geocoder: CLGeocoder = CLGeocoder()){
        self.geocoder = geocoder
    }
    
    public func getAddress(_ coordinate: (latitude: Double, longitude: Double), completion: @escaping (Result<KTAddress, Error>) -> Void){
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { placemarks, error in
            if let placemark = placemarks?.first{
                do{
                    let address = try CLPlaceMarkAddressMapper.map(placemark)
                    completion(.success(address))
                }
                catch{
                    completion(.failure(error))
                }
            }
            else if let error{
                completion(.failure(error))
            }else{
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }
    }
}

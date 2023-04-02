//
//  AppleReverseGeoStore.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 02/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import CoreLocation

public class AppleReverseGeoStore: ResourceStore{
    public typealias Resource = KTAddress
    
    private struct Cache: Codable {
        let resource: Resource
        let timestamp: Date
    }
        
    private let storeURL: URL
    private let coordinate: CLLocationCoordinate2D
    private let queue = DispatchQueue(label: "\(AppleReverseGeoStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    public init(storeURL: URL, coordinate: (latitude: Double, longitude: Double)) {
        self.storeURL = storeURL
        self.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    public func deleteCachedResource(completion: @escaping DeletionCompletion){
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(()))
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ resource: Resource, timestamp: Date, completion: @escaping InsertionCompletion){
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(resource: resource, timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion){
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }

            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success((cache.resource, cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func appleGeoAddress(completion:@escaping (KTAddress) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(clLocation, completionHandler: {[weak self] (placemarks, error) in
            guard let self else {return}
            
            if let error = error{
                failure(error)
            }else{
                if let dicto = placemarks?.first?.addressDictionary{
                    let address = KTAddress()
                    address.latitude = self.coordinate.latitude
                    address.longitude = self.coordinate.longitude
                    address.streetName = dicto["Street"] as? String
                    let postcode = dicto["ZIP"] as? String
                    if let postcode = postcode, let postcodeInt = Int(postcode){
                        address.postcode = postcodeInt
                    }
                    address.country = dicto["Country"] as? String
                    address.city = dicto["City"] as? String
                    address.state = dicto["State"] as? String
                    address.sublocality = dicto["SubLocality"] as? String
                    address.locality = dicto["Locality"] as? String
                    address.state = dicto["State"] as? String
                    address.subAdministrativeArea = dicto["SubAdministrativeArea"] as? String
                    
                    var addressComps = dicto["FormattedAddressLines"] as? [String]
                    addressComps?.removeLast()
                    let addressStr = addressComps?.joined(separator: ", ")
                    address.address = addressStr
                    completion(address)
                }
                
            }
        })
    }
}

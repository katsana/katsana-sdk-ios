//
//  KatsanaAPI+objc.swift
//  KatsanaSDK
//
//  Created by Wan Lutfi on 27/11/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import Foundation

public extension KatsanaAPI{

    @available(swift, obsoleted: 1.0)
    public func objc_requestAllVehicleLocations(completion: @escaping (_ vehicles: [KTVehicle]?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        requestAllVehicleLocations(completion: { (vehicles) in
            completion(vehicles)
        }) { (error) in
            failure(error)
        }
    }
    
    @available(swift, obsoleted: 1.0)
    public func objc_requestAllVehicles(options:[String]! = nil, completion: @escaping (_ vehicles: [KTVehicle]?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        requestAllVehicles(completion: { (vehicles) in
            completion(vehicles)
        }) { (error) in
            failure(error)
        }
    }
    
    @available(swift, obsoleted: 1.0)
    public func objc_requestTravelSummaries(vehicleId: String, fromDate: Date!, toDate: Date, completion: @escaping (_ summaries:[Travel]?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        requestTravelSummaries(vehicleId: vehicleId, fromDate: fromDate, toDate: toDate, forceRequest: true, completion: { (travels) in
            completion(travels)
        }) { (error) in
            failure(error)
        }
    }
    
    @available(swift, obsoleted: 1.0)
    public func objc_requestTravelSummaryToday(vehicleId: String, completion: @escaping (_ summary: Travel?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        requestTravelSummaryToday(vehicleId: vehicleId, completion: { (travel) in
            completion(travel)
        }) { (error) in
            failure(error)
        }
    }
    
    @available(swift, obsoleted: 1.0)
    public func objc_requestTravelUsing(summary: Travel, completion: @escaping (_ history: Travel?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        requestTravelUsing(summary: summary, completion: { (travel) in
            completion(travel)
        }) { (error) in
            failure(error)
        }
    }
    
    @available(swift, obsoleted: 1.0)
    public func objc_requestTravel(for date: Date, vehicleId: String, options: [String]! = nil, completion: @escaping (_ history: Travel?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        requestTravel(for: date, vehicleId: vehicleId, options: options, completion: { (travel) in
            completion(travel)
        }) { (error) in
            failure(error)
        }
    }
    
    @available(swift, obsoleted: 1.0)
    public func objc_requestVehicle(vehicleId: String, options: [String]! = nil, completion: @escaping (_ vehicle: KTVehicle?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        requestVehicle(vehicleId: vehicleId, options: options, completion: { (vehicle) in
            completion(vehicle)
        }) { (error) in
            failure(error)
        }
    }
    
    @available(swift, obsoleted: 1.0)
    public func objc_requestVehicleLocation(vehicleId: String, completion: @escaping (_ vehicleLocation: VehicleLocation?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        requestVehicleLocation(vehicleId: vehicleId, completion: { (location) in
            completion(location)
        }) { (error) in
            failure(error)
        }
    }
    
    @available(swift, obsoleted: 1.0)
    public func objc_requestSubscriptions(completion: @escaping (_ subscriptions: [VehicleSubscription]) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        requestSubscriptions(completion: { (subscriptions) in
            completion(subscriptions)
        }) { (error) in
            failure(error)
        }
    }
}

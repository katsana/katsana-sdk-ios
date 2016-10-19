//
//  KMKatsanaAPI.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit
import Siesta
import SwiftyJSON

public class KatsanaAPI: NSObject {
    
    public static let shared = KatsanaAPI()
    public var API : Service!
    
    
    internal(set) public var tokenRefreshDate: Date!
    internal(set) public var currentUser: KMUser!
    public               var currentVehicle: KMVehicle!{
        willSet{
            if (currentVehicle != nil) {lastVehicleId = currentVehicle.vehicleId}
        }
    }
    internal(set) public var vehicles: [KMVehicle]!{
        willSet{
            lastVehicleImeis = vehicles.map({ $0.imei})
        }
    }
    private(set) public var lastVehicleId: String!
    private(set) public var lastVehicleImeis: [String]!
    private let SwiftyJSONTransformer = ResponseContentTransformer { JSON($0.content as AnyObject) }
    
    internal var authToken: String! {
        didSet {
            // Rerun existing configuration closure using new value
            API.invalidateConfiguration()
            // Wipe any Siesta’s cached state if auth token changes
            API.wipeResources()
            if authToken != nil {tokenRefreshDate = Date()}
        }
    }
    
    // MARK: Lifecycle

    public class func configureShared(baseURL : URL) -> Void {
        shared.API = Service(baseURL: baseURL)
        shared.configure()
        shared.setupTransformer()
    }
    
    func configure() {
        API.configure("**") {
            $0.headers["Accept"] = "application/json"
            $0.pipeline[.parsing].add(self.SwiftyJSONTransformer, contentTypes: ["*/json"])
            $0.headers["Authorization"] = "Bearer " + self.authToken
        }
        
        //Vehicle location will request new data only after 5 seconds
        API.configure("vehicles/*/location") {
            $0.expirationTime = 5
        }
        
        //Vehicle summary will request new data only after 3 minutes
        API.configure("vehicles/*/summaries/*") {
            $0.expirationTime = 3*60
        }
        
        //Vehicle travel will request new data only after 1 minute
        API.configure("vehicles/*/travels/***") {
            $0.expirationTime = 1*60
        }
    }
    
    func setupTransformer() -> Void {
        API.configureTransformer("vehicles") {
            ObjectJSONTransformer.VehiclesObject(json: $0.content)
        }
        API.configureTransformer("vehicles/*") {
            ObjectJSONTransformer.VehicleObject(json: $0.content)
        }
        
        API.configureTransformer("profile") {
            ObjectJSONTransformer.UserObject(json: $0.content)
        }
        
        API.configureTransformer("vehicles/*/summaries/*") {
            ObjectJSONTransformer.TravelSummaryObject(json: $0.content)
        }
        API.configureTransformer("vehicles/*/travels/***") {
            ObjectJSONTransformer.TravelHistoryObject(json: $0.content)
        }
        API.configureTransformer("vehicles/*/location") {
            ObjectJSONTransformer.VehicleLocationObject(json: $0.content)
        }
    }
    
    func baseURL() -> URL {
        return API.baseURL!;
    }
    
    ///Check if web socket supported or not, if any vehicle support websocket, other vehicles also considered to support it
    public func websocketSupported() -> Bool {
        var supported = false
        for vehicle in vehicles {
            if vehicle.websocket {
                supported = true
                break
            }
        }
        return supported
    }
}

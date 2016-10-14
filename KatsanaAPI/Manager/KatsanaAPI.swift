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
    
    internal(set) public var currentUser: KMUser!
    public              var currentVehicle: KMVehicle!
    internal(set) public var vehicles: [KMVehicle]!
    
    private let SwiftyJSONTransformer = ResponseContentTransformer { JSON($0.content as AnyObject) }
    
    internal var authToken: String! {
        didSet {
            // Rerun existing configuration closure using new value
            API.invalidateConfiguration()
            // Wipe any Siesta’s cached state if auth token changes
            API.wipeResources()
        }
    }

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
            ObjectJSONTransformer.TravelHistoryObject(json: $0.content)
        }
        API.configureTransformer("vehicles/*/travels/***") {
            ObjectJSONTransformer.TravelHistoryObject(json: $0.content)
        }
    }
    
    func baseURL() -> URL {
        return API.baseURL!;
    }
}

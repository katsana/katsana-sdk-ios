//
//  KMKatsanaAPI.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Siesta
import XCGLogger

public class KatsanaAPI: NSObject {
    //Notifications
    static let userSuccessLoginNotification = Notification.Name(rawValue: "KMUserSuccessLogonNotification")
    static let userWillLogoutNotification = Notification.Name(rawValue: "KMUserWillLogoutNotification")
    static let userDidLogoutNotification = Notification.Name(rawValue: "KMUserDidLogoutNotification")
    static let defaultBaseURL = URL(string: "https://api.katsana.com/")! as URL
    internal(set) var log : XCGLogger!
    
    public static let shared = KatsanaAPI()
    public var API : Service!
    internal(set) var clientId : String = ""
    internal(set) var clientSecret: String = ""
    internal(set) var grantType: String = ""
    internal(set) var authTokenExpired: Date!
    internal(set) public var logPath: String!
    
    internal(set) public var tokenRefreshDate: Date!
    internal(set) dynamic public var currentUser: KMUser!
    public        dynamic        var currentVehicle: KMVehicle!{
        willSet{
            if (newValue != nil) {
                log.info("Current selected vehicle \(newValue.vehicleId)")
                lastVehicleId = newValue.vehicleId
            }
        }
    }
    internal(set) dynamic public var vehicles: [KMVehicle]!{
        willSet{
            if vehicles != nil {
                lastVehicleImeis = vehicles.map({ $0.imei})
            }
        }
    }
    private(set) dynamic public var lastVehicleId: String!{
        set{
            UserDefaults.standard.set(newValue, forKey: "lastVehicleId")
        }
        get{
            return  UserDefaults.standard.value(forKey: "lastVehicleId") as! String!
        }
    }
    private(set) dynamic public var lastVehicleImeis: [String]!{
        set{
            UserDefaults.standard.set(newValue, forKey: "lastVehicleImeis")
        }
        get{
            return  UserDefaults.standard.value(forKey: "lastVehicleImeis") as! [String]!
        }
    }
    private let SwiftyJSONTransformer = ResponseContentTransformer { JSON($0.content as AnyObject) }
    
    //Access token to the server
    internal(set) public var authToken: String! {
        didSet {
            if authToken != nil {
                tokenRefreshDate = Date()
                // Rerun existing configuration closure using new value
                API.invalidateConfiguration()
            }
            
            // Wipe any Siesta’s cached state if auth token changes
            API.wipeResources()
        }
    }

    /// Token to refresh access token
    internal(set) public var refreshToken: String!
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
        self.setupLog()
    }

    public class func configure(baseURL : URL = KatsanaAPI.defaultBaseURL) -> Void {
        
        configure(baseURL : baseURL, clientId: "", clientSecret:"", grantType: "")
    }
    
    public class func configure(baseURL : URL = KatsanaAPI.defaultBaseURL, clientId : String = "", clientSecret: String = "", grantType: String = "") -> Void {
        shared.API = Service(baseURL: baseURL)
        shared.configure()
        shared.setupTransformer()
        if clientId != nil {
            shared.clientId = clientId
        }
        if clientSecret != nil {
            shared.clientSecret = clientSecret
        }
        shared.grantType = grantType
    }
    
    func configure() {
        API.configure("**") {
            $0.headers["Accept"] = "application/json"
            $0.pipeline[.parsing].add(self.SwiftyJSONTransformer, contentTypes: ["*/json"])
            if self.authToken != nil{
                $0.headers["Authorization"] = "Bearer " + self.authToken
            }
        }
        
        //Vehicle location will request new data only after 5 seconds
        API.configure("vehicles/*/location") {
            $0.expirationTime = 5
        }
        
        //Vehicle location will request new data only after 10 seconds
        API.configure("vehicles/*") {
            $0.expirationTime = 10
        }
        
        //All vehicles will request new data only after 1 minute
        API.configure("vehicles") {
            $0.expirationTime = 10
        }
        
        //Vehicle summary today will request new data only after 4 minutes
        API.configure("vehicles/*/summaries/today") {
            $0.expirationTime = 4*60
        }
        
        //Vehicle summary duration will request new data only after 1 minute
        API.configure("vehicles/*/summaries/duration") {
            $0.expirationTime = 1*60
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
        
        API.configureTransformer("vehicles/*/summaries/duration") {
            ObjectJSONTransformer.TravelSummariesObject(json: $0.content)
        }
        API.configureTransformer("vehicles/*/summaries/today") {
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
        guard vehicles != nil else {
            return false
        }
        
        var supported = false
        for vehicle in vehicles {
            if vehicle.websocket {
                supported = true
                break
            }
        }
        log.verbose("Websocket /(supported)")
        return supported
    }
    
    ///Load last logon user for offline viewing
    public func loadLastUserOffline() -> Void {
        let user = KMCacheManager.sharedInstance().lastUser();
        let vehicles = KMCacheManager.sharedInstance().lastVehicles();
        self.currentUser = user
        self.vehicles = vehicles
    }
    
    //Update to new token. You must know what you are doing!
    public func updateToken(newToken: String) -> Void {
        authToken = newToken
    }
}

//
//  KMKatsanaAPI.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Siesta
import XCGLogger
import CoreLocation

open class KatsanaAPI {
    //Notifications
    public static let userSuccessLoginNotification = Notification.Name(rawValue: "KMUserLogonSuccessNotification")
    public static let userWillLogoutNotification = Notification.Name(rawValue: "KMUserWillLogoutNotification")
    public static let userDidLogoutNotification = Notification.Name(rawValue: "KMUserDidLogoutNotification")
    public static let profileUpdatedNotification = Notification.Name(rawValue: "KMProfileUpdatedNotification")
    public static let subscriptionRequestedNotification = Notification.Name(rawValue: "subscriptionRequestedNotification")
    public static let authTokenUpdatedNotification = Notification.Name(rawValue: "authTokenUpdatedNotification")
    public static let insuranceExpiryDateChangedNotification = Notification.Name(rawValue: "insuranceExpiryDateChangedNotification")
    public static let defaultBaseURL: URL = URL(string: "https://api.katsana.com/")!
    public internal(set) var log : XCGLogger!
    
    
    ///Default options when requesting vehicle or all vehicles
    public var defaultRequestVehicleOptions: [String]!
    ///Default options when requesting travel or trip
    public var defaultRequestTravelOptions: [String]!
    public var defaultRequestTripOptions: [String]!
    public var defaultRequestProfileOptions: [String]!
    public var defaultRequestTripSummaryOptions: [String]!
    public var authorizationHeader = "Bearer "
    ///Specify time cache is saved in day
    public var logSavedDuration = 7
    ///Use this handler if need to have extra setup when object is initialized
    public var objectInitializationHandler : ((JSON, Any) -> (Void))!
    ///Call outside address handler if address from SDK deemed not valid
    public var addressHandler : ((CLLocationCoordinate2D, _ completion: @escaping (KTAddress?) -> Void) -> Void)!
    
    public static let shared = KatsanaAPI()
    public var API : Service!
    var cache: KTCacheManager!
    
    var clientId : String = ""
    var clientSecret: String = ""
    var grantType: String = ""
    var authTokenExpired: Date!
    
    internal(set) public var logPath: String!
    internal var identifierDicts = [String: Date]()
    
    ///Vehicle ids with empty images. Due to some bugs, we put vehicle with empty image here, so can skip loading those images again on current session.
    var vehicleIdWithEmptyImages = [String]()
    
    ///Last log size before reset. Used for debugging purpose
    ///
    ///
    internal(set) public var lastLogSize: String!
    
    internal(set) public var tokenRefreshDate: Date!
    internal(set) public var currentUser: KTUser!
    internal(set) public var currentVehicle: KTVehicle!{
        willSet{
            if let newValue = newValue{
                if let currentVehicle = currentVehicle, newValue.imei != currentVehicle.imei{
                    log.info("Current selected vehicle \(String(describing: newValue.vehicleId))")
                    lastVehicleIds = [newValue.vehicleId]
                }else if currentVehicle == nil{
                    log.info("Current selected vehicle \(String(describing: newValue.vehicleId))")
                    lastVehicleIds = [newValue.vehicleId]
                }
            }else{
                lastVehicleIds = nil
            }
        }
    }
    public var selectedVehicles: [KTVehicle]!{
        willSet{
            if let newValue = newValue{
                if let selectedVehicles = selectedVehicles, newValue != selectedVehicles{
//                    log.info("Current selected vehicles \(newValue.vehicleId)")
                    lastVehicleIds = newValue.map({$0.vehicleId})
                }else if selectedVehicles == nil{
//                    log.info("Current selected vehicles \(newValue.vehicleId)")
                    lastVehicleIds = newValue.map({$0.vehicleId})
                }
            }
        }
    }
    internal(set) public var vehicles: [KTVehicle]!{
        willSet{
            if vehicles != nil {
//                print(vehicles)
                lastVehicleImeis = vehicles.map({ $0.imei})
            }
        }
    }
    @objc private(set) dynamic public var lastVehicleIds: [String]!{
        set{
            UserDefaults.standard.set(newValue, forKey: "lastVehicleIds")
        }
        get{
            if let ids = UserDefaults.standard.value(forKey: "lastVehicleIds") as? [String]{
                return ids
            }
            return nil
        }
    }
    @objc private(set) dynamic public var lastVehicleImeis: [String]!{
        set{
            UserDefaults.standard.set(newValue, forKey: "lastVehicleImeis")
        }
        get{
            return  UserDefaults.standard.value(forKey: "lastVehicleImeis") as! [String]?
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
            NotificationCenter.default.post(name: KatsanaAPI.authTokenUpdatedNotification, object: self)
            // Wipe any Siesta’s cached state if auth token changes
            API.wipeResources()
        }
    }

    /// Token to refresh access token
    internal(set) public var refreshToken: String!

    // MARK: Lifecycle
    
    public init(cache: KTCacheManager = KTCacheManager.shared) {
        self.cache = cache
        self.setupLog()
    }

    public class func configure(baseURL : URL = KatsanaAPI.defaultBaseURL) -> Void {
        configure(baseURL : baseURL, clientId: "", clientSecret:"", grantType: "")
    }
    
    public class func configure(baseURL : URL = KatsanaAPI.defaultBaseURL, clientId : String = "", clientSecret: String = "", grantType: String = "") -> Void {
        shared.API = Service(baseURL: baseURL)
        shared.configure()
        shared.setupTransformer()
        shared.clientId = clientId
        shared.clientSecret = clientSecret
        shared.grantType = grantType
    }
    
    ///Configure API using access token
    public class func configure(baseURL : URL = KatsanaAPI.defaultBaseURL, accessToken: String) -> Void {
        shared.API = Service(baseURL: baseURL)
        shared.authToken = accessToken
        shared.configure()
        shared.setupTransformer()
    }
    
    ///Configure API using access token
    public func configure(baseURL : URL = KatsanaAPI.defaultBaseURL, accessToken: String) -> Void {
        API = Service(baseURL: baseURL)
        authToken = accessToken
        configure()
        setupTransformer()
    }
    
    func configure() {
        API.configure("**") {
            $0.headers["Accept"] = "application/json"
            $0.pipeline[.parsing].add(self.SwiftyJSONTransformer, contentTypes: ["*/json"])
            if self.authToken != nil{
                $0.headers["Authorization"] = self.authorizationHeader + self.authToken
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
        
        //All vehicles will request new data only after 10 seconds
        API.configure("vehicles") {
            $0.expirationTime = 10
        }
        
        API.configure("operations/stream") {
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
        
        //Trip summary duration will request new data only after 3 minute
        API.configure("vehicles/*/travels/summaries/duration") {
            $0.expirationTime = 3*60
        }
        
        API.configure("insurers/my") {
            $0.expirationTime = 15*60
        }
        
        API.configure("subscriptions/pay") {
            $0.expirationTime = 1
        }
        
        API.configure("subscriptions") {
            $0.expirationTime = 5*60
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
        
        API.configureTransformer("address/") {
            ObjectJSONTransformer.AddressObject(json: $0.content)
        }
        
        API.configureTransformer("vehicles/*/summaries/duration") {
            ObjectJSONTransformer.TravelSummariesObject(json: $0.content)
        }
        
        API.configureTransformer("vehicles/*/summaries/today") {
            ObjectJSONTransformer.TravelSummaryObject(json: $0.content)
        }
        API.configureTransformer("vehicles/*/travels/***") {
            ObjectJSONTransformer.TravelObject(json: $0.content)
        }
        API.configureTransformer("vehicles/*/travels/summaries/duration") {
            ObjectJSONTransformer.TripSummariesObject(json: $0.content)
        }
        API.configureTransformer("vehicles/*/location") {
            ObjectJSONTransformer.VehicleLocationObject(json: $0.content)
        }
        API.configureTransformer("insurers/my") {
            ObjectJSONTransformer.InsurersObject(json: $0.content)
        }
        
        API.configureTransformer("subscriptions") {
            ObjectJSONTransformer.VehicleSubscriptionsObject(json: $0.content)
        }
        
//        API.configureTransformer("subscriptions/*") {
//            ObjectJSONTransformer.VehicleSubscriptionObject(json: $0.content)
//        }
        
        API.configureTransformer("track/register") {
            ObjectJSONTransformer.RegisterVehicleObject(json: $0.content)
        }
        
        API.configureTransformer("operations/stream") {
            ObjectJSONTransformer.VideoRecordingObjects(json: $0.content)
        }
        
        API.configureTransformer("operations/stream/show") {
            ObjectJSONTransformer.VideoRecordingObject(json: $0.content)
        }
        
        API.configureTransformer("operations/playback") {
            ObjectJSONTransformer.VideoPlaybackObjects(json: $0.content)
            
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
            if vehicle.websocketSupported {
                supported = true
                break
            }
        }
        log.verbose("Websocket /(supported)")
        return supported
    }
    
    ///Load last logon user for offline viewing
    public func loadCachedUser() -> Void {
        if let user = cache?.lastUser(){
            let vehicles = cache?.vehicles(userId: user.userId)
            self.currentUser = user
            self.vehicles = vehicles
        }
    }
    
    ///Load cached vehicles
    public func loadCachedVehicles() -> Void {
        if let user = cache?.lastUser(){
            let vehicles = cache?.vehicles(userId: user.userId)
            self.vehicles = vehicles
        }
    }
    
    //Update to new token. You must know what you are doing!
    public func updateToken(newToken: String) -> Void {
        authToken = newToken
    }
    
    public func purgeTravelCacheOlderThan(days: Int) {
        cache?.purgeTravelOlderThan(days: days)
    }
    
    // MARK: Error handling
    
    private var lastUnauthorizedErrorDate: Date!
    func handleError(error: Error!, details: String) {
        let handled = false
        if let error = error as? RequestError {
            if let code = error.httpStatusCode, code == 401 {
                //Because not authorized is occured frequently (need check the issue), fire notification or log unauthorized error only after 1 minute only
                if let lastUnauthorizedErrorDate = lastUnauthorizedErrorDate{
                    if Date().timeIntervalSince(lastUnauthorizedErrorDate) > 60 {
                        handleUnauthorizedError(details: details)
                    }
                }else{
                    handleUnauthorizedError(details: details)
                }
            }
        }
        if !handled {
            self.log.error(details)
        }
    }
    
    func handleUnauthorizedError(details: String) {
        refreshToken(completion: { (success) in
            self.log.info("Token refreshed")
        }) { (error) in
            self.log.error("Error refreshing token, \(String(describing: error?.localizedDescription))")
        }
    }
    
    // MARK: Helper
    
    public func vehicleWithUnassignedFleet() -> [KTVehicle]! {
        if let user = currentUser, let vehicles = vehicles{
            var newVehicles = [KTVehicle]()
            for vehicle in vehicles{
                var isUnassigned = true
                for fleet in vehicle.fleetIds{
                    if let _ = user.fleet(id: fleet){
                        isUnassigned = false
                        break
                    }
                }
                if isUnassigned{
                    newVehicles.append(vehicle)
                }
            }
            return newVehicles
        }
        return nil
    }
    
    public func vehicles(fleetId: Int) -> [KTVehicle]! {
        if let _ = currentUser, let vehicles = vehicles{
            var newVehicles = [KTVehicle]()
            for vehicle in vehicles{
                if vehicle.fleetIds.contains(fleetId){
                    newVehicles.append(vehicle)
                }
            }
            return newVehicles
        }
        return nil
    }
}

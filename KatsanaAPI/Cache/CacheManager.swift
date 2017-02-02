//
//  CacheManager.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 02/02/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import UIKit

let cacheVersion = "2.0"

public class CacheManager: NSObject {
    public static let shared = CacheManager()
    
    private var addresses = [Address]()
    private var activities = [String: [VehicleActivity]]()
    private var liveShares = [LiveShare]()
    private var data = [String: Any]()
    
    private var expandedTripList: [String : Date]!
    private var travelAccessVehicleId = ""
    private var todayAccessDate: Date!
    
    private var lastSavedCache : Date!
    private var lastSavedAddressCache: Date!
    private var lastSavedActivitiesCache: Date!
    
    override init() {
        super.init()
        
        let versionPath = cacheDirectory().appending("/version.txt")
        let version = try? NSString(contentsOfFile: versionPath, encoding: String.Encoding.ascii.rawValue)
        if let version = version{
            if version as String != cacheVersion {
                clearCache()
                return
            }
            try? cacheVersion.write(toFile: versionPath, atomically: true, encoding: String.Encoding.ascii)
        }
        
        let dataPath = cacheDirectory().appending("/" + cacheDataFilename())
        var url = URL(fileURLWithPath: dataPath)
        if let data = try? Data(contentsOf: url){
            if let unarchive = FastCoder.object(with: data) as? [String: Any]{
                self.data = unarchive
            }
        }
        
        let addressPath = cacheDirectory().appending("/" + cacheAddressDataFilename())
        url = URL(fileURLWithPath: addressPath)
        if let data = try? Data(contentsOf: url){
            if let unarchive = FastCoder.object(with: data) as? [Address]{
                self.addresses = unarchive
            }
        }
        
        let activitiesPath = cacheDirectory().appending("/" + cacheActivitiesDataFilename())
        url = URL(fileURLWithPath: activitiesPath)
        if let data = try? Data(contentsOf: url){
            if let unarchive = FastCoder.object(with: data) as? [String: [VehicleActivity]]{
                self.activities = unarchive
            }
        }
        
        purgeOldActivities()
        print(dataPath)
    }
    
    // MARK: Get Cache
    
    public func lastUser() -> User! {
        let classname = NSStringFromClass(User.self)
        if let user = data[classname] as? User{
            return user
        }
        return nil
    }
    
    public func lastVehicles() -> [Vehicle]! {
        let classname = NSStringFromClass(Vehicle.self)
        if let vehicles = data[classname] as? [Vehicle]{
            return vehicles
        }
        return nil
    }
    
    public func latestVehicleActivity(userId: String) -> VehicleActivity! {
        if let activities = activities[userId]{
            return activities.first //Assume first is latest activity
        }
        return nil
    }
    
    ///Get cached travel data given vehicle id and date
    public func travel(vehicleId:String, date:Date) -> Travel! {
        //Check if date is today, return nil if more than specified time. No local cache is returned and  library should request a new data from server
        let today = Date()
        if date.isToday(), travelAccessVehicleId == vehicleId, let todayAccessDate = todayAccessDate, today.timeIntervalSince(todayAccessDate) > 60 * 4 {
            self.travelAccessVehicleId = vehicleId
            self.todayAccessDate = today
            return nil
        }
        
        let classname = NSStringFromClass(Travel.self)
        if let travelDicto = data[classname] as? [String: Any]{
            if let travelVehicleId = travelDicto["id"] as? String, let travel = travelDicto["data"] as? Travel {
                if travelVehicleId == vehicleId, Calendar.current.isDate(travel.date, inSameDayAs: date){
                    return travel
                }
            }
        }
        return nil
    }
    
    public func address(for coordinate: CLLocationCoordinate2D, completion: @escaping (_ address: Address?) -> Void) {
        let keepAddressDuration : TimeInterval = 60*60*24 * 3*30 //Keep address for 3 months
        
        DispatchQueue.global(qos: .background).async {
            let addresses = self.addresses
            var found = false
            for address in addresses {
                if address.coordinate().equal(coordinate), Date().timeIntervalSince(address.updateDate) < keepAddressDuration{
                    completion(address)
                    found = true
                }
            }
            
            if !found{
                DispatchQueue.main.sync {
                    completion(nil)
                }
            }
        }
    }
    
    public func liveShare(userId: String, deviceId: String) -> LiveShare! {
        for liveshare in liveShares {
            if liveshare.deviceId == deviceId, liveshare.userId == userId{
                return liveshare
            }
        }
        return nil
    }
    
    public func image(for identifier: String) -> KMImage! {
        let dir = cacheDirectory()
        let path = dir.appending("/Images")
        let filePath = path.appending(identifier + ".jpg")
        if let data = NSData(contentsOfFile: filePath){
            let image = KMImage(data: data as Data)
            return image
        }
        return nil
    }
    
    public func vehicleActivities(userId: String) -> [VehicleActivity]! {
        if let activities = activities[userId]{
            return activities
        }
        return nil
    }
    
    public func expandedTripListDate(vehicleId: String) -> Date! {
        for (key, value) in expandedTripList {
            if key == vehicleId{
                return value
            }
        }
        return nil
    }
    
    // MARK: Save Cache
    
    public func cache(user: User) {
        let classname = NSStringFromClass(User.self)
        data[classname] = user
        autoSave()
    }
    
    public func cache(vehicles: [Vehicle]) {
        let classname = NSStringFromClass(Vehicle.self)
        data[classname] = vehicles
        autoSave()
    }
    
    public func cache(travel: Travel, vehicleId: String) {
        var dataChanged = false
        let classname = NSStringFromClass(Travel.self)
        
        var travelArray: [[String: Any]]!
        if let array = data[classname] as? [[String: Any]]{
            travelArray = array
        }else{
            let dicto = ["data": travel, "id": vehicleId] as [String : Any]
            travelArray.append(dicto)
            data[classname] = travelArray
            dataChanged = true
        }
        
        var needAdd = true
        var needRemoveTravelIndex : Int!
        
        for (index, dicto) in travelArray.enumerated() {
            if let theTravel = dicto["data"] as? Travel, let theVehicleId = dicto["id"] as? String{
                if theTravel.date.isEqualToDateIgnoringTime(travel.date), vehicleId == theVehicleId {
                    if theTravel == travel{
                        needAdd = false
                    }else{
                        needRemoveTravelIndex = index
                        dataChanged = true
                    }
                    break
                }
            }
        }
        
        if let needRemoveTravelIndex = needRemoveTravelIndex {
            travelArray.remove(at: needRemoveTravelIndex)
        }
        if needAdd {
            travelArray.append(["data": travel, "id": vehicleId])
            dataChanged = true
        }
        
        if dataChanged{
            autoSave()
        }
    }
    
    public func cache(address: Address) {
        var needAdd = true
        for add in addresses {
            if address == add{
                needAdd = false
                break
            }
        }
        
        if needAdd{
            address.updateDate = Date()
            addresses.append(address)
            autosaveAddress()
        }
    }
    
    public func cache(activities: [VehicleActivity], userId: String) {
        for act in activities {
            cache(activity: act, userId: userId)
        }
    }
    
    public func cache(activity: VehicleActivity, userId:String) {
        var needAdd = true
        var activities: [VehicleActivity]!
        if self.activities[userId] != nil{
           activities = self.activities[userId]
        }else{
            activities = [VehicleActivity]()
            self.activities[userId] = activities
        }
        
        for act in activities {
            if act.startTime == activity.startTime, act.type == activity.type{
                needAdd = false
                break
            }
        }
        
        if needAdd{
            activities.append(activity)
            autoSaveActivities()
        }
    }
    
    public func cache(liveShare: LiveShare) {
        let path = cacheDirectory().appending("/" + cacheLiveShareFilename())
        liveShares.append(liveShare)
        let data = FastCoder.data(withRootObject: liveShares) as NSData
        data.write(toFile: path, atomically: true)
    }
    
    public func cache(image: KMImage, identifier: String) {
        let dir = cacheDirectory()
        let path = dir.appending("/Images")
        if !FileManager.default.fileExists(atPath: path){
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        }
        let filePath = path.appending(identifier + ".jpg")
        #if os(iOS) || os(watchOS) || os(tvOS)
            let data = UIImagePNGRepresentation(image)
        #elseif os(OSX)
            let data = image.TIFFRepresentation
        #endif
        
        try? data?.write(to: URL(fileURLWithPath: filePath))
    }
    
    
    public func cacheExpandedTripList(vehicleId: String!, date:Date) {
        guard vehicleId != nil else {
            expandedTripList = nil
            return
        }
        expandedTripList = [vehicleId : date]
    }
    
    // MARK: Save data
    
    func autoSave()  {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if let lastSavedCache = lastSavedCache, Date().timeIntervalSince(lastSavedCache) < 5{
            perform(#selector(autoSave), with: nil, afterDelay: 3)
        }
        lastSavedCache = Date()
        
        let data = FastCoder.data(withRootObject: self.data)
        let path = cacheDirectory().appending("/" + cacheDataFilename())
        try? data?.write(to: URL(fileURLWithPath: path))
    }
    
    func autosaveAddress() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if let lastSavedCache = lastSavedAddressCache, Date().timeIntervalSince(lastSavedCache) < 5{
            perform(#selector(autosaveAddress), with: nil, afterDelay: 3)
        }
        lastSavedAddressCache = Date()
        
        let data = FastCoder.data(withRootObject: self.addresses)
        let path = cacheDirectory().appending("/" + cacheAddressDataFilename())
        try? data?.write(to: URL(fileURLWithPath: path))
    }
    
    func autoSaveActivities() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if let lastSavedCache = lastSavedActivitiesCache, Date().timeIntervalSince(lastSavedCache) < 5{
            perform(#selector(autoSaveActivities), with: nil, afterDelay: 3)
        }
        lastSavedActivitiesCache = Date()
        
        let data = FastCoder.data(withRootObject: self.activities)
        let path = cacheDirectory().appending("/" + cacheActivitiesDataFilename())
        try? data?.write(to: URL(fileURLWithPath: path))
    }
    
    // MARK: Persistence
    
    func cacheDataFilename() -> String {
        return "cacheData.dat"
    }
    
    func cacheAddressDataFilename() -> String {
        return "cacheAddress.dat"
    }
    
    func cacheActivitiesDataFilename() -> String {
        return "cacheActivities.dat"
    }
    
    func cacheLiveShareFilename() -> String {
        return "cacheLiveShare.dat"
    }
    
    func cacheDirectory() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
        return documentsPath
    }
    
    func clearCache() {
        let dataPath = cacheDirectory().appending("/" + cacheDataFilename())
        let addressPath = cacheDirectory().appending("/" + cacheAddressDataFilename())
        let activityPath = cacheDirectory().appending("/" + cacheActivitiesDataFilename())
        try? FileManager.default.removeItem(atPath: dataPath)
        try? FileManager.default.removeItem(atPath: addressPath)
        try? FileManager.default.removeItem(atPath: activityPath)
    }
    
    func purgeOldActivities() {
        if let lastPurgeDate = UserDefaults.standard.value(forKey: "lastPurgeActivityDate") as? Date{
            let purgeInterval : TimeInterval = 60*60*24*7
            
            if Date().timeIntervalSince(lastPurgeDate) > purgeInterval {
                let oldActivityDate = Date().addingTimeInterval(-purgeInterval)
                var activitiesDicto = [String : [VehicleActivity]]()
                for (key, vehicleActivities) in activities {
                    var newActivites = [VehicleActivity]()
                    for act in vehicleActivities {
                        newActivites.append(act)
                        if act.startTime.timeIntervalSince(oldActivityDate) < 0{
                            break
                        }
                    }
                    activitiesDicto[key] = newActivites
                }
                self.activities = activitiesDicto
                UserDefaults.standard.setValue(Date(), forKey: "lastPurgeActivityDate")
                autoSaveActivities()
            }
        }else{
            UserDefaults.standard.setValue(Date(), forKey: "lastPurgeActivityDate")
        }
    }
    
    
}

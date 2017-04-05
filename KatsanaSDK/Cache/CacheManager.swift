//
//  CacheManager.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 02/02/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import CoreLocation

let cacheVersion = "2.3"

//Manage and cache reusable KatsanaSDK data including as travel, address, live share, image and vehicle activity. For most part, the framework manages all the caching and developer does not need to use this class manually.
public class CacheManager: NSObject {
    public static let shared = CacheManager()
    
    private var addresses = [Address]()
    public var activities = [String: [VehicleActivity]]()
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
        do{
            let version = try NSString(contentsOfFile: versionPath, encoding: String.Encoding.ascii.rawValue)
            if version as String != cacheVersion {
                clearCache()
                try? cacheVersion.write(toFile: versionPath, atomically: true, encoding: String.Encoding.ascii)
                return
            }
            try? cacheVersion.write(toFile: versionPath, atomically: true, encoding: String.Encoding.ascii)
        }catch{
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
                //Sort activities date
                var newDicto = [String: [VehicleActivity]]()
                for (key, value) in unarchive {
                    let sort = value.sorted { (a, b) -> Bool in
                        return a.startTime.timeIntervalSince(b.startTime) > 0
                    }
                    newDicto[key] = sort
                }
                
                self.activities = newDicto
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
    
//    public func latestTravel(userId: String) -> Travel! {
//        let classname = NSStringFromClass(Travel.self)
//        if let travelArray = data[classname] as? [[String: Any]]{
//            for travelDicto in travelArray {
//                if let travelVehicleId = travelDicto["id"] as? String, let travel = travelDicto["data"] as? Travel {
//                    if travelVehicleId == vehicleId, Calendar.current.isDate(travel.date, inSameDayAs: date){
//                        return travel
//                    }
//                }
//            }
//        }
//        return nil
//    }
    
    ///Get cached travel data given vehicle id and date
    public func trips(vehicleId:String, date:Date, toDate:Date! = nil) -> [Trip]! {
        //Check if date is today, return nil if more than specified time. No local cache is returned and  library should request a new data from server
//        let today = Date()
//        if date.isToday(), travelAccessVehicleId == vehicleId, let todayAccessDate = todayAccessDate, today.timeIntervalSince(todayAccessDate) > 60 * 4 {
//            self.travelAccessVehicleId = vehicleId
//            self.todayAccessDate = today
//            return nil
//        }
        
        let classname = NSStringFromClass(Trip.self)
        if let tripArray = data[classname] as? [[String: Any]]{
            var trips = [Trip]()
            for tripDicto in tripArray {
                if let travelVehicleId = tripDicto["id"] as? String, let trip = tripDicto["data"] as? Trip {
                    if toDate == nil {
                        if travelVehicleId == vehicleId, Calendar.current.isDate(trip.date, inSameDayAs: date){
                            trips.append(trip)
                        }
                    }else{
                        if travelVehicleId == vehicleId{
                            if (Calendar.current.isDate(trip.date, inSameDayAs: date) || (trip.date.isLaterThanDate(date) && trip.date.isEarlierThanDate(toDate))) {
                                trips.append(trip)
                            }
                        }
                    }
                }
            }
            if trips.count == 0 {
                return nil
            }
            return trips
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
        if let travelArray = data[classname] as? [[String: Any]]{
            for travelDicto in travelArray {
                if let travelVehicleId = travelDicto["id"] as? String, let travels = travelDicto["data"] as? [Travel] {
                    for travel in travels {
                        if travelVehicleId == vehicleId, Calendar.current.isDate(travel.date, inSameDayAs: date){
                            return travel
                        }
                    }
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
                    DispatchQueue.main.sync {
                        completion(address)
                    }
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
        let filePath = path.appending("/" + identifier)
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
    
    public func validateVehicleActivities(userId: String, vehicleIds: [String]) {
        if let theActivities = activities[userId]{
            var newActivities = [VehicleActivity]()
            for act in theActivities {
                if let vehicleId = act.vehicleId {
                    if vehicleIds.contains(vehicleId) {
                        newActivities.append(act)
                    }
                }
            }
            activities[userId] = newActivities
            autoSaveActivities()
        }
    }
    
    public func expandedTripListDate(vehicleId: String) -> Date! {
        guard expandedTripList != nil else {
            return nil
        }
        
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
        
        var travelDicto: [[String: Any]]!
        if let array = data[classname] as? [[String: Any]]{
            travelDicto = array
        }else{
            travelDicto = [[String: Any]]()
        }
        
        var needAdd = true
        var needRemoveTravelIndex : Int!
        var theTravels : [Travel]!
        var theUserIndex : Int!
        
        for (userIndex, dicto) in travelDicto.enumerated() {
            if let theVehicleId = dicto["id"] as? String, let travels = dicto["data"] as? [Travel]{
                theTravels = travels
                theUserIndex = userIndex
                var needBreak = false
                for (index, theTravel) in travels.enumerated() {
                    if theTravel.date.isEqualToDateIgnoringTime(travel.date), vehicleId == theVehicleId {
                        if theTravel == travel{
                            needAdd = false
                        }else{
                            needRemoveTravelIndex = index
                            dataChanged = true
                        }
                        needBreak = true
                        break
                    }
                }
                if needBreak {
                    break
                }
            }
        }
        
        if let needRemoveTravelIndex = needRemoveTravelIndex {
            theTravels.remove(at: needRemoveTravelIndex)
        }
        if needAdd {
            if theTravels != nil {
                theTravels.append(travel)
            }else{
                theTravels = [travel]
            }
            dataChanged = true
        }
        
        if dataChanged{
            if let theUserIndex = theUserIndex {
                travelDicto[theUserIndex]["data"] = theTravels
            }else{
                var travelData = ["id": vehicleId, "data": theTravels] as [String : Any]
                travelDicto.append(travelData)
            }
            data[classname] = travelDicto
            autoSave()
        }
    }
    
    public func cache(trip: Trip, vehicleId: String) {
        var dataChanged = false
        let classname = NSStringFromClass(Trip.self)
        
        var tripArray: [[String: Any]]!
        if let array = data[classname] as? [[String: Any]]{
            tripArray = array
        }else{
            tripArray = [[String: Any]]()
        }
        
        var needAdd = true
        var needRemoveTravelIndex : Int!
        
        for (index, dicto) in tripArray.enumerated() {
            if let theTrip = dicto["data"] as? Trip, let theVehicleId = dicto["id"] as? String{
                if theTrip.date.isEqualToDateIgnoringTime(trip.date), vehicleId == theVehicleId {
                    if theTrip == trip{
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
            tripArray.remove(at: needRemoveTravelIndex)
        }
        if needAdd {
            tripArray.append(["data": trip, "id": vehicleId])
            dataChanged = true
        }
        
        if dataChanged{
            data[classname] = tripArray
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
            self.activities[userId] = activities
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
        let filePath = path.appending("/" + identifier)
        #if os(iOS) || os(watchOS) || os(tvOS)
            let data = UIImagePNGRepresentation(image)
        #elseif os(OSX)
            let data = image.tiffRepresentation
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
            return
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
            return
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
            return
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

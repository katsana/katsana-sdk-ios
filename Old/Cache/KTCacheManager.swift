//
//  CacheManager.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 02/02/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import CoreLocation

let cacheVersion = "2.9"

//Manage and cache reusable KatsanaSDK data including as travel, address, live share, image and vehicle activity. For most part, the framework manages all the caching and developer should not use and call methods in this class manually.
public class KTCacheManager: NSObject {
    var logger: Logger!
    
    private static var _shared : KTCacheManager!
    public static var shared: KTCacheManager {
        get{
            if _shared == nil{
                _shared = KTCacheManager()
            }
            return _shared
        }
    }
    
    static public let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYY"
        return formatter
    }()
    
    private var _addresses : [KTAddress]!
    private var addresses : [KTAddress] {
        get{
            if _addresses == nil{
                let theAddresses = loadCachedAddresses()
                _addresses = theAddresses
                purgeOldAddresses()
            }
            if _addresses == nil{
                _addresses = [KTAddress]()
            }
            return _addresses
        }
        set{
            _addresses = newValue
        }
    }
    
    public var activities = [String: [VehicleActivity]]()
    private var liveShares = [LiveShare]()
    
    private var codableData = [String: [String: Codable]]()
    private var codableTripsData = [[String: Codable]]()
    
    
    private var expandedTripList: [String : Date]!
    private var travelAccessVehicleId = 0
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
        
        let dataPath = cachePath()
        let size = sizeForLocalFilePath(filePath: cachePath())
        let sizeStr = covertToFileString(with: size)
        logger?.info("Cache data size = \(sizeStr)")
        
        if let codableData = try? loadCodableData(){
            self.codableData = codableData
        }
        
        clearLocationsIfNeeded(data: self.codableData)
        if size > 500000{
            purgeTravelOlderThan(days: 7)
        }
        
        self.activities = loadCachedActivities() ?? [:]
        purgeOldActivities()
        print(dataPath)
    }
    
    func loadCodableData() throws -> [String: [String: Codable]]! {
        let dataPath = cacheDirectory().appending("/codable" + cacheDataFilename())
        var theData = [String: [String: Codable]]()
        
        let data = try Data(contentsOf: URL(fileURLWithPath: dataPath))
        let decodedData = try JSONDecoder().decode([String: [String: Data]].self, from: data)
        for (key, value) in decodedData{
            if let theClass = NSClassFromString(key) as? Codable.Type{
                var aData = [String:Codable]()
                for (key2, value2) in value{
                    if key2 == "vehicles"{
                        if let theValue = try? JSONDecoder().decode([KTVehicle].self, from: value2){
                            aData[key2] = theValue
                        }
                    }
                    else if key2 == "travels"{
                        if let theValue = try? JSONDecoder().decode([KTDayTravel].self, from: value2){
                            aData[key2] = theValue
                        }
                    }
                    else if let theValue = try? JSONDecoder().decode(theClass, from: value2){
                        aData[key2] = theValue
                    }else{
                        aData[key2] = value2
                    }
                }
                theData[key] = aData
            }
        }
        return theData
    }
    
    func loadCachedAddresses() -> [KTAddress]!{
        let addressPath = KTCacheManager.shared.cacheDirectory().appending("/" + KTCacheManager.shared.cacheAddressDataFilename())
        let url = URL(fileURLWithPath: addressPath)
        if let data = try? Data(contentsOf: url){
            return try? JSONDecoder().decode([KTAddress].self, from: data)
        }
        return nil
    }
    
    func loadCachedActivities() -> [String: [VehicleActivity]]!{
        let activitiesPath = cacheDirectory().appending("/" + cacheActivitiesDataFilename())
        let url = URL(fileURLWithPath: activitiesPath)
        if let data = try? Data(contentsOf: url){
            if let unarchive = try? JSONDecoder().decode([String: [VehicleActivity]].self, from: data){
                //Sort activities date
                var newDicto = [String: [VehicleActivity]]()
                for (key, value) in unarchive {
                    let sort = value.sorted { (a, b) -> Bool in
                        return a.startTime.timeIntervalSince(b.startTime) > 0
                    }
                    newDicto[key] = sort
                }
                return newDicto
            }
        }
        return nil
    }
    
    // MARK: Get Cache
    
    public func lastUser() -> KTUser! {
        let classname = NSStringFromClass(KTUser.self)
        if let user = codableData[classname]?["user"] as? KTUser{
            return user
        }
        return nil
    }
    
    public func vehicles(userId: String) -> [KTVehicle]! {
        let classname = NSStringFromClass(KTVehicle.self)
        if let vehiclesData = codableData[classname], let id = vehiclesData["user"] as? String, userId == id, let vehicles = vehiclesData["vehicles"] as? [KTVehicle]{
            return vehicles
        }
        return nil
    }
    
    public func vehicleSubscriptions(userId: String) -> [VehicleSubscription]! {
        let classname = NSStringFromClass(VehicleSubscription.self)
        if let vehiclesData = codableData[classname], let id = vehiclesData["user"] as? String, userId == id, let subcriptions = vehiclesData["subscriptions"] as? [VehicleSubscription]{
            return subcriptions
        }
        return nil
    }
    
    public func latestVehicleActivity(userId: String) -> VehicleActivity! {
        if let activities = activities[userId]{
            return activities.first //Assume first is latest activity
        }
        return nil
    }
    
    ///Get latest cached travel data
    public func latestTravels(vehicleId: Int, count: Int = 1) -> [KTDayTravel]! {
        let classname = NSStringFromClass(KTDayTravel.self)
        if let travelDicto = codableData[classname]{
            var theTravels : [KTDayTravel]!
            if let theVehicleId = travelDicto["id"] as? Int, vehicleId == theVehicleId, let travels = travelDicto["travels"] as? [KTDayTravel] {
                theTravels = travels
            }
            if theTravels != nil {
                theTravels.sort(by: { (a, b) -> Bool in //Latest is first
                    a.date > b.date
                })
                if count == 1 || count == 0 {
                    if let travel = theTravels.first{
                        return [travel]
                    }
                }
                else{
                    var newTravels = [KTDayTravel]()
                    for (index, travel) in theTravels.enumerated() {
                        if index == count - 1 {
                            break
                        }else{
                            newTravels.append(travel)
                        }
                    }
                    return newTravels
                }
            }
        }
        return nil
    }
    
    ///Get cached travel data given vehicle id and date
    public func trips(vehicleId:String, date:Date, toDate:Date! = nil) -> [KTTrip]! {
        //Check if date is today, return nil if more than specified time. No local cache is returned and  library should request a new data from server
        //        let today = Date()
        //        if date.isToday(), travelAccessVehicleId == vehicleId, let todayAccessDate = todayAccessDate, today.timeIntervalSince(todayAccessDate) > 60 * 4 {
        //            self.travelAccessVehicleId = vehicleId
        //            self.todayAccessDate = today
        //            return nil
        //        }
        
        let classname = NSStringFromClass(KTDayTravel.self)
        if let travelDicto = codableData[classname]{
            var trips = [KTTrip]()
            if let travelVehicleId = travelDicto["id"] as? String, let travels = travelDicto["travels"] as? [KTDayTravel] {
                for travel in travels{
                    if toDate == nil {
                        if travelVehicleId == vehicleId, travel.date.timeIntervalSince(date) > 0{
                            trips.append(contentsOf: travel.trips)
                        }
                    }else{
                        if travelVehicleId == vehicleId{
                            if (travel.date.isLaterThanDate(date) && travel.date.isEarlierThanDate(toDate)) {
                                trips.append(contentsOf: travel.trips)
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
    
    ///Get cached travel data given vehicle id and date without locations data
    public func travel(vehicleId:Int, date:Date) -> KTDayTravel! {
        //Check if date is today, return nil if more than specified time. No local cache is returned and  library should request a new data from server
        let today = Date()
        if date.isToday(), travelAccessVehicleId == vehicleId, let todayAccessDate = todayAccessDate, today.timeIntervalSince(todayAccessDate) > 60 * 4 {
            self.travelAccessVehicleId = vehicleId
            self.todayAccessDate = today
            return nil
        }
        
        let classname = NSStringFromClass(KTDayTravel.self)
        if let travelDicto = codableData[classname]{
            if let theVehicleId = travelDicto["id"] as? Int, vehicleId == theVehicleId, let travels = travelDicto["travels"] as? [KTDayTravel] {
                for travel in travels {
                    let startDay = travel.date.dateAtStartOfDay()
                    if startDay.isEqualToDateIgnoringTime(date){
                        return travel
                    }
                }
            }
        }
        return nil
    }
    
    /*Get cached travel data given vehicle id and date with locations data.
     Previously, all locations are saved in same place as trip summaries, but due to memory issue, all travel locations are saved into separate file, a single file for a day travel.
     */
    public func travelDetail(vehicleId:Int, date:Date) -> KTDayTravel! {
        let dateStr = KTCacheManager.dateFormatter.string(from: date)
        let path = tripPath().appending("/\(dateStr).dat")
        if FileManager.default.fileExists(atPath: path) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
                if let decodedData = try? JSONDecoder().decode(KTDayTravel.self, from: data){
                    return decodedData
                }
            }
        }
        return nil
    }
    
    public func address(for coordinate: CLLocationCoordinate2D, completion: @escaping (_ address: KTAddress?) -> Void) {
        
        let keepAddressDuration : TimeInterval = 60*60*24 * 3*30 //Keep address for 3 months
        let addresses = self.addresses
        DispatchQueue.global(qos: .background).async {
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
    
    public func cache(user: KTUser) {
        let classname = NSStringFromClass(KTUser.self)
//        data[classname] = user
        codableData[classname] = ["user": user]
        autoSave()
    }
    
    public func cache(vehicles: [KTVehicle], userId: String) {
        let classname = NSStringFromClass(KTVehicle.self)
        codableData[classname] = ["vehicles": vehicles, "user": userId]
        autoSave()
    }
    
    public func cache(vehicleSubscription: [VehicleSubscription], userId: String) {
        let classname = NSStringFromClass(VehicleSubscription.self)
        codableData[classname] = ["subscriptions": vehicleSubscription, "user": userId]
        autoSave()
    }
    
    public func cache(travel: KTDayTravel, vehicleId: Int) {
        let aTravel = travel.copy() as! KTDayTravel
        for trip in aTravel.trips{
            cacheTripLocations(trip: trip)
            trip.locations.removeAll()
        }
        
        var dataChanged = false
        let classname = NSStringFromClass(KTDayTravel.self)
        
        var travelDicto: [String: Codable]!
        if let array = codableData[classname]{
            travelDicto = array
        }else{
            travelDicto = [String: Codable]()
        }
        
        var needAdd = true
        var needRemoveTravelIndex : Int!
        var theTravels : [KTDayTravel]!
        
        if let theVehicleId = travelDicto["id"] as? Int, vehicleId == theVehicleId, let travels = travelDicto["travels"] as? [KTDayTravel]{
            theTravels = travels
            for (index, theTravel) in travels.enumerated() {
                //Check if same date
                if theTravel.date.isEqualToDateIgnoringTime(aTravel.date) {
                    if theTravel == aTravel{
                        needAdd = false
                    }else{
                        needRemoveTravelIndex = index
                        dataChanged = true
                    }
                    
                    //Some request does not pass all information, so if old travel data has extra data use that data and save into new response data
                    if aTravel.trips.count == theTravel.trips.count{
                        for (subindex, trip) in travel.trips.enumerated() {
                            let oldTrip = theTravel.trips[subindex]
                            if mergeTrip(trip, with: oldTrip){
                                needRemoveTravelIndex = index
                                dataChanged = true
                            }
                        }
                    }
                }
            }
        }
        
        if let needRemoveTravelIndex = needRemoveTravelIndex {
            theTravels.remove(at: needRemoveTravelIndex)
            theTravels.insert(travel, at: needRemoveTravelIndex)
        }
        if needAdd {
            if theTravels != nil {
                theTravels.append(aTravel)
            }else{
                theTravels = [aTravel]
            }
            dataChanged = true
        }
        
        if dataChanged{
            travelDicto = ["id": vehicleId, "travels": theTravels ?? []]
            codableData[classname] = travelDicto
            autoSave()
        }
    }
    
    ///For normal use of KatsanaSDK, this class is never called except when used for different purpose.
    public func cache(trip: KTTrip, vehicleId: Int) {
        //Save locations in separate file to reduce memory footprint
        cacheTripLocations(trip: trip)
        trip.locations.removeAll()
        
        let classname = NSStringFromClass(KTDayTravel.self)
        var travel: KTDayTravel!
        var travelIndex: Int!
        var theTravels : [KTDayTravel]!
        let travelDicto = codableData[classname]
        
        if let travelDicto = travelDicto{
            if let theVehicleId = travelDicto["id"] as? Int, vehicleId == theVehicleId, let travels = travelDicto["travels"] as? [KTDayTravel] {
                theTravels = travels
                for (index, theTravel) in travels.enumerated() {
                    if theTravel.date.isEqualToDateIgnoringTime(trip.date){
                        travel = theTravel
                        travelIndex = index
                    }
                }
            }
        }
        
        var haveSameTrip = false
        if let travel = travel{
            for aTrip in travel.trips {
                //If less than 2 minute consider as same trip
                if fabs(aTrip.date.timeIntervalSince(trip.date)) < 2*60 {
                    if trip.locations.count > aTrip.locations.count {
                        aTrip.locations = trip.locations
                    }
                    for (key, value) in trip.extraData{
                        aTrip.extraData[key] = value
                    }
                    if trip.score >= 0{
                        aTrip.score = trip.score
                    }
                    haveSameTrip = true
                    break
                }
            }
            if !haveSameTrip {
                var trips = travel.trips
                trips.append(trip)
                trips.sort(by: { (a, b) -> Bool in
                    return a.date < b.date
                })
                travel.trips = trips
            }
        }else{
            travel = KTDayTravel(date: trip.date)
            travel.vehicleId = vehicleId
            travel.trips = [trip]
        }
        
        travel.updateDataFromTrip()
        
        if let travelIndex = travelIndex, var travelDicto = travelDicto{
            theTravels[travelIndex] = travel
            travelDicto = ["id": vehicleId, "travels": theTravels ?? [KTDayTravel]()]
            codableData[classname] = travelDicto
            autoSave()
        }else{
            cache(travel: travel, vehicleId: vehicleId)
        }
    }
    
    func cacheTripLocations(trip: KTTrip) {
        if trip.locations.count == 0{
            return
        }
        
        let dateStr = KTCacheManager.dateFormatter.string(from: trip.date)
        let path = tripPath().appending("/\(dateStr).dat")
        var travel: KTDayTravel!
        if FileManager.default.fileExists(atPath: path), let data = try? Data(contentsOf: URL(fileURLWithPath: path)), let aTravel = try? JSONDecoder().decode(KTDayTravel.self, from: data) {
            var foundIdx : Int!
            for (idx, aTrip) in aTravel.trips.enumerated(){
                if aTrip.date == trip.date{
                    foundIdx = idx
                    break
                }
            }
            if let foundIdx = foundIdx{
                aTravel.trips.remove(at: foundIdx)
                aTravel.trips.insert(trip, at: foundIdx)
            }else{
                var trips = aTravel.trips
                trips.insert(trip, at: 0)
                trips.sort(by: { (a, b) -> Bool in
                    return a.date < b.date
                })
                aTravel.trips = trips
            }
            travel = aTravel
        } else {
            travel = KTDayTravel(date: trip.date)
            travel.trips = [trip]
            travel.updateDataFromTrip()
        }
        
        if let travel = travel{
            let finalCodableData = try? JSONEncoder().encode(travel)
            try? finalCodableData?.write(to: URL(fileURLWithPath: path))
        }
    }
    
    public func cache(address: KTAddress) {
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
    
    public func cache(image: KMImage, identifier: String) {
        let dir = cacheDirectory()
        let path = dir.appending("/Images")
        if !FileManager.default.fileExists(atPath: path){
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        }
        let filePath = path.appending("/" + identifier)
#if os(iOS) || os(watchOS) || os(tvOS)
        
        let data = image.jpegData(compressionQuality: 0.9)
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
    
    @objc func autoSave(forceSave: Bool = false)  {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(autoSave), object: nil)
        if !forceSave{
            if let lastSavedCache = lastSavedCache, Date().timeIntervalSince(lastSavedCache) < 5{
                perform(#selector(autoSave), with: nil, afterDelay: 3)
                return
            }
        }
        lastSavedCache = Date()
        
//        let data = FastCoder.data(withRootObject: self.data)
//        let path = cacheDirectory().appending("/" + cacheDataFilename())
//        try? data?.write(to: URL(fileURLWithPath: path))
        
        //codableData
        let codablePath = cacheDirectory().appending("/codable" + cacheDataFilename())
        var codableDataa = [String: [String: Data]]()
        for (key, value) in codableData{
            var theData = [String: Data]()
            for (key2, value2) in value{
                if let data = try? JSONEncoder().encode(value2){
                    theData[key2] = data
                }
            }
            codableDataa[key] = theData
            
        }
        let finalCodableData = try? JSONEncoder().encode(codableDataa)
        try? finalCodableData?.write(to: URL(fileURLWithPath: codablePath))
        
        
    }
    
    @objc func autosaveAddress() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(autosaveAddress), object: nil)
        if let lastSavedCache = lastSavedAddressCache, Date().timeIntervalSince(lastSavedCache) < 5{
            perform(#selector(autosaveAddress), with: nil, afterDelay: 3)
            return
        }
        lastSavedAddressCache = Date()
        
        let data = try? JSONEncoder().encode(self.addresses)
        let path = cacheDirectory().appending("/" + cacheAddressDataFilename())
        try? data?.write(to: URL(fileURLWithPath: path))
    }
    
    @objc func autoSaveActivities() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(autoSaveActivities), object: nil)
        if let lastSavedCache = lastSavedActivitiesCache, Date().timeIntervalSince(lastSavedCache) < 5{
            perform(#selector(autoSaveActivities), with: nil, afterDelay: 3)
            return
        }
        lastSavedActivitiesCache = Date()
        
        let data = try? JSONEncoder().encode(self.activities)
        let path = cacheDirectory().appending("/" + cacheActivitiesDataFilename())
        try? data?.write(to: URL(fileURLWithPath: path))
    }
    
    // MARK: Data Clear
    
    ///Clear travel cache for specified date ranges
    public func clearTravelCache(vehicleId: String, date: Date! = nil, toDate: Date! = nil) {
        //        var dataChanged = false
        let classname = NSStringFromClass(KTDayTravel.self)
        
        var travelDicto: [String: Codable]!
        if let array = codableData[classname]{
            travelDicto = array
        }else{
            travelDicto = [String: Codable]()
        }
        
            if let theVehicleId = travelDicto["id"] as? String, vehicleId == theVehicleId, var travels = travelDicto["travels"] as? [KTDayTravel]{
                //                var indexset = IndexSet()
                var startIndex : Int!
                var endIndex : Int!
                
                if date == nil, toDate == nil {
                    //Remove all data
                    travelDicto["travels"] = nil
                    codableData[classname] = travelDicto
                    autoSave()
                }else{
                    for (index, theTravel) in travels.enumerated() {
                        if toDate == nil{
                            if theTravel.date.isEqualToDateIgnoringTime(date){
                                startIndex = index
                                break
                            }
                        }else{
                            if theTravel.date.timeIntervalSince(date.dateAtStartOfDay()) >= 0, toDate.timeIntervalSince(theTravel.date.dateAtStartOfDay()) >= 0 {
                                if startIndex == nil{
                                    startIndex = index
                                }else{
                                    endIndex = index
                                }
                            }
                        }
                    }
                    
                    if let startIndex = startIndex{
                        if let endIndex = endIndex{
                            travels.removeSubrange(startIndex ... endIndex)
                        }else{
                            travels.remove(at: startIndex)
                        }
                        
                        travelDicto["travels"] = travels
                        codableData[classname] = travelDicto
                        autoSave()
                    }
                }
            }
    }
    
    ///Clear travel cache for specified date ranges
    public func clearTripCache(vehicleId: String, date: Date, toDate: Date) {
        let classname = NSStringFromClass(KTDayTravel.self)
        
        if var travelDicto = codableData[classname]{
            if let theVehicleId = travelDicto["id"] as? String, vehicleId == theVehicleId, let travels = travelDicto["travels"] as? [KTDayTravel]{
                var dataChanged = false
                
                for (_, theTravel) in travels.enumerated() {
                    var indexesNeedClear = [Int]()
                    for (tripIndex, trip) in theTravel.trips.enumerated(){
                        if trip.date.timeIntervalSince(date) >= 0, trip.date.timeIntervalSince(toDate) <= 0{
                            indexesNeedClear.append(tripIndex)
                            dataChanged = true
                        }
                    }
                    if indexesNeedClear.count == 1{
                        theTravel.trips.remove(at: indexesNeedClear.first!)
                    }else if indexesNeedClear.count > 1, let first = indexesNeedClear.first, let last = indexesNeedClear.last{
                        theTravel.trips.removeSubrange(first...last)
                    }
                }
                if dataChanged {
                    travelDicto["travels"] = travels
                    codableData[classname] = travelDicto
                    autoSave()
                }
            }
        }
    }
    
    func clearCache() {
        let dataPath = cacheDirectory().appending("/" + cacheDataFilename())
        let addressPath = cacheDirectory().appending("/" + cacheAddressDataFilename())
        let activityPath = cacheDirectory().appending("/" + cacheActivitiesDataFilename())
        let codableDataPath = cacheDirectory().appending("/codable" + cacheDataFilename())
        
        try? FileManager.default.removeItem(atPath: dataPath)
        try? FileManager.default.removeItem(atPath: codableDataPath)
        try? FileManager.default.removeItem(atPath: addressPath)
        try? FileManager.default.removeItem(atPath: activityPath)
        try? FileManager.default.removeItem(atPath: tripPath())
        _tripPath = nil
    }
    
    func clearMemory() {
        KTCacheManager._shared = nil
    }
    
    func clearLocationsIfNeeded(data: [String: [String: Codable]]){
        if let travelDicto = data[NSStringFromClass(KTDayTravel.self)]{
            if let travels = travelDicto["travels"] as? [KTDayTravel] {
                for travel in travels{
                    for trip in travel.trips{
                        if trip.locations.count > 100000{
                            trip.locations.removeAll()
                        }
                    }
                }
            }
        }
    }
    
    func purgeTravelOlderThan(days: Int) {
        let lastPurgeDate = UserDefaults.standard.value(forKey: "lastPurgeTravelDate")
        let purgeInterval : TimeInterval = 60*60*24*TimeInterval(days)
        
        var canContinue = false
        if let lastPurgeDate = lastPurgeDate as? Date, Date().timeIntervalSince(lastPurgeDate) > purgeInterval{
            canContinue = true
        }else if lastPurgeDate == nil{
            UserDefaults.standard.setValue(Date(), forKey: "lastPurgeTravelDate")
        }
        
        if canContinue {
            let classname = NSStringFromClass(KTDayTravel.self)
            
            if var travelDicto = codableData[classname]{
                if var travels = travelDicto["travels"] as? [KTDayTravel] {
                    travels.sort(by: { (a, b) -> Bool in //Latest is last
                        a.date < b.date
                    })
                    var newTravels = [KTDayTravel]()
                    for (index, travel) in travels.enumerated().reversed(){
                        if Date().daysAfterDate(travel.date) > days{
                            newTravels = Array(travels.suffix(from: index))
                            break
                        }
                    }
                    travelDicto["travels"] = newTravels
                }
                codableData[classname] = travelDicto
            }
            UserDefaults.standard.setValue(Date(), forKey: "lastPurgeTravelDate")
            autoSave()
        }
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
    
    func purgeOldAddresses() {
        if let addresses = _addresses{
            var diff = _addresses.count - 150
            if diff > 0{
                diff -= 10
                if diff > 0{
                    _addresses = Array(addresses.suffix(from: diff))
                }
            }
        }
    }
    
    // MARK: Logic
    
    ///Merge two trips
    func mergeTrip(_ trip: KTTrip, with oldTrip: KTTrip) -> Bool {
        var merged = false
        if trip.extraData.count == 0{
            if oldTrip.extraData.count > 0 {
                merged = true
                trip.extraData = oldTrip.extraData
            }
        }
        if trip.locations.count == 0, oldTrip.locations.count > 0{
            trip.locations = oldTrip.locations.map({$0})
        }
        return merged
    }
    
    // MARK: Persistence
    
    func cacheDataFilename() -> String {
        return "cacheData.dat"
    }
    
    func cacheAddressDataFilename() -> String {
        return "cacheAddress.dat"
    }
    
    func cacheTravelsDataFilename() -> String {
        return "travel.dat"
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
    
    func cachePath() -> String{
        return cacheDirectory().appending("/" + cacheDataFilename())
    }
    
    private var _tripPath: String!
    private func tripPath() -> String
    {
        if _tripPath != nil{
            return _tripPath!
        }
        createLogFolderIfNeeded()
        _tripPath = cacheDirectory().appending("/trip")
        return _tripPath
    }
    
    private func createLogFolderIfNeeded() {
        let triplogPath = cacheDirectory().appending("/trip")
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: triplogPath) {
            do {
                try fileManager.createDirectory(atPath: triplogPath,
                                                withIntermediateDirectories: false,
                                                attributes: nil)
            } catch {
                logger?.error("Error creating log folder in dir: \(error)")
            }
        }
    }
    
    // MARK: Helper
    
    func sizeForLocalFilePath(filePath:String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    
    func covertToFileString(with size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
    
}

//
//  ObjectJSONTransformer.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//


/// Class to convert Swifty JSON to API object
class ObjectJSONTransformer {
    ///Use this handler if need to have extra setup when object is initialized
    static public var objectInitializationHandler : ((JSON, Any) -> (Void))!
    
    class func UserObject(json : JSON) -> KTUser {
        let email = json["email"].stringValue
        let user = KTUser(email: email)
        user.userId = json["id"].stringValue
        user.address = json["address"].stringValue
        user.phoneHome = json["phone_home"].stringValue
        user.phoneMobile = json["phone_mobile"].stringValue
        user.fullname = json["fullname"].stringValue
        user.emergencyFullName = json["meta"]["fullname"].stringValue
        user.emergencyPhoneHome = json["meta"]["phone"]["home"].stringValue
        user.emergencyPhoneMobile = json["meta"]["phone"]["mobile"].stringValue
        user.imageURL = json["avatar"]["url"].stringValue
        
        user.address = json["address"].stringValue
        if let gender = json["gender"].string, (gender == "male" || gender == "female"){
            user.gender = Gender(rawValue: gender)!
        }
        if let fleets = json["fleets"].array{
            var theFleets = [Fleet]()
            for fleet in fleets{
                let aFleet = Fleet()
                aFleet.fleetId = fleet["id"].intValue
                aFleet.name = fleet["name"].stringValue
                aFleet.deviceCount = fleet["devices"].intValue
                theFleets.append(aFleet)
            }
            user.fleets = theFleets
        }
        
        user.country = json["country"].stringValue
        user.state = json["state"].stringValue
        user.postcode = json["postcode"].stringValue
        user.birthdayText = json["birthday"].stringValue
        
        user.planId = json["plan"]["id"].int
        user.planName = json["plan"]["name"].string
        user.planDescription = json["plan"]["description"].string
        
        user.createdAt = json["created_at"].date(gmt: 0)
        user.updatedAt = json["updated_at"].date(gmt: 0)
        objectInitializationHandler?(json, KTUser.self)
        return user
    }
    
    class func VehiclesObject(json : JSON) -> [KTVehicle]{
        let arr = json["devices"].arrayValue
        let vehicles = arr.map{VehicleObject(json: $0)}
        return vehicles
    }
    
    class func VehicleObject(json : JSON) -> KTVehicle {
        var dicto = json["device"]
        //Check if called from vehicle or vehicles API
        if dicto.dictionaryValue.keys.count == 0 {
            dicto = json
        }
        
        let vehicle = KTVehicle()
        vehicle.userId = dicto["user_id"].stringValue
        vehicle.vehicleId = dicto["id"].stringValue
        vehicle.driver = dicto["live_status"]["driver"].string
        
        vehicle.imei = dicto["imei"].stringValue
        vehicle.mode = dicto["mode"].stringValue
        vehicle.timezone = dicto["timezone"].stringValue
        vehicle.todayMaxSpeed = dicto["today_max_speed"].floatValue
        vehicle.imageURL = dicto["avatar"].stringValue
        vehicle.thumbImageURL = dicto["marker"].stringValue
        vehicle.odometer = dicto["odometer"].doubleValue
        vehicle.websocketSupported = dicto["meta"]["websocket"].boolValue
        vehicle.earliestTravelDate = dicto["earliest_date"].dateWithoutTime
        if let fuel = dicto["fuel_percentage"].float{
            vehicle.fuelPercentage = fuel
        }
        
        if let fleets = dicto["fleets"].array{
            var fleedIds = [Int]()
            for fleet in fleets{
                if let id = fleet.int{
                    fleedIds.append(id)
                }
            }
            vehicle.fleetIds = fleedIds
        }
        
        if let val = dicto["sensors"]["temperature"]["value"].float{
            vehicle.temperatureValue = val
            vehicle.temperatureStatus = dicto["sensors"]["temperature"]["status"].stringValue
        }
        if let val = dicto["sensors"]["fuel"]["capacity"].float{
            let litre = dicto["sensors"]["fuel"]["litre"].stringValue
            if let litreFloat = Float(litre){
                vehicle.fuelLitre = litreFloat
            }
            vehicle.fuelPercentage = dicto["sensors"]["fuel"]["percentage"].floatValue
            vehicle.fuelCapacity = val
            vehicle.fuelStatus = dicto["sensors"]["fuel"]["status"].string
        }
        
        
        if let sensors = dicto["sensors"]["others"].array{
            var theSensors = [Sensor]()
            for sensor in sensors{
                let aSensor = Sensor()
                aSensor.event = sensor["event"].stringValue
                aSensor.input = sensor["input"].intValue
                aSensor.name = sensor["name"].stringValue
                let sensorType = sensor["sensor"].stringValue
                if sensorType.lowercased() == "arm"{
                    aSensor.sensorType = .arm
                }else if sensorType.lowercased() == "door"{
                    aSensor.sensorType = .door
                }
                aSensor.deviceType = sensor["type"].stringValue
                theSensors.append(aSensor)
            }
            vehicle.sensors = theSensors
        }
        
        vehicle.vehicleNumber = dicto["vehicle_number"].stringValue
        if vehicle.vehicleNumber == "" {
            vehicle.vehicleNumber = dicto["license_plate"].stringValue
        }
        vehicle.vehicleDescription = dicto["description"].stringValue
        vehicle.manufacturer = dicto["manufacturer"].stringValue
        vehicle.model = dicto["model"].stringValue
        vehicle.insuredExpiryText = dicto["insured"]["expiry"].stringValue
        vehicle.insuredBy = dicto["insured"]["by"].stringValue
        
        vehicle.subscriptionEnd = dicto["ends_at"].date
        vehicle.current = self.VehicleLocationObject(json: dicto["current"])
        
        if let features = dicto["features"].arrayObject{
            vehicle.extraData["features"] = features
        }
        
        objectInitializationHandler?(json, KTUser.self)
        
        return vehicle
    }
    
    class func VehicleLocationObject(json : JSON) -> VehicleLocation {
        let latitude = json["latitude"].doubleValue
        let longitude = json["longitude"].doubleValue
        let pos = VehicleLocation(latitude: latitude, longitude: longitude)
        
        pos.altitude = json["altitude"].doubleValue
        pos.course = json["course"].doubleValue
        pos.latitude = json["latitude"].doubleValue
        pos.longitude = json["longitude"].doubleValue
//        pos.distance = json["distance"].floatValue
//        pos.fuelPercentage = json["mode"].string
        pos.speed = json["speed"].floatValue
        pos.state = json["state"].stringValue
        pos.voltage = json["voltage"].stringValue
        pos.gsm = json["gsm"].stringValue
        pos.ignitionState = json["ignition"].boolValue
        let date = json["tracked_at"].date(gmt: 0)
        pos.trackedAt = date
        
        if let harsh = json["harsh"].dictionaryObject{
            pos.extraData["harsh"] = harsh
        }
        return pos
    }
    
    class func VideoRecordingObjects(json : JSON) -> [VideoRecording]{
        let arr = json["vehicles"].arrayValue
        let vehicles = arr.map{VideoRecordingObject(json: $0)}
        return vehicles
    }
    
    class func VideoRecordingObject(json : JSON) -> VideoRecording {
        let video = VideoRecording()
        var theChannels = [VideoRecordingChannel]()
        let channels = json["dvr"]["channels"].dictionaryValue
        for (key, value) in channels {
            let theChannel = VideoRecordingChannel()
            theChannel.name = value["name"].string
            if let status = value["status"].string, status == "On"{
                theChannel.isOn = true
            }
            theChannel.identifier = key
            theChannels.append(theChannel)
        }
        theChannels.sort { a, b in
            if let id1 = a.identifier, let id2 = b.identifier{
                return id1 < id2
            }
            return false
        }
        video.channels = theChannels
        video.liveStreamURL = json["dvr"]["liveStreamURL"].string
        if let id = json["id"].int{
            video.id = String(id)
        }
        if let ratio = json["dvr"]["ratio"].arrayObject as? [Int], ratio.count > 1{
            video.horizontalRatio = ratio[0]
            video.verticalRatio = ratio[1]
        }
        return video
    }
    
    class func VideoPlaybackObjects(json : JSON) -> [VideoPlayback]{
        var allPlaybacks = [VideoPlayback]()
        let arr = json["vehicles"].arrayValue
        for vehicle in arr{
            let playbacksJSON = vehicle["dvr"]["playback"].arrayValue
            let playbacks = playbacksJSON.map{VideoPlaybackObject(json: $0)}
            allPlaybacks.append(contentsOf: playbacks)
        }
        return allPlaybacks
    }
    
    class func VideoPlaybackObject(json : JSON) -> VideoPlayback {
        let video = VideoPlayback()
        video.channelIdentifier = json["channel"].string
        if let id = json["channel"].int{
            video.channelIdentifier = String(id)
        }else{
            video.channelIdentifier = json["channel"].string
        }
        if let id = json["id"].int{
            video.id = String(id)
        }else{
            video.id = json["id"].string
        }
        if let deviceId = json["device_id"].int{
            video.deviceId = String(deviceId)
        }else{
            video.deviceId = json["device_id"].string
        }
        
        video.filename = json["filename"].string
        
        let date = json["date"].stringValue
        let startTime = date + " " + json["start_time"].stringValue
        video.startTime = Formatter.jsonDateFormatter2.date(from: startTime)
        video.duration = CGFloat(json["duration"].floatValue)
        video.endTime = video.startTime?.addingTimeInterval(video.duration)
        return video
    }
    
    class func TravelSummariesObject(json : JSON) -> [Travel] {
        var summaries = [Travel]()
        let array = json.arrayValue
        for jsonObj in array {
            let history = TravelSummaryObject(json: jsonObj)
            summaries.append(history)
        }
        return summaries
    }
    
    class func TripSummariesObject(json : JSON) -> [KTTrip] {
        var summaries = [KTTrip]()
        let array = json.arrayValue
        for jsonObj in array {
            let history = TripObject(json: jsonObj)
            summaries.append(history)
        }
        return summaries
    }
    
    class func TravelSummaryObject(json : JSON) -> Travel {
        let history = Travel()
        history.maxSpeed = json["max_speed"].floatValue
        history.distance = json["distance"].doubleValue
        history.violationCount = json["violation"].intValue
        history.tripCount = json["trip"].intValue
        history.duration = json["duration"].doubleValue
        history.idleDuration = json["idle_duration"].doubleValue
        history.date = json["date"].dateWithoutTime
//        /change date to local date and check UTC time again
        objectInitializationHandler?(json, KTUser.self)
        return history
    }
    
    class func TravelObject(json : JSON) -> Travel {
        let history = Travel()
        history.maxSpeed = json["summary"]["max_speed"].floatValue
        history.distance = json["summary"]["distance"].doubleValue
        history.violationCount = json["summary"]["violation"].intValue
        history.trips = json["trips"].arrayValue.map{TripObject(json: $0)}
        history.date = json["duration"]["from"].date(gmt: 0)
        objectInitializationHandler?(json, KTUser.self)
        return history
    }
    
    class func TripObject(json : JSON) -> KTTrip {
        let trip = KTTrip()
        trip.maxSpeed = json["max_speed"].floatValue
        trip.distance = json["distance"].doubleValue
        trip.duration = json["duration"].doubleValue
        trip.averageSpeed = json["average_speed"].floatValue
        trip.idleDuration = json["idle_duration"].floatValue
        trip.id = json["id"].stringValue
        
        trip.start = VehicleLocationObject(json: json["start"])
        trip.end = VehicleLocationObject(json: json["end"])
        trip.idles = json["idles"].arrayValue.map{VehicleLocationObject(json: $0)}
        trip.locations = json["histories"].arrayValue.map {VehicleLocationObject(json: $0)}
        trip.violations = json["violations"].arrayValue.map {VehicleActivityObject(json: $0)}
        trip.score = json["score"].floatValue
        let type = json["type"].stringValue
        if type == "public_transit"{
            trip.publicTransit = true
        }
        
        objectInitializationHandler?(json, KTUser.self)
        return trip
    }
    
    class func AddressObject(json : JSON) -> KTAddress {
        let address = KTAddress()
        address.latitude = json["latitude"].doubleValue
        address.longitude = json["longitude"].doubleValue
        let streetNumber = json["street_number"].stringValue
        address.streetNumber = streetNumber
        address.streetName = json["street_name"].stringValue
        address.locality = json["locality"].stringValue
        address.city = json["locality"].stringValue
        address.sublocality = json["sublocality"].stringValue
        address.postcode = json["postcode"].intValue
        address.country = json["country"].stringValue
        address.address = json["address"].stringValue
        return address
    }
    
    class func VehicleActivityObject(json : JSON) -> VehicleActivity {
        let violation = VehicleActivity()
        violation.violationId = json["id"].intValue
        violation.policyId = json["policy_id"].intValue
        violation.policyKey = json["policy_type"].stringValue
        violation.address = json["address"].stringValue
        violation.distance = json["distance"].floatValue
        violation.duration = json["duration"].floatValue
        violation.latitude = json["latitude"].doubleValue
        violation.longitude = json["longitude"].doubleValue
        if let date = json["start_time"].date(gmt: 0){
            violation.startTime = date
        }
        if let date = json["end_time"].date(gmt: 0){
            violation.endTime = date
        }
        violation.startPosition = json["start_position"].intValue
        violation.endPosition = json["end_position"].intValue
        violation.maxSpeed = json["max_speed"].floatValue
        violation.averageSpeed = json["average_speed"].floatValue
        violation.message = json["description"].stringValue
        
        return violation
    }
    
    class func LiveShareObject(json : JSON) -> LiveShare {
        let share = LiveShare()
        share.deviceId = json["device_id"].stringValue
        share.userId = json["user_id"].stringValue
        share.token = json["token"].stringValue
        let urlPath = json["url"].stringValue
        share.url = URL(string: urlPath)
//        share.type = json["type"].stringValue
        share.shareDescription = json["description"].stringValue
        share.startAt = json["started_at"].date(gmt: 0)
        share.endAt = json["ended_at"].date(gmt: 0)
//        share.updatedAt = json["updated_at"].date(gmt: 0)
        share.shareId = json["id"].stringValue
//        share.durationText = json1["duration"].stringValue
        return share
    }
    
    class func InsurersObject(json : JSON) -> [KTInsurer] {
        var insurers = [KTInsurer]()
        let array = json.arrayValue
        for jsonObj in array {
            let name = jsonObj["name"].stringValue
            let country = jsonObj["country"].stringValue
            let partner = jsonObj["partner"].boolValue
            let insurer = KTInsurer(name: name, country: country, partner: partner)
            insurers.append(insurer)
        }
        return insurers
    }
    
    class func VehicleSubscriptionsObject(json : JSON) -> [VehicleSubscription] {
        var subscribes = [VehicleSubscription]()
        let array = json.arrayValue
        for jsonObj in array {
            let history = VehicleSubscriptionObject(json: jsonObj)
            subscribes.append(history)
        }
        return subscribes
    }

    class func VehicleSubscriptionObject(json : JSON) -> VehicleSubscription {
        let subscribe = VehicleSubscription()
        subscribe.deviceId = json["device_id"].stringValue
        subscribe.deviceImei = json["device_imei"].stringValue
        subscribe.vehicleExpiredAt = json["expired_at"].date(gmt: 0)
        subscribe.vehicleDescription = json["description"].stringValue
        subscribe.vehicleNumber = json["vehicle_number"].stringValue
        subscribe.isReseller = json["reseller"].boolValue
        
        subscribe.subscriptionId = json["subscription"]["id"].stringValue
        subscribe.subscriptionPrice = json["subscription"]["price"]["price"].intValue
        subscribe.subscriptionPriceWithTax = json["subscription"]["price"]["price_with_tax"].intValue
        subscribe.subscriptionTax = json["subscription"]["price"]["tax"].floatValue
        subscribe.subscriptionStartAt = json["subscription"]["starts_at"].date(gmt: 0)
        subscribe.subscriptionEndAt = json["subscription"]["ends_at"].date(gmt: 0)
        
        subscribe.planId = json["subscription"]["plan"]["id"].stringValue
        subscribe.planName = json["subscription"]["plan"]["name"].stringValue
        subscribe.planDescription = json["subscription"]["plan"]["description"].stringValue
        subscribe.planPrice = json["subscription"]["plan"]["price"].intValue
        subscribe.planBillingCycle = json["subscription"]["plan"]["billing_cycle"].intValue
        subscribe.planQuickBooksId = json["subscription"]["plan"]["quickbooks_id"].stringValue
        subscribe.planRenewalAddonId = json["subscription"]["plan"]["renewal_addon_id"].stringValue
        subscribe.planTagId = json["subscription"]["plan"]["tag_id"].stringValue
        subscribe.planType = json["subscription"]["plan"]["type"].stringValue
        subscribe.planCreatedAt = json["subscription"]["created_at"].date(gmt: 0)
        subscribe.planUpdatedAt = json["subscription"]["updated_at"].date(gmt: 0)
        
        return subscribe
    }
    
    class func RegisterVehicleObject(json : JSON) -> KTVehicle {
        let device = json["device"]
        return ObjectJSONTransformer.VehicleObject(json: device)
    }
}

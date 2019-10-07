//
//  ObjectJSONTransformer.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//


/// Class to convert Swifty JSON to API object
class ObjectJSONTransformer: NSObject {
    class func UserObject(json : JSON) -> User {
        let email = json["email"].stringValue
        let user = User(email: email)
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
        user.country = json["country"].stringValue
        user.state = json["state"].stringValue
        user.postcode = json["postcode"].stringValue
        user.birthdayText = json["birthday"].stringValue
        
        user.createdAt = json["created_at"].date(gmt: 0)
        user.updatedAt = json["updated_at"].date(gmt: 0)
        if let handler = KatsanaAPI.shared.objectInitializationHandler {
            handler(json, User.self)
        }
        return user
    }
    
    class func VehiclesObject(json : JSON) -> [Vehicle]{
        let arr = json["devices"].arrayValue
        let vehicles = arr.map{VehicleObject(json: $0)}
        return vehicles
    }
    
    class func VehicleObject(json : JSON) -> Vehicle {
        var dicto = json["device"]
        //Check if called from vehicle or vehicles API
        if dicto.dictionaryValue.keys.count == 0 {
            dicto = json
        }
        
        let vehicle = Vehicle()
        vehicle.userId = dicto["user_id"].stringValue
        vehicle.vehicleId = dicto["id"].stringValue
        
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
        
        if let handler = KatsanaAPI.shared.objectInitializationHandler {
            handler(json, vehicle)
        }
        
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
    
    class func TravelSummariesObject(json : JSON) -> [Travel] {
        var summaries = [Travel]()
        let array = json.arrayValue
        for jsonObj in array {
            let history = TravelSummaryObject(json: jsonObj)
            summaries.append(history)
        }
        return summaries
    }
    
    class func TripSummariesObject(json : JSON) -> [Trip] {
        var summaries = [Trip]()
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
        if let handler = KatsanaAPI.shared.objectInitializationHandler {
            handler(json, history)
        }
        return history
    }
    
    class func TravelObject(json : JSON) -> Travel {
        let history = Travel()
        history.maxSpeed = json["summary"]["max_speed"].floatValue
        history.distance = json["summary"]["distance"].doubleValue
        history.violationCount = json["summary"]["violation"].intValue
        history.trips = json["trips"].arrayValue.map{TripObject(json: $0)}
        history.date = json["duration"]["from"].date(gmt: 0)
        if let handler = KatsanaAPI.shared.objectInitializationHandler {
            handler(json, history)
        }
        return history
    }
    
    class func TripObject(json : JSON) -> Trip {
        let trip = Trip()
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
        
        if let handler = KatsanaAPI.shared.objectInitializationHandler {
            handler(json, trip)
        }
        return trip
    }
    
    class func AddressObject(json : JSON) -> Address {
        let address = Address()
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
    
    class func InsurersObject(json : JSON) -> [Insurer] {
        var insurers = [Insurer]()
        let array = json.arrayValue
        for jsonObj in array {
            let name = jsonObj["name"].stringValue
            let country = jsonObj["country"].stringValue
            let partner = jsonObj["partner"].boolValue
            let insurer = Insurer(name: name, country: country, partner: partner)
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
        subscribe.id = json["id"].stringValue
        subscribe.userId = json["user_id"].stringValue
        subscribe.planId = json["plan"]["id"].stringValue
        subscribe.planName = json["plan"]["name"].stringValue
        subscribe.planDescription = json["plan"]["description"].stringValue
        subscribe.endsAt = json["ends_at"].date(gmt: 0)
        let status = json["status"].stringValue
        if status == "active" {
            subscribe.status = .active
        }else if status == "grace"{
            subscribe.status = .grace
        }else{
            subscribe.status = .expired
        }
        
        subscribe.isExpiring = json["is_expiring"].boolValue
        subscribe.amountBeforeTax = json["amount"]["before_gst"].floatValue
        subscribe.amountAfterTax = json["amount"]["after_gst"].floatValue
        subscribe.taxPercent = json["amount"]["gst_percent"].floatValue
        subscribe.taxAmount = json["amount"]["gst_amount"].floatValue
        subscribe.billingCycle = json["plan"]["billing_cycle"].intValue
        
        var subscribeUpgrades = [VehicleSubscription]()
        if let upgrades = json["plan"]["upgrades"].array{
            for upgradeJSON in upgrades{
                let upgrade = VehicleSubscription()
                upgrade.id = subscribe.id
                upgrade.billingCycle = upgradeJSON["billing_cycle"].intValue
                upgrade.userId = subscribe.userId
                upgrade.planId = upgradeJSON["plan_id"].stringValue
                upgrade.planName = upgradeJSON["name"].stringValue
                upgrade.planDescription = upgradeJSON["description"].stringValue
                upgrade.amountBeforeTax = json["amount"]["before_gst"].floatValue
                upgrade.amountAfterTax = json["amount"]["after_gst"].floatValue
                upgrade.taxPercent = json["amount"]["gst_percent"].floatValue
                upgrade.taxAmount = json["amount"]["gst_amount"].floatValue
                subscribeUpgrades.append(upgrade)
            }
        }
        subscribe.upgrades = subscribeUpgrades
        
        var devices = [Vehicle]()
        if let devicesArray = json["devices"].array{
            for deviceJSON in devicesArray{
                let device = Vehicle()
                device.vehicleId = deviceJSON["id"].stringValue
                device.vehicleNumber = deviceJSON["vehicle_number"].stringValue
                device.vehicleDescription = deviceJSON["description"].stringValue
                devices.append(device)
            }
        }
        subscribe.devices = devices
        
        return subscribe
    }
    
    class func RegisterVehicleObject(json : JSON) -> Vehicle {
        let device = json["device"]
        return ObjectJSONTransformer.VehicleObject(json: device)
    }
}

//
//  KatsanaAPI+Trip.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Siesta

extension KatsanaAPI {
    @nonobjc static let maxDaySummary = 3;
    
    public func requestTravelSummaryToday(vehicleId: String, completion: @escaping (_ summary: Travel?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "vehicles/" + vehicleId + "/summaries/today"
        let resource = API.resource(path);
        let request = resource.loadIfNeeded()
        
        
        request?.onSuccess({(entity) in
            let summary : Travel? = resource.typedContent()
            summary?.vehicleId = vehicleId
            completion(summary)
            }).onFailure({ (error) in
                failure(error)
                self.log.error("Error getting trip summary today vehicle id \(vehicleId), \(error)")
            })
        
        if request == nil {
            let summary : Travel? = resource.typedContent()
            completion(summary)
        }
    }
    
    ///Request travel summaries between dates. Only trip count is loaded, travel details are omitted.
    public func requestTravelSummaries(vehicleId: String, fromDate: Date!, toDate: Date, forceRequest: Bool = false, completion: @escaping (_ summaries:[Travel]?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let dates = validateRange(fromDate: fromDate, toDate: toDate)
        var newFromDate = dates.fromDate
        var newToDate = dates.toDate
        var travels = [Travel]()
        
        if !forceRequest{
            let datesWithHistory = requiredRangeToRequestTravelSummary(fromDate: dates.fromDate, toDate: dates.toDate, vehicleId: vehicleId)
            newFromDate = datesWithHistory.fromDate
            newToDate = datesWithHistory.toDate
            travels = datesWithHistory.cachedHistories
        }

        let path = "vehicles/" + vehicleId + "/summaries/duration"
        
        let resource = API.resource(path).withParam("start", newFromDate.toStringWithYearMonthDay()).withParam("end",newToDate.toStringWithYearMonthDay());
        let request = resource.loadIfNeeded()
        
        func handleResource() -> Void {
            if let summaries : [Travel] = resource.typedContent(){
                for summary in summaries{
                    //Remove duplicate history
                    var duplicateHistoryNeedRemove : Travel!
                    for travel in travels{
                        if summary.date.isEqualToDateIgnoringTime(travel.date){
                            if summary.tripCount > travel.trips.count{
                                summary.needLoadTripHistory = true
                            }else{
                                summary.needLoadTripHistory = false
                            }
                            summary.trips = travel.trips
                            duplicateHistoryNeedRemove = travel
                        }
                    }
                    if duplicateHistoryNeedRemove != nil{
                        travels.remove(at: travels.index(of: duplicateHistoryNeedRemove)!)
                    }
                    
                    
                    summary.needLoadTripHistory = true //Always need load trip summary if loaded from summary API
                    summary.lastUpdate = Date()
                    summary.vehicleId = vehicleId
                    
                    //Cache history for days more than maxDaySummary, because it may already contain trip but still not finalized on the server
                    if Date().daysAfterDate((summary.date)!) > KatsanaAPI.maxDaySummary{
                        CacheManager.shared.cache(travel: summary, vehicleId: vehicleId)
                    }
                }
                travels.append(contentsOf: summaries)
                travels.sort(by: { $0.date > $1.date })
                completion(travels)
            }else{
                failure(nil)
            }
        }
        
        request?.onSuccess({(entity) in
            handleResource()
        }).onFailure({ (error) in
            failure(error)
            self.handleError(error: error, details: "Error getting trip summaries with original from \(String(describing: fromDate)) to \(toDate) and final from \(newFromDate) to \(newToDate),  \(error)")
        })
        if request == nil {
            handleResource()
        }
    }
    
    ///Request travel details for given date
    public func requestTravel(for date: Date, vehicleId: String, loadLocations: Bool = false, forceLoad: Bool = false, options: [String]! = nil, completion: @escaping (_ history: Travel?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        var travel : Travel!
        if !forceLoad{
            if loadLocations {
                travel = CacheManager.shared.travelDetail(vehicleId: vehicleId, date: date)
            }else{
                travel = CacheManager.shared.travel(vehicleId: vehicleId, date: date)
            }
        }
        
        if let travel = travel, travel.needLoadTripHistory == false{
            var needLoad = false
            for trip in travel.trips {
                if trip.locations.count <= 2 || trip.score == -1{
                    needLoad = true
                    break
                }
                else if trip.locations.count > 3, let last = trip.locations.last?.trackedAt, let secondLast = trip.locations[trip.locations.count-2].trackedAt{
                    if last == secondLast{
                        needLoad = true
                        break
                    }
                }
            }
            if travel.trips.count == 0{
                needLoad = true
            }

            if !needLoad{ //Can load from cache only if locations count > 0
                self.log.debug("Get trip history from cached data vehicle id \(vehicleId), date \(date)")
                travel.vehicleId = vehicleId
                completion(travel)
                return
            }
        }
        
        let path = "vehicles/" + vehicleId + "/travels/" + date.toStringWithYearMonthDay()
        var resource = API.resource(path)
        
        //Check for options
        if let options = options {
            let text = options.joined(separator: ",")
            resource = resource.withParam("includes", text)
        }else if let options = defaultRequestTravelOptions{
            let text = options.joined(separator: ",")
            resource = resource.withParam("includes", text)
        }
        
        func handleResource() -> Void{
            let travel : Travel? = resource.typedContent()
            
            if let travel = travel {
                travel.lastUpdate = Date() //Set last update date
                travel.date = date
                travel.vehicleId = vehicleId
                var newTrips = [Trip]()
                for trip in travel.trips {
                    if let date =  trip.start?.trackedAt{
                        trip.date = date
                    }
                    if trip.duration > 60, trip.distance > 1000{
                        newTrips.append(trip)
                    }
                }
                travel.trips = newTrips
                CacheManager.shared.cache(travel: travel, vehicleId: vehicleId) //Cache history
            }
            completion(travel)
        }
        
        let request = resource.loadIfNeeded()
        request?.onSuccess({(entity) in
            handleResource()
        }).onFailure({ (error) in
            failure(error)
            self.handleError(error: error, details: "Error getting trip history today vehicle id \(vehicleId), date \(date), \(error)")
        })
        
        if request == nil {
            handleResource()
        }
    }
    
    ///Request travel using given summary. Summary only give duration and trip count, if cached history is different from the summary, reload and return it
    public func requestTravelUsing(summary: Travel, completion: @escaping (_ history: Travel?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let vehicleId = summary.vehicleId
        guard vehicleId != nil else {
            return
        }
        
        let travel = cachedTravelWithLocationsData(vehicleId: vehicleId!, date: summary.date)
        if let travel = travel{
            //If distance is same, no need to request again
            if summary.duration != 0, summary.distance == travel.distance, summary.tripCount == travel.trips.count {
                summary.trips = travel.trips
                travel.needLoadTripHistory = false
                completion(travel)
                return
            }
            
            if travel.needLoadTripHistory == false{
                //If trip count is different, make need load trip
                if summary.tripCount != travel.trips.count {
                    travel.needLoadTripHistory = true
                    self.log.debug("Need load trip history from summary because summary trip count (\(summary.tripCount)) != history trip count (\(travel.trips.count)), vehicle id \(String(describing: vehicleId))")
                }
                //If duration from summary and history more than 10 seconds, make need load trip
                let totalDuration = travel.duration
                if fabs(summary.duration - totalDuration) > 10 {
                    travel.needLoadTripHistory = true
                    self.log.debug("Need load trip history from summary because summary duration (\(summary.duration)) != history duration (\(totalDuration)), vehicle id \(String(describing: vehicleId))")
                }
                if !travel.needLoadTripHistory {
                    summary.trips = travel.trips
                    completion(travel)
                    return
                }
            }
        }
        
        var forceLoad = false
        if let travel = travel{
            forceLoad = travel.needLoadTripHistory
        }
        
        
        requestTravel(for: summary.date, vehicleId: vehicleId!, forceLoad:forceLoad, completion: {travel in
            summary.needLoadTripHistory = false
            if let trips = travel?.trips{
                summary.trips = trips
            }
            travel?.needLoadTripHistory = false
            travel?.vehicleId = summary.vehicleId
            if let travel = travel, let vehicleId = vehicleId{
                CacheManager.shared.cache(travel: travel, vehicleId: vehicleId) //Cache history
            }
            completion(travel)

            }, failure: { (error) in
                failure(error)
                self.log.error("Error getting trip history vehicle id \(String(describing: vehicleId)), using summary with date \(String(describing: summary.date)), \(String(describing: error))")
        })
    }
    
    ///Request trip summaries between dates.
    public func requestTripSummaries(vehicleId: String, options: [String]! = nil, fromDate: Date, toDate: Date, completion: @escaping (_ summaries:[Trip]?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let datesWithHistory = requiredRangeToRequestTravelSummary(fromDate: fromDate, toDate: toDate, vehicleId: vehicleId)
        var travels = datesWithHistory.cachedHistories
        let newFromDate = datesWithHistory.fromDate.toStringWithYearMonthDay()
        let newToDate = datesWithHistory.toDate.toStringWithYearMonthDay()
        
        var trips = [Trip]()
        var date = fromDate
        

        let path = "vehicles/" + vehicleId + "/travels/summaries/duration"
        var resource = API.resource(path)

        var timezone: NSTimeZone!
        var vehicle = vehicleWith(vehicleId: vehicleId)
        if vehicle == nil {
            vehicle = currentVehicle
        }
        if let vehicle = vehicle, let timezoneText = vehicle.timezone{
            timezone = NSTimeZone(name: timezoneText)
        }
        
        func requestSummaries(){
            //Check for options
            if let options = options {
                let text = options.joined(separator: ",")
                var params = "?start=\(fromDate.toStringWithYearMonthDayAndTime())&end=\(toDate.toStringWithYearMonthDayAndTime())"
                params = params + "&includes=\(text)"
                resource = resource.relative(params)
            }else if let options = defaultRequestTripSummaryOptions{
                let text = options.joined(separator: ",")
                resource = resource.withParam("includes", text)
                var params = "?start=\(fromDate.toStringWithYearMonthDayAndTime(timezone: timezone))&end=\(toDate.toStringWithYearMonthDayAndTime(timezone: timezone))"
                params = params + "&includes=\(text)"
                resource = resource.relative(params)
            }else{
                let params = "?start=\(fromDate.toStringWithYearMonthDayAndTime(timezone: timezone))&end=\(toDate.toStringWithYearMonthDayAndTime(timezone: timezone))"
                resource = API.resource(path).relative(params)
            }
            
            let request = resource.loadIfNeeded()
            
            func handleResource() -> Void {
                if let summaries : [Trip] = resource.typedContent(){
                    var newSummaries = [Trip]()
                    for summary in summaries{
                        if let date = summary.start?.trackedAt{
                            summary.date = date
                        }else if summary.locations.count > 0, let date = summary.locations.first?.trackedAt{
                            summary.date = date
                        }
                        if summary.duration > 60, summary.distance > 1000{
                            newSummaries.append(summary)
                        }
                        CacheManager.shared.cache(trip: summary, vehicleId: vehicleId)
                    }
                    if let travels = CacheManager.shared.latestTravels(vehicleId: vehicleId, count: 2){
                        var cachedTrips = [Trip]()
                        for travel in travels{
                            cachedTrips.append(contentsOf: travel.trips)
                        }
                        
                        if let lastTrip = summaries.last{
                            for trip in cachedTrips{
                                if trip.date.timeIntervalSince(lastTrip.date) > 0{
                                    newSummaries.append(trip)
                                }
                            }
                        }
                    }
                    completion(newSummaries)
                }else{
                    failure(nil)
                }
            }
            
            request?.onSuccess({(entity) in
                handleResource()
            }).onFailure({ (error) in
                failure(error)
                self.handleError(error: error, details: "Error getting trip summaries with original from \(fromDate) to \(toDate) and final from \(datesWithHistory.fromDate) to \(datesWithHistory.toDate),  \(error), path \(resource.url)")
            })
            if request == nil {
                handleResource()
            }
        }
        
        if vehicle == nil{
            requestVehicle(vehicleId: vehicleId, completion: { (vehicle) in
                if let vehicle = vehicle, let timezoneText = vehicle.timezone{
                    timezone = NSTimeZone(name: timezoneText)
                }
                requestSummaries()
            }) { (err) in
                failure(err)
            }
        }else{
            requestSummaries()
        }
    }
    
    ///Get latest cached travel locations from today to previous day count
    public func cacheLatestTrip(trip: Trip, vehicleId : String){
        CacheManager.shared.cache(trip: trip, vehicleId: vehicleId)
    }
    
    ///Get latest cached travel locations from today to previous day count
    public func cachedTrips(vehicleId : String, fromDate: Date, toDate: Date) -> [Trip]! {
        return CacheManager.shared.trips(vehicleId: vehicleId, date: fromDate, toDate: toDate)
    }
    
    ///Get latest cached travel locations from today to previous day count
    public func latestCachedTravels(vehicleId : String, dayCount : Int) -> [Travel]! {
        var date = Date()
        var travellocations = [Travel]()
        for _ in 0..<dayCount {
            if let history = CacheManager.shared.travel(vehicleId: vehicleId, date: date){
                travellocations.append(history)
            }
            date = date.dateBySubtractingDays(1)
        }
        return travellocations
    }
    
    ///Get cached travel data with locations
    public func cachedTravelWithLocationsData(vehicleId : String, date : Date) -> Travel! {
        return CacheManager.shared.travelDetail(vehicleId:vehicleId, date:date)
    }
    
    public func wipeTripSummariesResources(){
        API.wipeResources(matching: "vehicles/*/travels/summaries/duration")
    }

// MARK: Logic
    
    func validateRange(fromDate: Date, toDate : Date) -> (fromDate: Date, toDate : Date) {
        //If both from and to date is in the future, return today
        if (toDate.isLaterThanDate(Date()) && fromDate.isLaterThanDate(Date())) {
            return (Date(), Date())
        }
        
        var theFromDate = fromDate
        if fromDate.isLaterThanDate(Date()) {
            theFromDate = Date()
        }
        var theToDate = toDate
        if toDate.isLaterThanDate(Date())  {
            theToDate = Date()
        }
        return (theFromDate, theToDate)
    }
    
    //!Check required date range from given dates that require to update data from server. Basically give date range by user, cached data is checked if already available, the dates then filtered based on the cached data. However if it is latest dates, need check more condition because the latest data may still not uploaded to the server from the vechle itself.
    func requiredRangeToRequestTravelSummary(fromDate : Date, toDate : Date, vehicleId : String) -> (fromDate : Date, toDate : Date, cachedHistories : [Travel]) {
        var travels = [Travel]()
        var dates : (fromDate : Date, toDate : Date, cachedHistories : [Travel])
        
        var loopDate = fromDate
        

        //Check required from date
        while !loopDate.isEqualToDateIgnoringTime(toDate) {
            let travel = CacheManager.shared.travel(vehicleId: vehicleId, date: loopDate)
            
            //If have cached history, add to array if pass other condition
            if let travel = travel {
                //Check if last 3 day
                if Date().daysAfterDate((travel.date)!) <= KatsanaAPI.maxDaySummary {
                    //Check if current date is 5 minutes than last try update date and trips is 0
//                    if Date().minutesAfterDate(travel.lastUpdate) > 5 || travel.trips.count == 0 {
                        break
//                    }
                }
                travels.append(travel)
            }else{
                break
            }
            loopDate = loopDate.dateByAddingDays(1)
        }
        dates.fromDate = loopDate
        
        //Check required to date
        loopDate = toDate
        while !loopDate.isEqualToDateIgnoringTime(fromDate) || loopDate == toDate {
            let travel = CacheManager.shared.travel(vehicleId: vehicleId, date: loopDate)
            //If have cached history, add to array
            if let travel = travel {
                //Check if last 3 day
                if Date().daysAfterDate((travel.date)!) <= KatsanaAPI.maxDaySummary {
                    //Check if current date is 5 minutes than last try update date and trips is 0
//                    if Date().minutesAfterDate(travel.lastUpdate) > 5 || travel.trips.count == 0 {
                        break
//                    }
                }
                travels.append(travel)
            }else{
                break
            }
            loopDate = loopDate.dateBySubtractingDays(1)
        }
        dates.toDate = loopDate
        dates.cachedHistories = travels
        return dates
    }
}



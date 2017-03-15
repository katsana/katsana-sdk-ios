//
//  KatsanaAPI+Trip.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//


extension KatsanaAPI {
    @nonobjc static let maxDaySummary = 3;
    
    public func requestTravelSummaryToday(vehicleId: String, completion: @escaping (_ summary: Travel?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
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
    public func requestTravelSummaries(vehicleId: String, fromDate: Date!, toDate: Date, completion: @escaping (_ summaries:[Travel]?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let dates = validateRange(fromDate: fromDate, toDate: toDate)
        let datesWithHistory = requiredRangeToRequestTripSummary(fromDate: dates.fromDate, toDate: dates.toDate, vehicleId: vehicleId)
        
        var travels = datesWithHistory.cachedHistories
        
        let path = "vehicles/" + vehicleId + "/summaries/duration"
        
        let resource = API.resource(path).withParam("start", datesWithHistory.fromDate.toStringWithYearMonthDay()).withParam("end",datesWithHistory.toDate.toStringWithYearMonthDay());
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
            self.log.error("Error getting trip summaries with original from \(fromDate) to \(toDate) and final from \(datesWithHistory.fromDate) to \(datesWithHistory.toDate),  \(error)")
        })
        if request == nil {
            handleResource()
        }
        
        
    }
    
    ///Request travel details for given date
    public func requestTravel(for date: Date, vehicleId: String, options: [String]! = nil, completion: @escaping (_ history: Travel?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let travel = CacheManager.shared.travel(vehicleId: vehicleId, date: date)
        if let travel = travel, travel.needLoadTripHistory == false{
            self.log.debug("Get trip history from cached data vehicle id \(vehicleId), date \(date)")
            travel.vehicleId = vehicleId
            completion(travel)
            return
        }
        
        let path = "vehicles/" + vehicleId + "/travels/" + date.toStringWithYearMonthDay()
        var resource = API.resource(path)
        
        //Check for options
        if let options = options {
            let text = options.joined(separator: ", ")
            resource = resource.withParam("includes", text)
        }else if let options = defaultRequestTravelOptions{
            let text = options.joined(separator: ", ")
            resource = resource.withParam("includes", text)
        }
        
        func handleResource() -> Void{
            let travel : Travel? = resource.typedContent()
            travel?.lastUpdate = Date() //Set last update date
            travel?.date = date
            travel?.vehicleId = vehicleId
            if let travel = travel {
                CacheManager.shared.cache(travel: travel, vehicleId: vehicleId) //Cache history
            }
            completion(travel)
        }
        
        let request = resource.loadIfNeeded()
        request?.onSuccess({(entity) in
            handleResource()
        }).onFailure({ (error) in
            failure(error)
            self.log.error("Error getting trip history today vehicle id \(vehicleId), date \(date), \(error)")
        })
        
        if request == nil {
            handleResource()
        }
    }
    
    ///Request travel using given summary. Summary only give duration and trip count, if cached history is different from the summary, reload and return it
    public func requestTravelUsing(summary: Travel, completion: @escaping (_ history: Travel?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let vehicleId = summary.vehicleId
        guard vehicleId != nil else {
            return
        }
        
        let travel = CacheManager.shared.travel(vehicleId: vehicleId!, date: summary.date)
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
                    self.log.debug("Need load trip history from summary because summary trip count (\(summary.tripCount)) != history trip count (\(travel.trips.count)), vehicle id \(vehicleId)")
                }
                //If duration from summary and history more than 10 seconds, make need load trip
                let totalDuration = travel.duration
                if fabs(summary.duration - totalDuration) > 10 {
                    travel.needLoadTripHistory = true
                    self.log.debug("Need load trip history from summary because summary duration (\(summary.duration)) != history duration (\(totalDuration)), vehicle id \(vehicleId)")
                }
                if !travel.needLoadTripHistory {
                    summary.trips = travel.trips
                    completion(travel)
                    return
                }
            }
        }
        
        requestTravel(for: summary.date, vehicleId: vehicleId!, completion: {travel in
            summary.needLoadTripHistory = false
            if let trips = travel?.trips{
                summary.trips = trips
            }
            travel?.needLoadTripHistory = false
            travel?.vehicleId = summary.vehicleId
            CacheManager.shared.cache(travel: travel!, vehicleId: vehicleId!) //Cache history
            completion(travel)

            }, failure: { (error) in
                failure(error)
                self.log.error("Error getting trip history vehicle id \(vehicleId), using summary with date \(summary.date), \(error)")
        })
    }
    
    ///Request trip summaries between dates.
    public func requestTripSummaries(vehicleId: String, fromDate: Date, toDate: Date, completion: @escaping (_ summaries:[Trip]?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        var trips = [Trip]()
        var date = fromDate
        
        func requestTravel(){
            self.requestTravel(for: date, vehicleId: vehicleId, completion: { (travel) in
                travel?.trips.map({$0.date = date})
                trips.append(contentsOf: (travel?.trips)!)
                
                if date.isEqualToDateIgnoringTime(toDate){
                    completion(trips.reversed())
                }else{
                    date = date.dateByAddingDays(1)
                    requestTravel()
                }
            }) { (error) in
                failure(error)
                self.log.error("Error getting trip history vehicle id \(vehicleId), using summary with date \(date), \(error)")
            }
        }
        requestTravel()
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
    func requiredRangeToRequestTripSummary(fromDate : Date, toDate : Date, vehicleId : String) -> (fromDate : Date, toDate : Date, cachedHistories : [Travel]) {
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
        while !loopDate.isEqualToDateIgnoringTime(fromDate) {
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



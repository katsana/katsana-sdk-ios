//
//  KatsanaAPI+Trip.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//


extension KatsanaAPI {
    @nonobjc static let maxDaySummary = 3;
    
    public func requestTripSummaryToday(vehicleId: String, completion: @escaping (_ summary: Travel?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
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
    
    ///Request trip summary between dates. Only load trip count without actual trip details to minimize data usage,
    
    public func requestTripSummaries(vehicleId: String, fromDate: Date!, toDate: Date, completion: @escaping (_ summaries:[Travel]?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
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
    
    ///Request trip history will download histories for that particular date
    public func requestTripHistory(for date: Date, vehicleId: String, completion: @escaping (_ history: Travel?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        
        let history = CacheManager.shared.travel(vehicleId: vehicleId, date: date)
        if history != nil && history?.needLoadTripHistory == false{
            self.log.debug("Get trip history from cached data vehicle id \(vehicleId), date \(date)")
            history?.vehicleId = vehicleId
            completion(history)
            return
        }
        
        let path = "vehicles/" + vehicleId + "/travels/" + date.toStringWithYearMonthDay()
        let resource = API.resource(path);
        
        func handleResource() -> Void{
            let history : Travel? = resource.typedContent()
            history?.lastUpdate = Date() //Set last update date
            history?.date = date
            history?.vehicleId = vehicleId
            if let history = history {
                CacheManager.shared.cache(travel: history, vehicleId: vehicleId) //Cache history
            }
            completion(history)
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
    
    ///Request trip history using given summary. Summary only give duration and trip count, if cached history is different from the summary, reload and return it
    public func requestTripHistoryUsing(summary: Travel, completion: @escaping (_ history: Travel?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let vehicleId = summary.vehicleId
        guard vehicleId != nil else {
            return
        }
        
        let history = CacheManager.shared.travel(vehicleId: vehicleId!, date: summary.date)
        if history != nil && history?.needLoadTripHistory == false{
            //If trip count is different, make need load trip
            if summary.tripCount != history?.trips.count {
                history?.needLoadTripHistory = true
                self.log.debug("Need load trip history from summary because summary trip count (\(summary.tripCount)) != history trip count (\(history?.trips.count)), vehicle id \(vehicleId)")
            }
            let theHistory = history!
            //If duration from summary and history more than 10 seconds, make need load trip
            let totalDuration = theHistory.duration
            if fabs(summary.duration - totalDuration) > 10 {
                history?.needLoadTripHistory = true
                self.log.debug("Need load trip history from summary because summary duration (\(summary.duration)) != history duration (\(totalDuration)), vehicle id \(vehicleId)")
            }
        }
        requestTripHistory(for: summary.date, vehicleId: vehicleId!, completion: {history in
            summary.needLoadTripHistory = false
            if let trips = history?.trips{
                summary.trips = trips
            }
            history?.needLoadTripHistory = false
            history?.vehicleId = summary.vehicleId
            completion(history)
            }, failure: { (error) in
                failure(error)
                self.log.error("Error getting trip history vehicle id \(vehicleId), using summary with date \(summary.date), \(error)")
        })
    }
    
    ///Get latest cached travel histories from today to previous day count
    public func latestCachedTravels(vehicleId : String, dayCount : Int) -> [Travel]! {
        var date = Date()
        var travelhistories = [Travel]()
        for _ in 0..<dayCount {
            if let history = CacheManager.shared.travel(vehicleId: vehicleId, date: date){
                travelhistories.append(history)
            }
            date = date.dateBySubtractingDays(1)
        }
        return travelhistories
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
        var histories = [Travel]()
        var dates : (fromDate : Date, toDate : Date, cachedHistories : [Travel])
        
        var loopDate = fromDate
        

        //Check required from date
        while !loopDate.isEqualToDateIgnoringTime(toDate) {
            let history = CacheManager.shared.travel(vehicleId: vehicleId, date: loopDate)
            
            //If have cached history, add to array if pass other condition
            if history != nil {
                //Check if last 3 day
                if Date().daysAfterDate((history?.date)!) <= KatsanaAPI.maxDaySummary {
                    //Check if current date is 5 minutes than last try update date and trips is 0
                    if Date().minutesAfterDate((history?.lastUpdate)!) > 5 && history?.trips.count == 0 {
                        break
                    }
                }
                histories.append(history!)
            }else{
                break
            }
            loopDate = loopDate.dateByAddingDays(1)
        }
        dates.fromDate = loopDate
        
        //Check required to date
        loopDate = toDate
        while !loopDate.isEqualToDateIgnoringTime(fromDate) {
            let history = CacheManager.shared.travel(vehicleId: vehicleId, date: loopDate)
            //If have cached history, add to array
            if history != nil {
                histories.append(history!)
            }else{
                break
            }
            loopDate = loopDate.dateBySubtractingDays(1)
        }
        dates.toDate = loopDate
        dates.cachedHistories = histories
        return dates
    }
}



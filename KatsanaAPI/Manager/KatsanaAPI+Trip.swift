//
//  KatsanaAPI+Trip.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit

extension KatsanaAPI {
    @nonobjc static let maxDaySummary = 3;
    
    public func requestTripSummaryToday(vehicleId: String, completion: @escaping (_ summary: KMTravelHistory?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let path = "vehicles/" + vehicleId + "/summaries/today"
        let resource = API.resource(path);
        resource.loadIfNeeded()?.onSuccess({(entity) in
            let summary : KMTravelHistory? = resource.typedContent()
            completion(summary)
            }).onFailure({ (error) in
                failure(error)
            })
    }
    
    //!Request trip summary between dates. Only load trip count without actual trip details to minimize data usage,
    public func requestTripSummary(vehicleId: String, fromDate: Date!, toDate: Date, completion: @escaping (_ summaries:[KMTravelHistory]?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let dates = validateRange(fromDate: fromDate, toDate: toDate)
        let datesWithHistory = requiredRangeToRequestTripSummary(fromDate: dates.fromDate, toDate: dates.toDate, vehicleId: vehicleId)
        
        var histories = datesWithHistory.cachedHistories
        
        let path = "vehicles/" + vehicleId + "/summaries/today"
        let resource = API.resource(path);
        resource.loadIfNeeded()?.onSuccess({(entity) in
            let summaries : [KMTravelHistory] = resource.typedContent()!
            for summary in summaries{
                //Remove duplicate history
                var duplicateHistoryNeedRemove : KMTravelHistory!
                for history in histories{
                    if summary.historyDate.isEqualToDateIgnoringTime(history.historyDate){
                        summary.trips = history.trips
                        duplicateHistoryNeedRemove = history
                        summary.needLoadTripHistory = false
                    }
                }
                if duplicateHistoryNeedRemove != nil{
                    histories.remove(at: histories.index(of: duplicateHistoryNeedRemove)!)
                }
                
                
                summary.needLoadTripHistory = true //Always need load trip summary if loaded from summary API
                summary.lastUpdate = Date()
                
                //Cache history for days more than maxDaySummary, because it may already contain trip but still not finalized on the server
                if Date().daysAfterDate((summary.historyDate)!) > KatsanaAPI.maxDaySummary{
                    KMCacheManager.sharedInstance().cacheData(summary, identifier: vehicleId)
                }
            }
            histories.append(contentsOf: summaries)
            histories.sort(by: { $0.historyDate > $1.historyDate })
            
            

            completion(summaries)
        }).onFailure({ (error) in
            failure(error)
        })
    }
    
    //!Request trip history will download histories for that particular date
    public func requestTripHistory(for date: Date, vehicleId: String, completion: @escaping (_ history: KMTravelHistory?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let path = "vehicles/" + vehicleId + "/travels/" + date.toStringWithYearMonthDay()
        let resource = API.resource(path);
        resource.loadIfNeeded()?.onSuccess({(entity) in
            let history : KMTravelHistory? = resource.typedContent()
            history?.lastUpdate = Date() //Set last update date
            history?.historyDate = date
            KMCacheManager.sharedInstance().cacheData(history, identifier: vehicleId) //Cache history
            completion(history)
        }).onFailure({ (error) in
            failure(error)
        })
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
    func requiredRangeToRequestTripSummary(fromDate : Date, toDate : Date, vehicleId : String) -> (fromDate : Date, toDate : Date, cachedHistories : [KMTravelHistory]) {
        var histories = [KMTravelHistory]()
        var dates : (fromDate : Date, toDate : Date, cachedHistories : [KMTravelHistory])
        
        var loopDate = fromDate
        

        //Check required from date
        while !loopDate.isEqualToDateIgnoringTime(toDate) {
            let history = KMCacheManager.sharedInstance().travelHistory(for: loopDate, vehicleId: vehicleId)
            
            //If have cached history, add to array if pass other condition
            if history != nil {
                //Check if last 3 day
                if Date().daysAfterDate((history?.historyDate)!) <= KatsanaAPI.maxDaySummary {
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
            let history = KMCacheManager.sharedInstance().travelHistory(for: loopDate, vehicleId: vehicleId)
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



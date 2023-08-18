//
//  KatsanaAPI+Stream.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2022.
//

import Foundation
import Siesta

extension KatsanaAPI_Old{
    ///Request live stream devices for supported vehicles
    public func requestLiveStreamDevices(completion: @escaping (_ summaries:[VehicleLiveStream]?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "operations/stream"
        
        let resource = API.resource(path)
        let request = resource.loadIfNeeded()
        
        func handleResource() -> Void {
            if let summaries : [VehicleLiveStream] = resource.typedContent(){
                if let vehicles = self.vehicles{
                    _ = vehicles.map({$0.requestVideoRecordingDate = Date()})
                }
                
                for summary in summaries {
                    if let vehicle = self.vehicleWith(vehicleId: summary.vehicleId){
                        vehicle.videoRecording = summary
                    }
                }
                completion(summaries)
            }else{
                failure(nil)
            }
        }
        
        request?.onSuccess({(entity) in
            handleResource()
        }).onFailure({ (error) in
            failure(error)
        })
        if request == nil {
            handleResource()
        }
    }
    
    public func requestLiveStream(vehicle:KTVehicle, channel: String! = nil, completion: @escaping (_ videoRecording:VehicleLiveStream?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "operations/stream/show"
        
        var resource = API.resource(path).withParam("vehicleID", "\(vehicle.vehicleId)")
        if let channel{
            resource = resource.withParam("channel", channel)
        }
        
        let request = resource.loadIfNeeded()
        
        func handleResource() -> Void {
            if let videoRecording : VehicleLiveStream = resource.typedContent(){
                vehicle.requestVideoRecordingDate = Date()
                vehicle.videoRecording = videoRecording
                if let idx = self.vehicles.firstIndex(of: vehicle){
                    self.vehicles[idx] = vehicle
                }
                if let currentVehicle = self.currentVehicle, currentVehicle.vehicleId == vehicle.vehicleId{
                    self.currentVehicle = vehicle
                }
                completion(videoRecording)
            }else{
                failure(nil)
            }
        }
        
        request?.onSuccess({(entity) in
            handleResource()
        }).onFailure({ (error) in
            failure(error)
        })
        if request == nil {
            handleResource()
        }
    }
    
    public func requestVideoPlaybacks(vehicleId: String, completion: @escaping (_ playbacks:[VideoPlayback]?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
       
        requestVideoPlaybacks { playbacks in
            if let playbacks{
                var channels = [VideoRecordingChannel]()
                func getOrCreateChannel(_ id: String) -> VideoRecordingChannel{
                    for channel in channels {
                        if channel.identifier == id{
                            return channel
                        }
                    }
                    let newChannel = VideoRecordingChannel()
                    newChannel.identifier = id
                    channels.append(newChannel)
                    return newChannel
                }
                var thePlaybacks = [VideoPlayback]()
                for playback in playbacks{
                    if vehicleId == playback.deviceId, let id = playback.channelIdentifier{
                        let channel = getOrCreateChannel(id)
                        channel.addPlayback(playback)
                        thePlaybacks.append(playback)
                    }
                }
                completion(thePlaybacks)
            }else{
                completion(nil)
            }
            
            
        } failure: { error in
            failure(error)
        }

    }
    
    public func requestVideoPlaybacks(completion: @escaping (_ playbacks:[VideoPlayback]?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "operations/playback"
        
//        let resource = API.resource(path)
        var resource = API.resource(path)
        
        let request = resource.loadIfNeeded()
        
        func handleResource() -> Void {
            if let playbacks : [VideoPlayback] = resource.typedContent(){
                completion(playbacks)
            }else{
                failure(nil)
            }
        }
        
        request?.onSuccess({(entity) in
            handleResource()
        }).onFailure({ (error) in
            failure(error)
        })
        if request == nil {
            handleResource()
        }
    }
    
    public func requestVideoPlaybackData(playbackId: String, completion: @escaping (_ data:Data) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "operations/playback/\(playbackId)/download"
//        API.configure("**") {
//            $0.headers["Accept"] = "application/json"
//            $0.headers["Authorization"] = self.authorizationHeader + "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2NhcmJvbi5hcGkua2F0c2FuYS5jb20vYXV0aCIsImlhdCI6MTY2ODA2OTc4MCwiZXhwIjoxNjcwNjYxNzgwLCJuYmYiOjE2NjgwNjk3ODAsImp0aSI6IlhGNk40cnVQcGFJOEI4VmwiLCJzdWIiOjIyMCwicHJ2IjoiZjZiNzE1NDlkYjhjMmM0MmI3NTgyN2FhNDRmMDJiN2VlNTI5ZDI0ZCIsInZlaGljbGVzIjpbXX0.Wjpe_Ggdi5mO7MGy_vQOoqnh_OM_5d_1Fdn4szViNh4"
//        }
//        let resource = API.resource(path)
        var resource = API.resource(path)
        
        let request = resource.loadIfNeeded()
        
//        func handleResource() -> Void {
//            if let playbacks : [VideoPlayback] = resource.typedContent(){
//                completion(playbacks)
//            }else{
//                failure(nil)
//            }
//        }
        
        request?.onSuccess({(entity) in
            if let json = entity.content as? Data{
                completion(json)
                print("Sfsa")
            }
        }).onFailure({ (error) in
            failure(error)
        })
        if request == nil {
//            handleResource()
        }
    }
}

//
//  VideoPlayback.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 15/11/2022.
//  Copyright © 2022 pixelated. All rights reserved.
//
import Foundation

public class VideoPlayback: Codable, Equatable {
    public let id: Int
    public let channelId: Int
    public let userId: Int
    public let deviceId: Int
    public let vacronDeviceId: String?
    public let filename: String
    public let startTime: Date
    public let endTime: Date
    public let duration: Float
    
    init(id: Int, channelId: Int, userId: Int, deviceId: Int, vacronDeviceId: String?, filename: String, startTime: Date, endTime: Date, duration: Float) {
        self.id = id
        self.channelId = channelId
        self.userId = userId
        self.deviceId = deviceId
        self.vacronDeviceId = vacronDeviceId
        self.filename = filename
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
    }
    
    public static func == (lhs: VideoPlayback, rhs: VideoPlayback) -> Bool {
        if lhs.id == rhs.id, lhs.channelId == rhs.channelId, lhs.deviceId == rhs.deviceId, lhs.filename == rhs.filename, lhs.startTime == rhs.startTime, lhs.endTime == rhs.endTime{
            return true
        }
        return false
    }
}

//open class DayVideoPlayback: Codable {
//    open var date: Date?
//    open var playbacks = [VideoPlayback]()
//    open var totalDuration: CGFloat = 0
//    
//    open var dayText: String?{
//        get{
//            if let date{
//                return String(date.day())
//            }
//            return nil
//        }
//    }
//    open var monthText: String?{
//        get{
//            if let date{
//                return date.shortMonthToString()
//            }
//            return nil
//        }
//    }
//    
//    open var playbackCountText: String!{
//        get{
//            return "\(playbacks.count) files"
//        }
//    }
//    open var durationText: String?{
//        get{
//            var totalDuration: CGFloat = 0
//            for playback in playbacks {
//                totalDuration += playback.duration
//            }
//            return KatsanaFormatter.durationStringFrom(seconds: totalDuration)
//        }
//    }
//    
//    func addPlayback(_ playback: VideoPlayback){
//        playbacks.append(playback)
//    }
//}
//
//public extension Array where Element: VideoPlayback {
//    func getDayVideoPlaybacks(channelId: String) -> [DayVideoPlayback]!{
//        var days = [DayVideoPlayback]()
//        func getOrCreateDayPlayback(_ date: Date) -> DayVideoPlayback{
//            for channel in days {
//                if let channelDate = channel.date, channelDate.isEqualToDateIgnoringTime(date){
//                    return channel
//                }
//            }
//            let newChannel = DayVideoPlayback()
//            newChannel.date = date
//            days.append(newChannel)
//            return newChannel
//        }
//        
//        for playback in self{
//            if playback.channelIdentifier == channelId, let startTime = playback.startTime{
//                let day = getOrCreateDayPlayback(startTime)
//                day.addPlayback(playback)
//            }
//        }
//        days.sort { a,b in
//            guard let aDate = a.date, let bDate = b.date else{
//                return false
//            }
//            return aDate < bDate
//        }
//        
//        return days
//    }
//}

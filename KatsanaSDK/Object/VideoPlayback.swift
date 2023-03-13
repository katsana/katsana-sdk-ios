//
//  VideoPlayback.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 15/11/2022.
//  Copyright © 2022 pixelated. All rights reserved.
//
import Foundation

open class VideoPlayback: Codable {
    open var id: String?
    open var channelIdentifier: String?
    open var userId: String?
    open var deviceId: String?
    open var vacronDeviceId: String?
    open var filename: String?
    open var startTime: Date?
    open var endTime: Date?
    open var duration: CGFloat = 0
    
    open var url: String?
    open var previewURL: String?
//    open var channelId
    
    open var startTimeText: String?{
        get{
            if let startTime{
                return startTime.toStringWithTime(includeSeconds: false)
            }
            return nil
        }
    }
}

open class DayVideoPlayback: Codable {
    open var date: Date?
    open var playbacks = [VideoPlayback]()
    open var totalDuration: CGFloat = 0
    
    open var dayText: String?{
        get{
            if let date{
                return String(date.day())
            }
            return nil
        }
    }
    open var monthText: String?{
        get{
            if let date{
                return date.shortMonthToString()
            }
            return nil
        }
    }
    
    open var playbackCountText: String!{
        get{
            return "\(playbacks.count) files"
        }
    }
    open var durationText: String?{
        get{
            var totalDuration: CGFloat = 0
            for playback in playbacks {
                totalDuration += playback.duration
            }
            return KatsanaFormatter.durationStringFrom(seconds: totalDuration)
        }
    }
    
    func addPlayback(_ playback: VideoPlayback){
        playbacks.append(playback)
    }
}

public extension Array where Element: VideoPlayback {
    func getDayVideoPlaybacks(channelId: String) -> [DayVideoPlayback]!{
        var days = [DayVideoPlayback]()
        func getOrCreateDayPlayback(_ date: Date) -> DayVideoPlayback{
            for channel in days {
                if let channelDate = channel.date, channelDate.isEqualToDateIgnoringTime(date){
                    return channel
                }
            }
            let newChannel = DayVideoPlayback()
            newChannel.date = date
            days.append(newChannel)
            return newChannel
        }
        
        for playback in self{
            if playback.channelIdentifier == channelId, let startTime = playback.startTime{
                let day = getOrCreateDayPlayback(startTime)
                day.addPlayback(playback)
            }
        }
        days.sort { a,b in
            guard let aDate = a.date, let bDate = b.date else{
                return false
            }
            return aDate < bDate
        }
        
        return days
    }
}

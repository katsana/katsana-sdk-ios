//
//  VideoRecordingChannel.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2022.
//  Copyright © 2022 pixelated. All rights reserved.
//
import Foundation

open class VideoRecordingChannel: Codable {
    enum CodingKeys: CodingKey {
        case identifier
        case name
        case isOn
        case playbacks
    }
    
    open var identifier: String?
    open var name: String?
    open var isOn: Bool = false
    open var playbacks = [VideoPlayback]()
    
    open func getDayPlaybacks() -> [DayVideoPlayback]!{
        
        let day = DayVideoPlayback()
        for i in 0..<10{
            let test = VideoPlayback()
            test.startTime = Date()
            day.playbacks.append(test)
        }
        return [day]
        
        if playbacks.count > 0{
            let day = DayVideoPlayback()
            for playback in playbacks {
                day.date = playback.startTime
                day.playbacks.append(playback)
            }
            return [day]
        }
        return nil
    }
    
    func addPlayback(_ playback: VideoPlayback){
        playbacks.append(playback)
    }
}




//
//  Trip.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import UIKit

public class Trip: NSObject {
    var start: VehicleLocation!
    var end: VehicleLocation!
    var distance: Double = 0
    var duration: Double = 0
    var maxSpeed: Float = 0
    var averageSpeed: Float = 0
    var idleDuration: Float = 0
    var score: Float = -1
    
    var locations = [VehicleLocation]()
    var violations = [VehicleActivity]()
    
    ///Next trip and prev trip automatically set when trips are set in Travel class
    weak var nextTrip: Trip!
    weak var prevTrip: Trip!
    
    //Extra data that user can set to trip
    var extraData: NSDictionary!
    
    class func fastCodingKeys() -> [Any?] {
        return ["start", "end", "distance", "duration", "maxSpeed", "averageSpeed", "idleDuration", "locations", "violations", "idles", "score", "extraData"]
    }
}

    
//    - (CGFloat)tripStopDuration{
//        if (self.nextTrip) {
//            CGFloat duration = [self.nextTrip.start.trackedAt timeIntervalSinceDate:self.end.trackedAt];
//            return duration;
//        }
//        return 0;
//        }
//        
//        - (NSString*)tripStopDurationString{
//            CGFloat duration = [self tripStopDuration];
//            return [KatsanaFormatter durationStringUsingFormatWithFormat:DisplayFormatFull duration:duration];
//            }
//            
//            //- (CGFloat)averageSpeed{
//            //    __block CGFloat totalSpeed = 0;
//            //    __block KMVehicleLocation *prevPos = self.start;
//            //    __block NSInteger count = 0;
//            //    [self.histories enumerateObjectsUsingBlock:^(KMVehicleLocation *pos, NSUInteger idx, BOOL * _Nonnull stop) {
//            //        CGFloat speed = 0;
//            //
//            //        CGFloat distance = [pos distanceToPosition:prevPos]/1000.0f;
//            //        CGFloat time = [pos.trackedAt timeIntervalSinceDate:prevPos.trackedAt];
//            //        time = time/(60*60);
//            //        speed = distance/time;
//            //        if (time > 0) {
//            //            totalSpeed += speed;
//            //            count++;
//            //        }
//            //        prevPos = pos;
//            //    }];
//            //
//            //    CGFloat avgSpeed = totalSpeed/count;
//            //    return avgSpeed;
//            //}
//            
//            - (CGFloat)medianSpeed{
//                NSMutableArray *speeds = [NSMutableArray arrayWithCapacity:self.histories.count];
//                __block KMVehicleLocation *prevPos = self.start;
//                [self.histories enumerateObjectsUsingBlock:^(KMVehicleLocation *pos, NSUInteger idx, BOOL * _Nonnull stop) {
//                    CGFloat speed = 0;
//                    
//                    CGFloat distance = [pos distanceToPosition:prevPos]/1000.0f;
//                    CGFloat time = [pos.trackedAt timeIntervalSinceDate:prevPos.trackedAt];
//                    time = time/(60*60);
//                    speed = distance/time;
//                    if (time > 0) {
//                    [speeds addObject:@(speed)];
//                    }
//                    prevPos = pos;
//                    }];
//                
//                NSArray *sorted = [speeds sortedArrayUsingSelector:@selector(compare:)];    // Sort the array by value
//                NSUInteger middle = [sorted count] / 2;                                           // Find the index of the middle element
//                NSNumber *median = [sorted objectAtIndex:middle];
//                return median.floatValue;
//                }
//                
//                
//                - (NSString*)maxSpeedString{
//                    return [KatsanaFormatter speedStringFromKnot:self.maxSpeed];
//                    }
//                    
//                    - (NSString*)averageSpeedString{
//                        CGFloat speed = self.averageSpeed;
//                        if (speed < 0) {
//                            speed = 0;
//                        }
//                        return [KatsanaFormatter speedStringFromKnot:speed];
//}

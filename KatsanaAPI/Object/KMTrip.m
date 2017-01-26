//
//  KMTrip.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 02/02/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import "KMTrip.h"

@implementation KMTrip

+ (NSArray*)fastCodingKeys{
    return @[@"start", @"end", @"distance", @"duration", @"maxSpeed", @"averageSpeed", @"idleDuration", @"histories", @"violations", @"idles", @"score", @"extraData"];
}

- (CGFloat)tripStopDuration{
    if (self.nextTrip) {
        CGFloat duration = [self.nextTrip.start.trackedAt timeIntervalSinceDate:self.end.trackedAt];
        return duration;
    }
    return 0;
}

- (NSString*)tripStopDurationString{
    CGFloat duration = [self tripStopDuration];
    return [KatsanaFormatter durationStringUsingFormatWithFormat:DisplayFormatFull duration:duration];
}

//- (CGFloat)averageSpeed{
//    __block CGFloat totalSpeed = 0;
//    __block KMVehicleLocation *prevPos = self.start;
//    __block NSInteger count = 0;
//    [self.histories enumerateObjectsUsingBlock:^(KMVehicleLocation *pos, NSUInteger idx, BOOL * _Nonnull stop) {
//        CGFloat speed = 0;
//        
//        CGFloat distance = [pos distanceToPosition:prevPos]/1000.0f;
//        CGFloat time = [pos.trackedAt timeIntervalSinceDate:prevPos.trackedAt];
//        time = time/(60*60);
//        speed = distance/time;
//        if (time > 0) {
//            totalSpeed += speed;
//            count++;
//        }
//        prevPos = pos;
//    }];
//    
//    CGFloat avgSpeed = totalSpeed/count;
//    return avgSpeed;
//}

- (CGFloat)medianSpeed{
    NSMutableArray *speeds = [NSMutableArray arrayWithCapacity:self.histories.count];
    __block KMVehicleLocation *prevPos = self.start;
    [self.histories enumerateObjectsUsingBlock:^(KMVehicleLocation *pos, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat speed = 0;
        
        CGFloat distance = [pos distanceToPosition:prevPos]/1000.0f;
        CGFloat time = [pos.trackedAt timeIntervalSinceDate:prevPos.trackedAt];
        time = time/(60*60);
        speed = distance/time;
        if (time > 0) {
            [speeds addObject:@(speed)];
        }
        prevPos = pos;
    }];
    
    NSArray *sorted = [speeds sortedArrayUsingSelector:@selector(compare:)];    // Sort the array by value
    NSUInteger middle = [sorted count] / 2;                                           // Find the index of the middle element
    NSNumber *median = [sorted objectAtIndex:middle];
    return median.floatValue;
}


- (NSString*)maxSpeedString{
    return [KatsanaFormatter speedStringFromKnot:self.maxSpeed];
}

- (NSString*)averageSpeedString{
    CGFloat speed = self.averageSpeed;
    if (speed < 0) {
        speed = 0;
    }
    return [KatsanaFormatter speedStringFromKnot:speed];
}


@end

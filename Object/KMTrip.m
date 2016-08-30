//
//  KMTrip.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 02/02/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import "KMTrip.h"
#import "KMViolation.h"

@implementation KMTrip

- (CGFloat)tripStopDuration{
    if (self.nextTrip) {
        CGFloat duration = [self.nextTrip.start.trackedAt timeIntervalSinceDate:self.end.trackedAt];
        return duration;
    }
    return 0;
}

- (NSString*)tripStopDurationString{
    CGFloat duration = [self tripStopDuration];
    
    CGFloat minute = duration/60.0f;
    
    NSString *durationStr;
    if (minute >= 60) {
        CGFloat hour = floor(minute/60.0f);
        minute = (minute/60.0f - floor(minute/60.0f)) * 60;
        durationStr = [NSString stringWithFormat:@"%.0f hours %.0f minutes", hour, minute];
    }else{
        if (isnan(minute)) {
            durationStr = @"";
        }else{
            durationStr = [NSString stringWithFormat:@"%.0f minutes", minute];
        }
    }
    return durationStr;
}

//- (CGFloat)averageSpeed{
//    __block CGFloat totalSpeed = 0;
//    __block KMVehiclePosition *prevPos = self.start;
//    __block NSInteger count = 0;
//    [self.histories enumerateObjectsUsingBlock:^(KMVehiclePosition *pos, NSUInteger idx, BOOL * _Nonnull stop) {
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
    __block KMVehiclePosition *prevPos = self.start;
    [self.histories enumerateObjectsUsingBlock:^(KMVehiclePosition *pos, NSUInteger idx, BOOL * _Nonnull stop) {
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

//- (CGFloat)maxSpeed{
//    __block CGFloat maxSpeed = 0;
//    __block KMVehiclePosition *prevPos = self.start;
//    [self.histories enumerateObjectsUsingBlock:^(KMVehiclePosition *pos, NSUInteger idx, BOOL * _Nonnull stop) {
//        CGFloat speed = 0;
//        
//        CGFloat distance = [pos distanceToPosition:prevPos];
//        distance /= 1000.0f;
//        CGFloat time = [pos.trackedAt timeIntervalSinceDate:prevPos.trackedAt];
//        time = time/(60*60);
//        speed = distance/time;
//        if (speed > maxSpeed && time > 0) {
//            maxSpeed = speed;
//        }
//        prevPos = pos;
//    }];
//    return maxSpeed;
//}


- (NSString*)maxSpeedString{
    NSString *str = [NSString stringWithFormat:@"%.0f km/h", self.maxSpeed * KNOT_TO_KMH];
    return str;
}

- (NSString*)averageSpeedString{
    NSString *str = [NSString stringWithFormat:@"%.0f km/h", self.averageSpeed * KNOT_TO_KMH];
    return str;
}


@end

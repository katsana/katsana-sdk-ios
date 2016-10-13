//
//  KMVehicleHistory.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/30/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import "KMTravelHistory.h"
#import "KMVehiclePosition.h"
#import "KMVehicle.h"
#import "KMTrip.h"
//#import "NSDate+Compare.h"
#import "KMTimeTransformer.h"
#import "KMVehicle.h"

@implementation KMTravelHistory{
    NSArray *_routeTrips;
}

- (NSDate*)localTimezoneHistoryDate{
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:self.historyDate];
    NSDate *date = [self.historyDate dateByAddingTimeInterval:-timeZoneOffset];
    return date;
}

- (NSInteger)tripCount{
    if (self.trips.count > 0) {
        return self.trips.count;
    }
    return _tripCount;
}

- (CGFloat)totalDuration{
    __block CGFloat duration = 0;
    if (self.trips.count == 0 || _duration > 0) {
        return _duration;
    }else{
        //If vehicle is still moving and trip duration is 0, can use current time - startTime to calculate duration
        //However if the car is currently stop, must not calculate using this method because the car maybe has been stopping for a long time, so the duration might not accurate, so will
        //need to use duration from server
//        if (self.owner && self.owner.current.speed > 0) {
//            [self.trips enumerateObjectsUsingBlock:^(KMTrip *trip, NSUInteger idx, BOOL * _Nonnull stop) {
//                if (trip.duration == 0 && idx == self.trips.count-1) {
//                    KMTrip *trip = self.trips.firstObject;
//                    duration += [[NSDate date] timeIntervalSinceDate:trip.start.trackedAt];
//                }
//                
//                duration += trip.duration;
//            }];
//        }else{
            [self.trips enumerateObjectsUsingBlock:^(KMTrip *trip, NSUInteger idx, BOOL * _Nonnull stop) {
                duration += trip.duration;
            }];
//        }
    }
    return duration;
}

- (CGFloat)averageSpeed{
    CGFloat totalSpeed = 0;
    for (KMTrip *trip in self.trips) {
        totalSpeed += trip.averageSpeed;
    }
    CGFloat averageSpeed = totalSpeed/(CGFloat)self.trips.count;
    return averageSpeed;
}

- (NSString*)averageSpeedString{
    NSString *str = [NSString stringWithFormat:@"%.0f km/h", self.averageSpeed * KNOT_TO_KMH];
    return str;
}

- (NSString*)idleDurationString{
    CGFloat duration = 0;
    for (KMTrip *trip in self.trips) {
        duration += trip.idleDuration;
    }
    if (duration == 0) {
        duration = self.idleDuration;
    }
    
    NSString *str = [[[KMTimeTransformer alloc] init] transformedValue:@(duration)];
    return str;
}

- (NSString*)todayMaxSpeedString{
    CGFloat maxSpeed = self.maxSpeed;
    maxSpeed *= KNOT_TO_KMH;
    return [NSString stringWithFormat:@"%.0f km/h", maxSpeed];
}

- (NSString*)totalDistanceString{
    CGFloat distance = self.distance;
    if (distance < 1000) {
        return [NSString stringWithFormat:@"%.0f m", distance];
    }else{
        return [NSString stringWithFormat:@"%.0f km", distance/1000.0f];
    }
}

- (NSString*)totalDurationString{
    return [self totalDurationAttributedString].string;
}

- (NSAttributedString*)totalDurationAttributedString{
    NSMutableAttributedString *fullStr = [[NSMutableAttributedString alloc] init];
    
    CGFloat duration = [self totalDuration];
    
    CGFloat minutes = duration/60.0f;
    if (minutes > 60) {
        CGFloat hour = minutes/60.0f;
        minutes = (hour - floor(hour)) * 60;
        hour = floor(hour);
        minutes = floor(minutes);
        
        NSAttributedString *hourValAttrStr = [[NSAttributedString alloc] initWithString:@(hour).stringValue attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Karla-Bold" size:14]}];
        NSAttributedString *minuteValAttrStr = [[NSAttributedString alloc] initWithString:@(minutes).stringValue attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Karla-Bold" size:14]}];
        NSAttributedString *hourAttrStr = [[NSAttributedString alloc] initWithString:@" hr" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Karla-Regular" size:14]}];
        NSAttributedString *minuteAttrStr = [[NSAttributedString alloc] initWithString:@" min" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Karla-Regular" size:14]}];
        
        [fullStr appendAttributedString:hourValAttrStr];
        [fullStr appendAttributedString:hourAttrStr];
        [fullStr appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:nil]];
        [fullStr appendAttributedString:minuteValAttrStr];
        [fullStr appendAttributedString:minuteAttrStr];
    }else{
//        if (minutes < 1) {
//            CGFloat secs = minutes * 60;
//            NSAttributedString *minuteValAttrStr = [[NSAttributedString alloc] initWithString:@(secs).stringValue attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Karla-Bold" size:14]}];
//            NSAttributedString *minuteAttrStr = [[NSAttributedString alloc] initWithString:@" secs" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Karla-Regular" size:14]}];
//            
//            [fullStr appendAttributedString:minuteValAttrStr];
//            [fullStr appendAttributedString:minuteAttrStr];
//        }else{
            minutes = ceil(minutes);
            NSAttributedString *minuteValAttrStr = [[NSAttributedString alloc] initWithString:@(minutes).stringValue attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Karla-Bold" size:14]}];
            NSAttributedString *minuteAttrStr = [[NSAttributedString alloc] initWithString:@" min" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Karla-Regular" size:14]}];
            
            [fullStr appendAttributedString:minuteValAttrStr];
            [fullStr appendAttributedString:minuteAttrStr];
//        }
        
        
    }
    return fullStr;
}

- (void)setTrips:(NSArray *)trips{
   [trips enumerateObjectsUsingBlock:^(KMTrip *trip, NSUInteger idx, BOOL * _Nonnull stop) {
       if (idx == 0) {
           if (trips.count > 1) {
               trip.nextTrip = trips[1];
           }
           
       }else if (idx == trips.count -1){
           trip.prevTrip = trips[idx-1];
       }
       else{
           trip.prevTrip = trips[idx-1];
           if (trips.count > idx+1) {
               trip.nextTrip = trips[idx+1];
           }
           
       }
   }];
    
    _trips = trips;
}

- (BOOL)dateEqualToVehicleDayHistory:(KMTravelHistory*)history{
    return [[NSCalendar currentCalendar] isDate:self.historyDate equalToDate:history.historyDate toUnitGranularity:NSCalendarUnitDay];;
}

- (BOOL)isEqual:(KMTravelHistory*)object{
    if ([self dateEqualToVehicleDayHistory:object] && self.trips.count == object.trips.count && self.distance == object.distance) {
        return YES;
    }
    return NO;
}

- (NSComparisonResult)compare:(KMTravelHistory *)object{
    return [self.historyDate compare:object.historyDate];
}

#pragma mark - Custom type

- (void)setupCustomTypeDetailFromDayHistories:(NSArray*)dayHistories{
    if (dayHistories.count == 0) {
        return;
    }
    
    NSArray *sorted = [dayHistories sortedArrayUsingSelector:@selector(compare:)];
    NSDateComponents *components = [[NSDateComponents alloc] init] ;
    [components setDay:-1];
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[sorted.firstObject historyDate] options:0];
    self.historyDate = yesterday;
    
    CGFloat duration = 0;
    CGFloat distance = 0;
    CGFloat idleDuration = 0;
    
    for (KMTravelHistory *history in dayHistories) {
        duration += history.duration;
        distance += history.distance;
        idleDuration += history.idleDuration;
    }
    self.duration = duration;
    self.distance = distance;
    self.idleDuration = idleDuration;
}

- (NSString*)description{
    return [NSString stringWithFormat:@"%@, trips:%@, maxSpeed:%.1f, date:%@", [super description], self.trips, self.maxSpeed, self.historyDate];
}

@end

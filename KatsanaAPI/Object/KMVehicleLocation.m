//
//  KMVehicleLocation.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/17/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import "KMVehicleLocation.h"
#import "KMAddress.h"

@implementation KMVehicleLocation
{
    NSString *_address;
    CLLocationCoordinate2D _lastCoord;
}

static NSDateFormatter *sharedDateFormatter = nil;
+ (NSDateFormatter*)sharedDateFormatter {
    if (!sharedDateFormatter) {
        sharedDateFormatter = [[NSDateFormatter  alloc] init];
        [sharedDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone *inputTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [sharedDateFormatter setTimeZone:inputTimeZone];
    }
    return sharedDateFormatter;
}

+ (KMVehicleLocation*)vehiclePositionFromDictionary:(NSDictionary*)dicto{
    KMVehicleLocation *pos;
    if (dicto[@"data"]) {
        NSDictionary *current = dicto[@"data"][@"current"];
        pos = [[KMVehicleLocation alloc] init];
        pos.latitude = [current[@"latitude"] doubleValue];
        pos.longitude = [current[@"longitude"] doubleValue];
        pos.speed = [current[@"speed"] floatValue];
        pos.state = current[@"state"];
        pos.voltage = current[@"voltage"];
        pos.gsm = current[@"gsm"];
        pos.ignitionState = [current[@"ignition"] boolValue];
        
        NSString *dateStr = current[@"tracked_at"];
        pos.trackedAt = [[KMVehicleLocation sharedDateFormatter] dateFromString:dateStr];
        
//        pos.voltage =
        
    }
    return pos;
}

- (CLLocationCoordinate2D)coordinate{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

-(void)addressWithCompletionBlock:(void (^)(NSString *address))completion{
    [self addressWithCountry:NO completionBlock:completion];
}

-(void)addressWithCountry:(BOOL)useCountry completionBlock:(void (^)(NSString *address))completion
{
    if (CLCOORDINATES_EQUAL2(_lastCoord, self.coordinate) && _address.length > 0) {
        completion(_address);
        return;
    }
    
    [[KatsanaAPI shared] requestAddressFor:CLLocationCoordinate2DMake(self.latitude, self.longitude) completion:^(KMAddress * address) {
        if (useCountry) {
            _address = address.optimizedAddressWithCountry;
        }else{
            _address = address.optimizedAddress;
        }
        _lastCoord = self.coordinate;
        completion(_address);


    } failure:^(NSError * err) {
        
    }];
}

- (NSString*)address{
    return _address;
}

- (NSString*)updatedDateString{
    NSDate *updated = self.trackedAt;
    NSString *updatedString;
    
    CGFloat duration = [[NSDate date] timeIntervalSinceDate:updated];
    if (duration < 60) {
        updatedString = [NSString stringWithFormat:@"Updated %.0f sec ago", duration];
    }else if (duration < 60 * 60){
        CGFloat minute = duration/60;
        updatedString = [NSString stringWithFormat:@"Updated %.0f min ago", minute];
    }else{
        CGFloat hour = duration/(60*60);
        updatedString = [NSString stringWithFormat:@"Updated %.0f hour ago", hour];
    }
    
    if (!updated) {
        return @"Updated";
    }
    
    return updatedString;
}

- (NSString*)speedString{
    return [KatsanaFormatter speedStringFromKnot:self.speed];
}

- (BOOL)locationEqualToVehiclePosition:(KMVehicleLocation*)otherPos{
    if (!otherPos) {
        return NO;
    }
    
    if (self.latitude == otherPos.latitude && self.longitude == otherPos.longitude) {
        return YES;
    }
    return NO;
}

- (BOOL)locationEqualToCoordinate:(CLLocationCoordinate2D)coord{
    if (self.latitude == coord.latitude && self.longitude == coord.longitude) {
        return YES;
    }
    return NO;
}

- (CGFloat)distanceToPosition:(KMVehicleLocation*)pos{
    CLLocation *current = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    CLLocation *itemLoc = [[CLLocation alloc] initWithLatitude:pos.latitude longitude:pos.longitude];
    CLLocationDistance itemDist = [itemLoc distanceFromLocation:current];
    return itemDist;
}

- (CGFloat)distanceToCoordinate:(CLLocationCoordinate2D)coord{
    CLLocation *current = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    CLLocation *itemLoc = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    CLLocationDistance itemDist = [itemLoc distanceFromLocation:current];
    return itemDist;
}

- (NSDate*)localizedTrackedAt{
        NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:self.trackedAt];
        NSDate *date = [self.trackedAt dateByAddingTimeInterval:timeZoneOffset];
    return date;
}

- (CGFloat)localizedSpeed{
    CGFloat speed = [KatsanaFormatter localizedSpeedWithKnot:self.speed];
    return speed;
}

//- (NSString*)description{
//    return [NSString stringWithFormat:@"%@, voltage: %@", [super description], self.voltage];
//}


@end

//
//  KMActivityObject.m
//  Katsana
//
//  Created by Wan Ahmad Lutfi on 17/06/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import "KMActivityObject.h"

@implementation KMActivityObject

+ (NSArray*)fastCodingKeys{
    NSArray *keys = [super fastCodingKeys];
    keys = [keys arrayByAddingObjectsFromArray:@[@"identifier", @"altitude", @"course", @"speed", @"serverTimeText"]];
    return keys;
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

static NSDateFormatter *sharedDateFormatter2 = nil;
+ (NSDateFormatter*)sharedDateFormatter2 {
    if (!sharedDateFormatter2) {
        sharedDateFormatter2 = [[NSDateFormatter  alloc] init];
        [sharedDateFormatter2 setDateFormat:@"dd-MM-yyyy"];
    }
    return sharedDateFormatter2;
}

static NSDateFormatter *sharedDateFormatter3 = nil;
+ (NSDateFormatter*)sharedDateFormatter3 {
    if (!sharedDateFormatter3) {
        sharedDateFormatter3 = [[NSDateFormatter  alloc] init];
        [sharedDateFormatter3 setDateFormat:@"dd MM yyyy, hh:mm a"];
//        11 July 2016, 8:59 AM
    }
    return sharedDateFormatter3;
}

- (NSAttributedString*)attributedMessage{
    if (!_attributedMessage) {
        if ([self respondsToSelector:@selector(attributedMessageInCategory)]) {
            _attributedMessage = [self valueForKey:@"attributedMessageInCategory"];
        }
    }
    return _attributedMessage;
}

+ (NSArray*)violationsFromDictionary:(NSDictionary*)dicto{
    NSMutableArray *violations = [NSMutableArray array];
    [dicto enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSDictionary *obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            KMViolation *violation = [[KMViolation alloc] init];
            
            NSString *type = obj[@"type"];
            NSNumber *deviceId = obj[@"device_id"];
            NSString *message = obj[@"message"];
            NSString *time = obj[@"time"];
            
            NSDate *date = [[self sharedDateFormatter] dateFromString:time];
            if (!date) {
                date = [NSDate date];
            }
            
            violation.policyType = type;
            violation.deviceId = deviceId.stringValue;
            violation.message = message;
            violation.startTime = date;
            [violations addObject:violation];
        }
    }];
    return violations;
}

+ (KMActivityObject*)activityObjectFromDictionary:(NSDictionary*)obj identifier:(NSString*)identifier{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        KMActivityObject *activity = [[KMActivityObject alloc] init];
        
        NSString *type = obj[@"type"];
        if (!type) {
            return nil;
        }
        
        NSNumber *deviceId = obj[@"device_id"];
        NSString *message = obj[@"message"];
        NSString *time = obj[@"time"];
        
        NSDate *date = [[self sharedDateFormatter] dateFromString:time];
        if (!date) {
            date = [NSDate date];
        }
        activity.policyType = type;
        activity.deviceId = deviceId.stringValue;
        activity.message = message;
        activity.startTime = date;
        activity.identifier = identifier;
        activity.serverTimeText = time;

        return activity;
    }
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    //Do nothing if key undefined
}


#pragma mark - Logic
                         
- (CGFloat)localizedSpeed{
    CGFloat speed = self.speed;
    if (speed == 0) {
        NSString *text = [self.message stringByReplacingOccurrencesOfString:self.vehicle.vehicleNumber withString:@""];
        NSString *numberStr = [self extractNumberFromText:text];
        speed = numberStr.floatValue;
    }else{
        speed *= KNOT_TO_KMH;
    }
    
    return speed ;
}

- (NSString*)dateString{
    return [[KMActivityObject sharedDateFormatter2] stringFromDate:self.startTime];
}

- (NSString *)extractNumberFromText:(NSString *)text
{
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [[text componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
}

@end

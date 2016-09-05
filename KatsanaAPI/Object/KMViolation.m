//
//  KMViolation.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 07/01/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import "KMViolation.h"
#import "KMAddress.h"

@implementation KMViolation

+ (NSArray*)fastCodingKeys{
    return @[@"deviceId", @"message", @"distance", @"duration", @"latitude", @"longitude", @"startTime", @"endTime", @"startPosition", @"endPosition", @"violationId", @"policyId", @"policyType", @"maxSpeed", @"averageSpeed"];
}

- (CLLocationCoordinate2D)coordinate{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (void)setAddress:(NSString *)address{
    _address = address;
}


- (KMVehicle*)vehicle{
    if (!_vehicle) {
        _vehicle = [[KMUserManager sharedInstance] vehicleWithVehicleId:self.deviceId];
    }
    return _vehicle;
}

-(void)addressWithCompletionBlock:(void (^)(NSString *address))completion
{
    if (self.latitude == 0) {
        completion(@"");
        return;
    }
    [[KMUserManager sharedInstance] loadAddressWithLocation:CLLocationCoordinate2DMake(self.latitude, self.longitude) address:^(KMAddress *address) {
        _address = address.optimizedAddress;
        completion(_address);
    } failure:^(NSError *error) {
        
    }];
}

- (void)setPolicyType:(NSString *)policyType{
    KMViolationPolicyTypeId type = 0;
    _policyType = policyType;
    if ([self.policyType isEqualToString:@"speed"]) {
        type = KMViolationPolicyTypeSpeed;
    }
    else if ([self.policyType isEqualToString:@"movement"]) {
        type = KMViolationPolicyTypeTime;
    }
    else if ([self.policyType isEqualToString:@"battery-cutoff"]) {
        type = KMViolationPolicyTypeBatteryCutoff;
    }
    else if ([self.policyType isEqualToString:@"area"]) {
        type = KMViolationPolicyTypeArea;
    }
    else if ([self.policyType isEqualToString:@"trip-start"]) {
        type = KMViolationPolicyTypeMovement;
    }
    else if ([self.policyType isEqualToString:@"lockdown"]) {
        type = KMViolationPolicyTypeLockdown;
    }
    else if ([self.policyType isEqualToString:@"speed-summary"]) {
        type = KMViolationPolicyTypeSpeedSummary;
    }
    else if ([self.policyType isEqualToString:@"harsh-brake"]) {
        type = KMViolationPolicyTypeHarshBrake;
    }
    else if ([self.policyType isEqualToString:@"harsh-accelerate"]) {
        type = KMViolationPolicyTypeHarshAccelerate;
    }
    else if ([self.policyType isEqualToString:@"checkpoint"]) {
        type = KMViolationPolicyCheckpoint;
    }
    else{
        //Add log only
//        NSMutableArray *violations = [KMGlobalHelper sharedInstance].customValues[@"violationTypeHandled"];
//        if (!violations) {
//            violations = [NSMutableArray array];
//            [KMGlobalHelper sharedInstance].customValues[@"violationTypeHandled"] = violations;
//        }
//        if (![violations containsObject:policyType] && policyType) {
//            DDLogError(@"No enum for policy type '%@'!", policyType);
//            [violations addObject:policyType];
//        }
    }
    _policyTypeId = type;
}

- (NSString*)violationType{
    NSString *type= @"";
    if ([self.policyType isEqualToString:@"speed"]) {
        type = @"OVERSPEEDING";
    }
    else if ([self.policyType isEqualToString:@"movement"]) {
        type = @"MOVEMENT";
    }
    else if ([self.policyType isEqualToString:@"battery-cutoff"]) {
        type = @"BATTERY-CUTOFF";
    }
    else if ([self.policyType isEqualToString:@"area"]) {
        type = @"AREA";
    }
    return type;
}

- (NSString*)policyAlertString{
    NSString *type= @"";
    switch (self.policyTypeId) {
        case KMViolationPolicyTypeNone: {
            
            break;
        }
        case KMViolationPolicyTypeMovement: {
            type = @"movement alerts";
            break;
        }
        case KMViolationPolicyTypeTime: {
            type = @"time alerts";
            break;
        }
        case KMViolationPolicyTypeSpeed: {
            type = @"speed alerts";
            break;
        }
        case KMViolationPolicyTypeArea: {
            type = @"area alerts";
            break;
        }
        case KMViolationPolicyTypeBatteryCutoff: {
            type = @"battery-cutoff alerts";
            break;
        }
        case KMViolationPolicyTypeRefuel: {
            type = @"refuel";
            break;
        }
        case KMViolationPolicyTypeSiphoning: {
            type = @"fuel theft";
            break;
        }
        case KMViolationPolicyTypeSpeedSummary: {
            type = @"";
            break;
        }
        case KMViolationPolicyTypeHarshBrake: {
            type = @"harsh braking alerts";
            break;
        }
        case KMViolationPolicyTypeHarshAccelerate: {
            type = @"harsh accelerate alerts";
            break;
        }
        case KMViolationPolicyCheckpoint: {
            type = @"checkpoint alerts";
            break;
        }
    }
    return type;
}

- (NSString*)violationInfo{
    NSString *str = @"";
    
    switch (self.policyTypeId) {
        case KMViolationPolicyTypeNone: {
            
            break;
        }
        case KMViolationPolicyTypeMovement: {
            break;
        }
        case KMViolationPolicyTypeTime: {
            break;
        }
        case KMViolationPolicyTypeSpeed: {
            CGFloat min = self.duration/60.0f;
            
            str = [NSString stringWithFormat:@"Speeding for %.0f minutes with maximum speed %.0f km/h", min, self.localizedMaxSpeed];
            break;
        }
        case KMViolationPolicyTypeArea: {
            str = [NSString stringWithFormat:@"Breaking area policy \"%@\"", self.message];
            break;
        }
        case KMViolationPolicyTypeBatteryCutoff: {

            break;
        }
        case KMViolationPolicyTypeRefuel: {
            break;
        }
        case KMViolationPolicyTypeSiphoning: {
            break;
        }
        case KMViolationPolicyTypeSpeedSummary: {
            break;
        }
        case KMViolationPolicyTypeHarshAccelerate: {
            break;
        }
        case KMViolationPolicyTypeHarshBrake: {
            break;
        }
    }
    return str;
}

- (NSComparisonResult)compare:(KMViolation*)other
{
    if ([other isKindOfClass:[KMViolation class]]) {
        return [self.startTime compare:other.startTime];
    }
    return NSOrderedSame;
}

static NSArray *violationTypes = nil;
+ (NSArray*) violationTypes {
    if (!violationTypes) {
        NSMutableArray *types = [NSMutableArray array];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"notificationSettings" ofType:@"plist"];
        NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:path];
        for (NSMutableDictionary *dicto in data) {
            NSMutableArray *items = dicto[@"items"];
            [items filterUsingPredicate:[NSPredicate predicateWithFormat:@"enabled == %lu", YES]];
            for (NSDictionary *item in items) {
                NSString *key = item[@"key"];
                [types addObject:key];
            }
        }
        violationTypes = types.copy;
    }
    return violationTypes;
}

//+ (NSArray*)violationTypes{
//    
//    NSArray *violations = @[@"trip-start", @"lockdown", @"speed", @"movement", @"battery-cutoff", @"area", @"harsh-brake", @"harsh-accelerate"];
//    return violations;
//}

- (CGFloat)localizedMaxSpeed{
    return self.maxSpeed * KNOT_TO_KMH;
}

@end

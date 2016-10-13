//
//  KMNotificationSettings.m
//  Katsana
//
//  Created by Wan Ahmad Lutfi on 23/06/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import "KMNotificationSettings.h"
#import "KMNotificationSettingsObject.h"

@interface KMNotificationSettings ()

@property (nonatomic, strong) NSMutableDictionary *needUpdateAllInfo;

@end

@implementation KMNotificationSettings

- (NSMutableDictionary*)needUpdateAllInfo{
    if (!_needUpdateAllInfo) {
        _needUpdateAllInfo = [NSMutableDictionary dictionary];
    }
    return _needUpdateAllInfo;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath{
    if ([keyPath hasPrefix:@"the"]) {
        NSString *theKeypath = [keyPath stringByReplacingOccurrencesOfString:@"the" withString:@""];
        theKeypath = [theKeypath stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[theKeypath substringToIndex:1].lowercaseString];
        [self handleAddArrayForKeypath:theKeypath value:value];
    }else{
        [super setValue:value forKeyPath:keyPath];
    }
}

- (id)valueForKeyPath:(NSString *)keyPath{
    if ([keyPath hasPrefix:@"the"]) {
        NSString *theKeypath = [keyPath stringByReplacingOccurrencesOfString:@"the" withString:@""];
        theKeypath = [theKeypath stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[theKeypath substringToIndex:1].lowercaseString];
        NSArray *values = [self valueForKeyPath:theKeypath];
        NSMutableDictionary *dicto = [NSMutableDictionary dictionary];
        for (KMNotificationSettingsObject *settingsObj in values) {
            [dicto setValue:@(settingsObj.enabled) forKey:settingsObj.vehicleId];
        }
        return dicto;
    }else{
        return [super valueForKeyPath:keyPath];
    }
}

- (void)handleAddArrayForKeypath:(NSString*)keypath value:(NSDictionary*)value{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:value.count];
    [value enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        KMNotificationSettingsObject *settingsObj = [[KMNotificationSettingsObject alloc] init];
        settingsObj.enabled = [obj boolValue];
        settingsObj.vehicleId = key;
        
        
        [array addObject:settingsObj];
    }];
    [self setValue:array forKeyPath:keypath];
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
}

- (id)patchValueForKeypath:(NSString*)keypath{
    NSString* theKeypath = [keypath stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[keypath substringToIndex:1].uppercaseString];
    theKeypath = [@"the" stringByAppendingString:theKeypath];
    return [self valueForKeyPath:theKeypath];
}

- (BOOL)needUpdateAllForKeypath:(NSString*)keypath boolValue:(BOOL*)boolValue{
    NSDictionary *subDict = self.needUpdateAllInfo[keypath];
    if (subDict) {
        if ([subDict[@"needUpdate"] boolValue] == YES) {
            BOOL theBool = [subDict[@"bool"] boolValue];
            *boolValue = theBool;
            return YES;
        }
    }
    return NO;
}

- (void)setNeedUpdateForAllForKeypath:(NSString*)keypath boolValue:(BOOL)boolValue{
    NSDictionary *subDict = @{@"needUpdate" : @YES, @"bool" : @(boolValue)};
    self.needUpdateAllInfo[keypath] = subDict;
}

@end

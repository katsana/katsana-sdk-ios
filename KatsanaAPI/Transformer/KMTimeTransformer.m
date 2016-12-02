//
//  KMTimeTransformer.m
//  Katsana
//
//  Created by Wan Ahmad Lutfi on 23/05/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import "KMTimeTransformer.h"

@implementation KMTimeTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[NSNumber class]]) {
        CGFloat duration = [value floatValue];
        CGFloat minutes = duration/60.0f;
        if (minutes > 60) {
            CGFloat hour = minutes/60.0f;
            minutes = (hour - floor(hour)) * 60;
            hour = floor(hour);
            minutes = floor(minutes);
            
            NSString *timeStr;
            if (hour >= 24) {
                CGFloat day = hour/24.0f;
                hour = (day - floor(day)) * 24;
                hour = ceil(hour);
                timeStr = [NSString stringWithFormat:@"%.0f day %.0f hours", day, hour];
            }else{
                timeStr = [NSString stringWithFormat:@"%.0f hr %.0f min", hour, minutes];
                if (self.fullFormat) {
                    timeStr = [NSString stringWithFormat:@"%.0f hour %.0f minutes", hour, minutes];
                }
            }
            return timeStr;
        }else{
            NSString *timeStr;
            if (minutes < 1) {
                timeStr = [NSString stringWithFormat:@"%.0f sec", minutes * 60];
                if (self.fullFormat) {
                    timeStr = [NSString stringWithFormat:@"%.0f seconds", minutes * 60];
                }
            }else{
                minutes = round(minutes);
                timeStr = [NSString stringWithFormat:@"%.0f min", minutes];
                if (self.fullFormat) {
                    timeStr = [NSString stringWithFormat:@"%.0f minutes", minutes];
                }
            }
            
            return timeStr;
        }
        
    }
    return @"0 min";
}

//- (id)reverseTransformedValue:(id)value{
//    if ([value isKindOfClass:[NSColor class]]) {
//        NSString *hex = [value hexString];
//        //        hex = [NSStrings stringWithFormat:@"#%@", hex];
//        return hex;
//        
//    }
//    return @"#FFFFFF";
//}

@end

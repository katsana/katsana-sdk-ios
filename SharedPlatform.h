//
//  SharedPlatform.h
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 15/11/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//


#if TARGET_OS_IPHONE
#define KMImage UIImage
#define KMFont UIFont
#define KMColor UIColor

#elif TARGET_OS_MAC
#define KMImage NSImage
#define KMFont NSFont
#define KMColor NSColor
#endif


typedef void (^ImageCompletionBlock)(KMImage *image);
#define CLCOORDINATE_EPSILON 0.005f
#define CLCOORDINATES_EQUAL2( coord1, coord2 ) (fabs(coord1.latitude - coord2.latitude) < CLCOORDINATE_EPSILON && fabs(coord1.longitude - coord2.longitude) < CLCOORDINATE_EPSILON)

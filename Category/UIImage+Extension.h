//
//  UIImage+Extension.h
//  KatsanaAPI
//
//  Created by Wan Ahmad Lutfi on 30/08/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

+ (UIImage *)imageWithColor:(UIColor *)color ;
- (UIImage*)scaleToSize:(CGSize)size;
- (UIImage *)fixOrientation;

@end

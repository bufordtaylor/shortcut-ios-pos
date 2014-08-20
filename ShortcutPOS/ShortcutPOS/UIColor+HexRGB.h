//
//  UIColor+HexRGB.h
//  ShortcutPOS
//
//  Created by Christophe Maximin on 20/08/2014.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexRGB)

+ (UIColor *)colorWithHexRGB:(int)rgbValue withAlpha:(CGFloat)alphaValue;
+ (UIColor *)colorWithHexRGB:(int)rgbValue;

+ (UIColor *)colorWithStringHexRGB:(NSString *)rgb withAlpha:(CGFloat)alphaValue;
+ (UIColor *)colorWithStringHexRGB:(NSString *)rgb;

//+ (UIColor *)colorWithHexRGBA:(int)rgbaValue;

@end

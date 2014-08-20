//
//  UIColor+HexRGB.m
//  ShortcutPOS
//
//  Created by Christophe Maximin on 20/08/2014.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "UIColor+HexRGB.h"

@implementation UIColor (HexRGB)

// Inputing a number, e.g. 0xFF0000

+ (UIColor *)colorWithHexRGB:(int)rgbValue withAlpha:(CGFloat)alphaValue
{
    return [UIColor
                colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                blue:((float)(rgbValue & 0xFF))/255.0
                alpha:alphaValue];
}

+ (UIColor *)colorWithHexRGB:(int)rgbValue
{
    return [self colorWithHexRGB:rgbValue
                       withAlpha:1];
}

// Inputing a string, e.g. "FF0000"

+ (UIColor *)colorWithStringHexRGB:(NSString *)rgb withAlpha:(CGFloat)alphaValue
{
    return [self colorWithHexRGB:[self hexInt:rgb]
                       withAlpha:alphaValue];
}

+ (UIColor *)colorWithStringHexRGB:(NSString *)rgb
{
    return [self colorWithHexRGB:[self hexInt:rgb]];
}

// The following works, but is commented because its usage wouldn't be common.
//+ (UIColor *)colorWithHexRGBA:(int)rgbaValue
//{
//    return [UIColor
//            colorWithRed:((float)((rgbaValue & 0xFF000000) >> 24))/255.0
//            green:((float)((rgbaValue & 0xFF0000) >> 16))/255.0
//            blue:((float)((rgbaValue & 0xFF00) >> 8))/255.0
//            alpha:((float)(rgbaValue & 0xFF))/255.0];
//}

# pragma mark - Internal helpers

+ (int)hexInt:(NSString *)hex
{
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner scanHexInt:&result];
    return result;
}

@end

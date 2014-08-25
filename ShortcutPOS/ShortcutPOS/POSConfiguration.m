//  POSConfiguration.m
//  Created by Christophe Maximin on 19/08/2014.

@implementation POSConfiguration

+ (NSString *)environment
{
    return @"development"; // comment this line if you want to run in production
    return @"production";
}

+ (NSString *)serverBaseURL
{
    return [self serverBaseURLViaSSL:true];
}

+ (NSString *)serverBaseURLViaSSL:(BOOL)viaSSL
{
    if ([[self environment] isEqualToString:@"production"]) {
        if (viaSSL) {
            return @"https://shortcutapp.com";
        } else {
            return @"http://shortcutapp.com";
        }
    } else {
//        return @"http://shortcutapp.dev";
        return @"http://10.2.198.196:1234";
    }
}

# pragma mark - Environment shorthands

+ (BOOL)production
{
    return [[self environment] isEqualToString:@"production"];
}

+ (BOOL)development
{
    return [[self environment] isEqualToString:@"development"];
}

# pragma mark - Colors

+ (NSString *)colorStringOf:(NSString *)colorKeyName
{
    NSDictionary *colorsDict =
        @{
            @"shortcut-purple": @"744790",
            @"light-gray": @"dddddd",
            @"dark-gray": @"777777",
        };
    
    return [colorsDict objectForKey:colorKeyName];
}

// Color Helper

+ (UIColor *)colorFor:(NSString *)colorKeyName
{
    NSString *hexRGBColor = [self colorStringOf:colorKeyName];
    return [UIColor colorWithStringHexRGB:hexRGBColor];
}

# pragma mark - Fonts

+ (NSString *)defaultFont
{
    return @"Helvetica";
}

+ (NSString *)defaultFontBold
{
    return @"Helvetica Bold";
}

@end
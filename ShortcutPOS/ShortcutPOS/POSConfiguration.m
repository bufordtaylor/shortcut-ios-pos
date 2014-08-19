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
        return @"http://shortcutapp.dev";
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


@end
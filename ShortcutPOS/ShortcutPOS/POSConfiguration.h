//  POSConfiguration.h
//  Created by Christophe Maximin on 19/08/2014.

@interface POSConfiguration : NSObject

+ (NSString *)environment;
+ (NSString *)serverBaseURL;
+ (NSString *)serverBaseURLViaSSL:(BOOL)viaSSL;

+ (NSString *)colorStringOf:(NSString *)colorKeyName;
+ (UIColor *)colorFor:(NSString *)colorKeyName;

+ (BOOL)production;
+ (BOOL)development;

@end
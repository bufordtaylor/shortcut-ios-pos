//  POSConfiguration.h
//  Created by Christophe Maximin on 19/08/2014.

@interface POSConfiguration : NSObject

+ (NSString *)environment;
+ (NSString *)serverBaseURL;
+ (NSString *)serverBaseURLViaSSL:(BOOL)viaSSL;

+ (BOOL)production;
+ (BOOL)development;

@end
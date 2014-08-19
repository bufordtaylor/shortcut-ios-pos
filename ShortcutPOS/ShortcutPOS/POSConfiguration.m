//
//  POSConfiguration.m
//  
//
//  Created by Christophe Maximin on 19/08/2014.
//
//

#define LIVE // comment this ENTIRE line if you are in dev mode

#ifdef LIVE
    BOOL const kLive = true;
    NSString *const kServerBaseURL = @"http://shortcutapp.com";
    NSString *const kServerSecureBaseURL = @"https://shortcutapp.com";
#else
    BOOL const kLive = false;
    NSString *const kServerBaseURL = @"http://shortcutapp.dev";
    NSString *const kServerSecureBaseURL = @"https://shortcutapp.dev";
#endif
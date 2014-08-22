//
//  POSWebViewController.m
//  ShortcutPOS
//
//  Created by Christophe Maximin on 19/08/2014.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "POSWebViewController.h"
#import "POSCardInputViewController.h"

@interface POSWebViewController ()
    <
        UIWebViewDelegate
    >

@property UIView *webViewWrapperView;
@property UIWebView *webView;
@property BOOL loadedAtLeastOnePage;

@end

@implementation POSWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [POSConfiguration colorFor:@"shortcut-purple"];
    
    // Wrapper around the WebView
    self.webViewWrapperView = [[UIView alloc] init];
    self.webViewWrapperView.hidden = true;
    self.webViewWrapperView.frame = CGRectMake(0, 0,
                                               self.view.frame.size.width,
                                               self.view.frame.size.height);
    [self.view addSubview:self.webViewWrapperView];
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.webViewWrapperView.frame = CGRectMake(0, 0,
                                        self.view.frame.size.width,
                                        self.view.frame.size.height);
    } else {
        self.webViewWrapperView.frame = CGRectMake(0, 0,
                                        self.view.frame.size.height,
                                        self.view.frame.size.width);
    }
    
    // Settings cookies
    NSData *keyedCookies = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookies"];
    if (keyedCookies) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:keyedCookies];
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in cookies) {
            [cookieStorage setCookie:cookie];
        }
    }
    
    
    // Setting a custom UserAgent that will allow the web app to display special content
    NSString *newUserAgent =
         [NSString
          stringWithFormat:@"ShortcutPOS-iOS/%@_%@",
              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    NSDictionary *dictionary = [NSDictionary
                                dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    // Webview
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.frame = self.webViewWrapperView.frame;
    self.webView.hidden = true;
    [self.webViewWrapperView addSubview:self.webView];
    
    // Handle swiping right (=> from left to right) to go to previous page
    UISwipeGestureRecognizer *swipeRightGesture =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(swipedRight:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.webView addGestureRecognizer:swipeRightGesture];
    
    // Reload button
    float width, height;
    UIImage *reloadImage = [UIImage imageNamed:@"reload"];
    UIImageView *reloadImageView = [[UIImageView alloc] initWithImage:reloadImage];
    reloadImageView.tag = kReloadImageViewTag;
    reloadImageView.userInteractionEnabled = true;
    [reloadImageView
     addGestureRecognizer:[[UITapGestureRecognizer alloc]
                           initWithTarget:self
                           action:@selector(reloadTapped:)]];
    // reload button align at the bottom left
    width = 30; height = 30;
    reloadImageView.frame = CGRectMake(0,
                                       self.webViewWrapperView.frame.size.height - height,
                                       width, height);
    [self.webViewWrapperView addSubview:reloadImageView];
    
    [self loadWebPOS];

}

///*
// tmp
- (void)viewDidAppear:(BOOL)animated
{
    POSCardInputViewController *cardInputVC = [[POSCardInputViewController alloc] init];
    [self presentViewController:cardInputVC animated:YES completion:nil];
}
//*/

#pragma mark - UIWebView
#pragma mark UIWebView actions

- (void)loadWebPOS
{
    NSString *posURL = [[POSConfiguration serverBaseURL]
                        stringByAppendingString:@"/pos/concessions"];
    [self.webView
     loadRequest:[NSURLRequest
                  requestWithURL:[NSURL
                                  URLWithString:posURL]]];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
    
    if (!self.loadedAtLeastOnePage) {
        self.webView.hidden = false;
        [self showStatusView:@"Loading Shortcut POS ..."];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    
    self.loadedAtLeastOnePage = true;
    [self hideStatusView];
    
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:
                                [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cookiesData forKey:@"cookies"];
    [userDefaults synchronize];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError %@", error);
    
    // we don't want to show an error if a page loading was cancelled,
    // which can happen if a user taps a link quickly twice.
    if (error.code == NSURLErrorCancelled) {
        return;
    }
    
    [self showStatusView:@"Failed to contact the POS server.\n\nAre you connected to the internet?"
               withError:true];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *appScheme = @"shortcutpos";
    NSString *jsonDictString = [request.URL.fragment stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    #pragma unused (jsonDictString)
    
    if ([request.URL.scheme isEqualToString:appScheme]) {
        NSString *actionType = request.URL.host;
        
        if ([actionType isEqualToString:@"getStripeToken"]) {
            
            POSCardInputViewController *cardInputVC = [[POSCardInputViewController alloc] init];
            [self presentViewController:cardInputVC animated:YES completion:nil];
        }
        
        return false;
    }
    
    return true;
}

#pragma mark - UITapGestureRecognizer actions

- (void)reloadTapped:(UITapGestureRecognizer *)recognizer
{
    self.loadedAtLeastOnePage = false;
    
    // if the request failed the very first time because the device wasn't online,
    // we can't use "reload" on the webView.
    if ([[self.webView.request.URL absoluteString] isEqualToString:@""]) {
        [self loadWebPOS];
    } else {
        [self.webView reload];
    }
}

- (void)swipedRight:(UIGestureRecognizer *)recognizer
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

#pragma mark - statusView actions

- (void)showStatusView:(NSString *)message
{
    [self showStatusView:message withError:false];
}

- (void)showStatusView:(NSString *)message withError:(BOOL)withError
{
    self.webViewWrapperView.hidden = true;
    
    UIView *statusView = [self.view viewWithTag:kStatusViewTag];
    UILabel *messageLabel;
    UIButton *reloadAfterErrorButton;
    
    if (statusView == nil) {
        // building status view
        statusView = [[UIView alloc] init];
        statusView.tag = kStatusViewTag;
        statusView.hidden = true;
        statusView.frame = self.webViewWrapperView.frame;
        [self.view addSubview:statusView];
        
        // building message label
        messageLabel = [[UILabel alloc] init];
        messageLabel.tag = kStatusMessageLabelTag;
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
        [statusView addSubview:messageLabel];
        
        // building reload button
        reloadAfterErrorButton = [[UIButton alloc] init];
        reloadAfterErrorButton.tag = kReloadAfterErrorButtonTag;
        [reloadAfterErrorButton setTitleColor:[UIColor redColor]
                                     forState:UIControlStateNormal];
        [reloadAfterErrorButton setTitle:@"Try again" forState:UIControlStateNormal];
        [reloadAfterErrorButton addTarget:self
                                   action:@selector(reloadTapped:)
                         forControlEvents:UIControlEventTouchUpInside];
        reloadAfterErrorButton.backgroundColor = [UIColor whiteColor];
        [reloadAfterErrorButton sizeToFit];
        reloadAfterErrorButton.frame = CGRectInset(reloadAfterErrorButton.frame, -20, -10);
        reloadAfterErrorButton.center = statusView.center;
        [statusView addSubview:reloadAfterErrorButton];
    }
    
    statusView.hidden = false;
    
    // customizing message label
    messageLabel = (UILabel *)[statusView viewWithTag:kStatusMessageLabelTag];
    messageLabel.text = message;
    CGSize messageLabelSize = [messageLabel
                               sizeThatFits:CGSizeMake(statusView.frame.size.width * 0.95,
                                                       MAXFLOAT)];
    messageLabel.frame = CGRectMake(0, 0, messageLabelSize.width, messageLabelSize.height);
    messageLabel.center = statusView.center;
    
    // customizing reload button
    reloadAfterErrorButton = (UIButton *)[statusView viewWithTag:kReloadAfterErrorButtonTag];
    
    if (withError) {
        statusView.backgroundColor = [UIColor redColor];
        reloadAfterErrorButton.hidden = false;
        CGRect buttonFrame = reloadAfterErrorButton.frame;
        buttonFrame.origin.y = messageLabel.frame.origin.y + messageLabel.frame.size.height + 50;
        reloadAfterErrorButton.frame = buttonFrame;
    } else {
        statusView.backgroundColor = [POSConfiguration colorFor:@"shortcut-purple"];
        reloadAfterErrorButton.hidden = true;
    }
}

- (void)hideStatusView
{
    self.webViewWrapperView.hidden = false;
    
    UIView *statusView = [self.view viewWithTag:kStatusViewTag];
    statusView.hidden = true;
}

@end

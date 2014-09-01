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
        , POSCardInputViewControllerDelegate
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
    self.webViewWrapperView = [UIView new];
    self.webViewWrapperView.hidden = true;
    [self.view addSubview:self.webViewWrapperView];
    
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
    self.webView = [UIWebView new];
    self.webView.delegate = self;
    self.webView.hidden = true;
    self.webView.scrollView.bounces = false;
    [self.webViewWrapperView addSubview:self.webView];
    
    // Handle swiping right (=> from left to right) to go to previous page
    UISwipeGestureRecognizer *swipeRightGesture =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(swipedRight:)];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.webView addGestureRecognizer:swipeRightGesture];
    
    // Reload button
    UIImage *reloadImage = [UIImage imageNamed:@"reload"];
    UIImageView *reloadImageView = [[UIImageView alloc] initWithImage:reloadImage];
    reloadImageView.tag = kReloadImageViewTag;
    reloadImageView.userInteractionEnabled = true;
    [reloadImageView
     addGestureRecognizer:[[UITapGestureRecognizer alloc]
                           initWithTarget:self
                           action:@selector(reloadTapped:)]];
    [self.webViewWrapperView addSubview:reloadImageView];
    
    [self loadWebPOS];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self sizeAndPositionElements:self.interfaceOrientation];
}

- (void)presentCardInputViewController
{
    POSCardInputViewController *cardInputVC = [POSCardInputViewController new];
    
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:cardInputVC];
    cardInputVC.delegate = self;

    cardInputVC.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
         target:cardInputVC
         action:@selector(cancelButtonTapped:)];
    
    cardInputVC.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemDone
         target:cardInputVC
         action:@selector(doneButtonTapped:)];
    
    [self presentViewController:navigationController animated:YES completion:nil];

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [self sizeAndPositionElements:toInterfaceOrientation];
}

- (void)sizeAndPositionElements:(UIInterfaceOrientation)forInterfaceOrientation
{
    // Note:
    // If you open the POSCardInputViewController, then rotate the device, then close it,
    // the size of the view won't be correct "for some reason".
    
    float baseWidth = self.view.frame.size.width;
    float baseHeight = self.view.frame.size.height;
    
    if (UIInterfaceOrientationIsLandscape(forInterfaceOrientation)) {
        baseWidth = self.view.frame.size.height;
        baseHeight = self.view.frame.size.width;
    }
    
    self.webViewWrapperView.frame = CGRectMake(0, 0, baseWidth, baseHeight);
    self.webView.frame = self.webViewWrapperView.frame;
    
    UIImageView *reloadImageView = (UIImageView *)[self.view viewWithTag:kReloadImageViewTag];
    reloadImageView.frame = CGRectMake(0, baseHeight - 30, 30, 30);
    
    UIView *statusView = (UIView *)[self.view viewWithTag:kStatusViewTag];
    statusView.frame = self.webViewWrapperView.frame;

    UILabel *messageLabel = (UILabel *)[self.view viewWithTag:kStatusMessageLabelTag];
    CGSize messageLabelSize = [messageLabel
                               sizeThatFits:CGSizeMake(statusView.frame.size.width * 0.95,
                                                       MAXFLOAT)];
    messageLabel.frame = CGRectMake(0, 0, messageLabelSize.width, messageLabelSize.height);
    messageLabel.center = statusView.center;

    UIButton *reloadAfterErrorButton = (UIButton *)[self.view
                                                    viewWithTag:kReloadAfterErrorButtonTag];
    reloadAfterErrorButton.center = statusView.center;
    
    CGRect buttonFrame = reloadAfterErrorButton.frame;
    buttonFrame.origin.y = messageLabel.frame.origin.y + messageLabel.frame.size.height + 50;
    reloadAfterErrorButton.frame = buttonFrame;

}



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
    
    
    // Logging the HTML source code
//    NSString *html = [self.webView
//                      stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
//    NSLog(@"%@", html);
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

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *appScheme = @"shortcutpos";
    NSString *jsonDictString = [request.URL.fragment
                                stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    #pragma unused (jsonDictString)
    
    if ([request.URL.scheme isEqualToString:appScheme]) {
        NSString *actionType = request.URL.host;
        
        if ([actionType isEqualToString:@"payWithCard"]) {
            [self presentCardInputViewController];
        }
        
        return false;
    }
    
    return true;
}

#pragma mark POSCardInputViewControllerDelegate

- (void)setStripeTokenId:(NSString *)stripeTokenId
{
    NSLog(@"stripe token from the webview: %@", stripeTokenId); // do stuff to the webview here
    
    NSString *jsString;
    jsString = [NSString stringWithFormat:@"window.insertStripeToken('%@');", stripeTokenId];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
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
        statusView = [UIView new];
        statusView.tag = kStatusViewTag;
        statusView.hidden = true;
        [self.view addSubview:statusView];
        
        // building message label
        messageLabel = [UILabel new];
        messageLabel.tag = kStatusMessageLabelTag;
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
        [statusView addSubview:messageLabel];
        
        // building reload button
        reloadAfterErrorButton = [UIButton new];
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
        [statusView addSubview:reloadAfterErrorButton];
    }
    
    statusView.hidden = false;
    
    // customizing message label
    messageLabel = (UILabel *)[statusView viewWithTag:kStatusMessageLabelTag];
    messageLabel.text = message;
    
    // customizing reload button
    reloadAfterErrorButton = (UIButton *)[statusView viewWithTag:kReloadAfterErrorButtonTag];
    
    if (withError) {
        statusView.backgroundColor = [UIColor redColor];
        reloadAfterErrorButton.hidden = false;
    } else {
        statusView.backgroundColor = [POSConfiguration colorFor:@"shortcut-purple"];
        reloadAfterErrorButton.hidden = true;
    }
    
    [self sizeAndPositionElements:self.interfaceOrientation];
}

- (void)hideStatusView
{
    self.webViewWrapperView.hidden = false;
    
    UIView *statusView = [self.view viewWithTag:kStatusViewTag];
    statusView.hidden = true;
}


#pragma mark - Enumerators
#pragma mark View Tags

typedef NS_ENUM(NSInteger, POSWebViewTags) {
    kStatusViewTag = 100,
    kStatusMessageLabelTag,
    kReloadImageViewTag,
    kReloadAfterErrorButtonTag
};

@end

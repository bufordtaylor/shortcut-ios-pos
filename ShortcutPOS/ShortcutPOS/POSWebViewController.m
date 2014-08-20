//
//  POSWebViewController.m
//  ShortcutPOS
//
//  Created by Christophe Maximin on 19/08/2014.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "POSWebViewController.h"

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
    
    self.webViewWrapperView = [[UIView alloc] init];
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
    
    // Webview
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.frame = self.webViewWrapperView.frame;
    [self.webViewWrapperView addSubview:self.webView];
    
    // Reload button
    float width, height;
    
    UIImage *reloadImage = [UIImage imageNamed:@"reload"];
    UIImageView *reloadImageView = [[UIImageView alloc] initWithImage:reloadImage];
    reloadImageView.tag = kReloadImageViewTag;
    reloadImageView.userInteractionEnabled = true;
    [reloadImageView
     addGestureRecognizer:[[UITapGestureRecognizer alloc]
                           initWithTarget:self
                           action:@selector(reloadImageTapped:)]];

    // align at the bottom left
    width = 50; height = 50;
    reloadImageView.frame = CGRectMake(0,
                                       self.webViewWrapperView.frame.size.height - height,
                                       width, height);
    
    [self.webViewWrapperView addSubview:reloadImageView];

    self.webViewWrapperView.frame = CGRectMake(0, 0,
                                               self.view.frame.size.width,
                                               self.view.frame.size.height);

    
    
    [self.webView
        loadRequest:[NSURLRequest
                     requestWithURL:[NSURL
                                     URLWithString:[POSConfiguration serverBaseURL]]]];

}

#pragma mark - Web view delegates

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
    
    if (!self.loadedAtLeastOnePage) {
        [self showStatusView:@"Loading Shortcut POS ..."];
    }
//    UILabel *loadingLabel = [[UILabel alloc] init];
//    loadingLabel.text = @"Loading...";
//    loadingLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
//    loadingLabel.tag = kURLLoadingLabelTag;
//    loadingLabel.font = [UIFont fontWithName:@"Helvetica" size:40];
//    [loadingLabel sizeToFit];
//    loadingLabel.center = self.webView.center;
//    
//    [self.view addSubview:loadingLabel];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    
    self.loadedAtLeastOnePage = true;
    [self hideStatusView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError %@", error);
}

#pragma mark - Gesture actions

- (void)reloadImageTapped:(UITapGestureRecognizer *)recognizer
{
    self.loadedAtLeastOnePage = false;
    [self.webView reload];
}


#pragma mark - POS status view actions

- (UIView *)setStatusView
{
    UIView *statusView = [[UIView alloc] init];
    statusView.tag = kStatusViewTag;
    statusView.hidden = true;
    statusView.frame = self.webViewWrapperView.frame;
    [self.view addSubview:statusView];
    
    UIView *messageLabel = [[UILabel alloc] init];
    messageLabel.tag = kStatusMessageLabelTag;
    [statusView addSubview:messageLabel];
    
    return statusView;
}


- (void)showStatusView:(NSString *)message
{
    [self showStatusView:message withErrorStyle:false];
}

- (void)showStatusView:(NSString *)message withErrorStyle:(BOOL)withErrorStyle
{
    self.webViewWrapperView.hidden = true;
    
    UIView *statusView = [self.view viewWithTag:kStatusViewTag];
    
    if (statusView == nil) {
        statusView = [self setStatusView];
    }
    
    statusView.hidden = false;
    
    UILabel *messageLabel = (UILabel *)[statusView viewWithTag:kStatusMessageLabelTag];
    messageLabel.text = message;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont fontWithName:@"Helvetica" size:25];
    [messageLabel sizeToFit];
    messageLabel.center = statusView.center;
    
    if (withErrorStyle) {
        statusView.backgroundColor = [UIColor redColor];
    } else {
        statusView.backgroundColor = [POSConfiguration colorFor:@"shortcut-purple"];
    }
}

- (void)hideStatusView
{
    self.webViewWrapperView.hidden = false;
    
    UIView *statusView = [self.view viewWithTag:kStatusViewTag];
    statusView.hidden = true;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

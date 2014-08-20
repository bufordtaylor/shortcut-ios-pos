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

@property UIWebView *contentWebView;
@property BOOL loadedAtLeastOnePage;

@end

@implementation POSWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.contentWebView = [[UIWebView alloc] init];
    self.contentWebView.delegate = self;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.contentWebView.frame = CGRectMake(0, 0,
                                               self.view.frame.size.width,
                                               self.view.frame.size.height);
    } else {
        self.contentWebView.frame = CGRectMake(0, 0,
                                               self.view.frame.size.height,
                                               self.view.frame.size.width);
    }
    
    [self.view addSubview:self.contentWebView];
    
    [self.contentWebView
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
//    loadingLabel.center = self.contentWebView.center;
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


#pragma mark - POS status view actions

- (UIView *)setStatusView
{
    UIView *statusView = [[UIView alloc] init];
    statusView.tag = kStatusViewTag;
    statusView.hidden = true;
    statusView.frame = self.contentWebView.frame;
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
    self.contentWebView.hidden = true;
    
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
    self.contentWebView.hidden = false;
    
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

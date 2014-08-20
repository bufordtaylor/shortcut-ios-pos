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
    
    self.view.backgroundColor = [POSConfiguration colorFor:@"shortcut-purple"];
    
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
    
    // Webview
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.frame = self.webViewWrapperView.frame;
    self.webView.hidden = true;
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
    // reload button align at the bottom left
    width = 50; height = 50;
    reloadImageView.frame = CGRectMake(0,
                                       self.webViewWrapperView.frame.size.height - height,
                                       width, height);
    [self.webViewWrapperView addSubview:reloadImageView];
    
    

    // Loading POS from Shortcut servers
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
        self.webView.hidden = false;
        [self showStatusView:@"Loading Shortcut POS ..."];
    }
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
    [self showStatusView:@"Failed to contact the POS server.\n\nAre you connected to the internet?"
          withErrorStyle:true];
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
    messageLabel.numberOfLines = 0;
    messageLabel.text = message;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
    CGSize messageLabelSize = [messageLabel
                               sizeThatFits:CGSizeMake(statusView.frame.size.width * 0.95,
                                                       MAXFLOAT)];
    messageLabel.frame = CGRectMake(0, 0, messageLabelSize.width, messageLabelSize.height);
    NSLog(@"ML %@", NSStringFromCGSize(messageLabel.frame.size));

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

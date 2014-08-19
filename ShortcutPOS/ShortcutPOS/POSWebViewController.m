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

@property (nonatomic, readwrite, strong) UIWebView *contentWebView;

@end

@implementation POSWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentWebView = [[UIWebView alloc] init];
    self.contentWebView.delegate = self;
    self.contentWebView.frame = CGRectMake(0,
                                           0,
                                           self.view.frame.size.width,
                                           self.view.frame.size.height);
    
    [self.view addSubview:self.contentWebView];
    
    [self.contentWebView
        loadRequest:[NSURLRequest
                     requestWithURL:[NSURL URLWithString:kServerBaseURL]]];

}

#pragma mark - Web view delegates

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    UILabel *loadingLabel = [[UILabel alloc] init];
    loadingLabel.text = @"Loading...";
    loadingLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
    loadingLabel.tag = kURLLoadingLabelTag;
    loadingLabel.font = [UIFont fontWithName:@"Helvetica" size:40];
    [loadingLabel sizeToFit];
    loadingLabel.center = self.view.center;
    
    [self.view addSubview:loadingLabel];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    UILabel *loadingLabel = (UILabel *)[self.view viewWithTag:kURLLoadingLabelTag];
    [loadingLabel removeFromSuperview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
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

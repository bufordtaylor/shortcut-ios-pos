//
//  POSCardInputViewController.m
//  ShortcutPOS
//
//  Created by Christophe Maximin on 22/08/2014.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "POSCardInputViewController.h"
#import "CardIO.h"

@interface POSCardInputViewController ()
    <
        CardIOPaymentViewControllerDelegate
    >

@property UITextField *cardNumberTextField;
@property UITextField *cardCvcTextField;

@end

@implementation POSCardInputViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [POSConfiguration colorFor:@"slight-gray"];
    
    // Title Label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.tag = kTitleLabelTag;
    titleLabel.text = @"Card Info";
    [self.view addSubview:titleLabel];
    
    // Images
    UIImageView *imageView;
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Card"]];
    imageView.tag = kCardImageViewTag;
    [self.view addSubview:imageView];
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CardCVC"]];
    imageView.tag = kCardCvcImageViewTag;
    [self.view addSubview:imageView];

    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CardExpiryDate"]];
    imageView.tag = kCardExpiryDateImageViewTag;
    [self.view addSubview:imageView];
    
    // Text fields
    self.cardNumberTextField = [[UITextField alloc] init];
    self.cardNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardNumberTextField.placeholder = @"Card Number";
    [self.view addSubview:self.cardNumberTextField];
    
    self.cardCvcTextField = [[UITextField alloc] init];
    self.cardCvcTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardCvcTextField.placeholder = @"CVC Number";
    [self.view addSubview:self.cardCvcTextField];
    
}

- (void)viewDidLayoutSubviews
{
    // Sizing and positionning subviews for iPhone
    
    float paddingTop, paddingRight, paddingBottom, paddingLeft;
    float cardFieldsMarginTop, cardFieldsOriginX;
    float cardFieldsWidth, cardFieldsHeight;

    UILabel *titleLabel = (UILabel *)[self.view viewWithTag:kTitleLabelTag];
    UIImageView *cardImageView = (UIImageView *)[self.view viewWithTag:kCardImageViewTag];
    UIImageView *cardCvcImageView = (UIImageView *)[self.view viewWithTag:kCardCvcImageViewTag];
    UIImageView *cardExpiryDateImageView = (UIImageView *)[self.view viewWithTag:kCardExpiryDateImageViewTag];
    
    paddingTop = 50, paddingRight = 30, paddingBottom = 10, paddingLeft = 30;
    cardFieldsMarginTop = 30, cardFieldsOriginX = 90;
    cardFieldsHeight = 30;
    cardFieldsWidth = self.view.frame.size.width - cardFieldsOriginX - paddingRight;
    
    UIFont *fieldsFont = [UIFont fontWithName:[POSConfiguration defaultFont]
                                         size:20];
    
    titleLabel.font = [UIFont fontWithName:[POSConfiguration defaultFontBold] size:25];
    titleLabel.frame = CGRectMake(paddingLeft, paddingTop, 0, 0);
    [titleLabel sizeToFit];

    cardImageView.frame =
        CGRectMake(paddingLeft,
                   titleLabel.frame.origin.y
                        + titleLabel.frame.size.height
                        + cardFieldsMarginTop,
                   cardImageView.frame.size.width,
                   cardImageView.frame.size.height);
    
    cardCvcImageView.frame =
        CGRectMake(paddingLeft,
                   cardImageView.frame.origin.y
                        + cardImageView.frame.size.height
                        + cardFieldsMarginTop,
                   cardCvcImageView.frame.size.width,
                   cardCvcImageView.frame.size.height);
    
    cardExpiryDateImageView.frame =
        CGRectMake(paddingLeft,
                   cardCvcImageView.frame.origin.y
                        + cardCvcImageView.frame.size.height
                        + cardFieldsMarginTop,
                   cardExpiryDateImageView.frame.size.width,
                   cardExpiryDateImageView.frame.size.height);
    
    
    self.cardNumberTextField.font = fieldsFont;
    self.cardNumberTextField.frame =
        CGRectMake(cardFieldsOriginX,
                   cardImageView.frame.origin.y,
                   cardFieldsWidth,
                   cardFieldsHeight);
    

    self.cardCvcTextField.font = fieldsFont;
    self.cardCvcTextField.frame =
        CGRectMake(cardFieldsOriginX,
                   cardCvcImageView.frame.origin.y,
                   cardFieldsWidth,
                   cardFieldsHeight);

}

#pragma mark - Gesture actions

- (void)scanCardTapped:(UITapGestureRecognizer *)recognizer
{
    CardIOPaymentViewController *scanViewController =
        [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.appToken = @"df4cb3fa0320437a9da7de5961888a3d";
    [self presentViewController:scanViewController animated:YES completion:nil];
}

#pragma mark - CardIOPaymentViewControllerDelegate

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo
             inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    // do something with cardInfo here
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

//
//  POSCardInputViewController.m
//  ShortcutPOS
//
//  Created by Christophe Maximin on 22/08/2014.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import "POSCardInputViewController.h"
#import "CardIO.h"
#import "BSKeyboardControls.h"

@interface POSCardInputViewController ()
    <
          UIPickerViewDelegate
        , UIPickerViewDataSource
        , UITextFieldDelegate
        , UITextViewDelegate
        , CardIOPaymentViewControllerDelegate
        , BSKeyboardControlsDelegate
    >

@property UITextField *cardNumberTextField;
@property UITextField *cardCvcTextField;
@property UITextField *cardExpirationDateTextField;
@property UIPickerView *cardExpirationDatePickerView;

@property NSNumber *selectedCardExpirationMonth;
@property NSNumber *selectedCardExpirationYear;

@property BSKeyboardControls *keyboardControls;

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

    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CardExpirationDate"]];
    imageView.tag = kCardExpirationDateImageViewTag;
    [self.view addSubview:imageView];
    
    // Text fields and buttons
    self.cardNumberTextField = [[UITextField alloc] init];
    self.cardNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardNumberTextField.placeholder = @"Card Number";
    self.cardNumberTextField.delegate = self;
    [self.view addSubview:self.cardNumberTextField];
    
    self.cardCvcTextField = [[UITextField alloc] init];
    self.cardCvcTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardCvcTextField.placeholder = @"CVC Number";
    self.cardCvcTextField.delegate = self;
    [self.view addSubview:self.cardCvcTextField];
    
    self.cardExpirationDateTextField = [[UITextField alloc] init];
    self.cardExpirationDateTextField.tag = kCardExpirationDateTextFieldTag;
    self.cardExpirationDateTextField.placeholder = @"Expiration Date";
    self.cardExpirationDateTextField.returnKeyType = UIReturnKeyDone;
    self.cardExpirationDateTextField.delegate = self;
    [self.view addSubview:self.cardExpirationDateTextField];

    self.cardExpirationDatePickerView = [[UIPickerView alloc] init];
    self.cardExpirationDatePickerView.tag = kCardExpirationDatePickerViewTag;
    self.cardExpirationDatePickerView.delegate = self;
    self.cardExpirationDatePickerView.dataSource = self;
    self.cardExpirationDatePickerView.showsSelectionIndicator = YES;
    self.cardExpirationDateTextField.inputView = self.cardExpirationDatePickerView;
    
    UIButton *scanCardButton = [[UIButton alloc] init];
    scanCardButton.tag = kScanCardButtonTag;
    [scanCardButton setTitle:@"SCAN CARD" forState:UIControlStateNormal];
    [scanCardButton addTarget:self
                               action:@selector(scanCardTapped:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanCardButton];

    // BSKeyboardControls
    [self setKeyboardControls:[[BSKeyboardControls alloc]
                               initWithFields:@[self.cardNumberTextField,
                                                self.cardCvcTextField,
                                                self.cardExpirationDateTextField]]];
    [self.keyboardControls setDelegate:self];

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
    UIImageView *cardExpirationDateImageView = (UIImageView *)[self.view viewWithTag:kCardExpirationDateImageViewTag];
    UIButton *scanCardButton = (UIButton *)[self.view viewWithTag:kScanCardButtonTag];
    
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
    
    cardExpirationDateImageView.frame =
        CGRectMake(paddingLeft,
                   cardCvcImageView.frame.origin.y
                        + cardCvcImageView.frame.size.height
                        + cardFieldsMarginTop,
                   cardExpirationDateImageView.frame.size.width,
                   cardExpirationDateImageView.frame.size.height);
    
    
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
    
    self.cardExpirationDateTextField.font = fieldsFont;
    self.cardExpirationDateTextField.frame =
        CGRectMake(cardFieldsOriginX,
                   cardExpirationDateImageView.frame.origin.y,
                   cardFieldsWidth,
                   cardFieldsHeight);
    
    [scanCardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    scanCardButton.titleLabel.font = [UIFont fontWithName:[POSConfiguration defaultFont]
                                                     size:14];
    scanCardButton.backgroundColor = [POSConfiguration colorFor:@"shortcut-purple"];
    [scanCardButton sizeToFit];
    scanCardButton.frame = CGRectInset(scanCardButton.frame, -10, 0);
    scanCardButton.frame = CGRectMake(self.view.frame.size.width
                                        - scanCardButton.frame.size.width
                                        - paddingRight,
                                      titleLabel.frame.origin.y,
                                      scanCardButton.frame.size.width,
                                      scanCardButton.frame.size.height);

}

- (void)viewDidAppear:(BOOL)animated
{
    
}

#pragma mark - UITapGestureRecognizer actions

- (void)scanCardTapped:(UITapGestureRecognizer *)recognizer
{
    CardIOPaymentViewController *scanViewController =
        [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.appToken = @"df4cb3fa0320437a9da7de5961888a3d";
    [self presentViewController:scanViewController animated:YES completion:nil];
}

#pragma mark - CardIO
#pragma mark CardIOPaymentViewControllerDelegate

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo
             inPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    self.cardNumberTextField.text = cardInfo.cardNumber;
    self.cardCvcTextField.text = cardInfo.cvv;
    self.selectedCardExpirationMonth = @(cardInfo.expiryMonth);
    self.selectedCardExpirationYear = @(cardInfo.expiryYear);
    self.cardExpirationDateTextField.text = [NSString stringWithFormat:@"%@/%@",
                                                 @(cardInfo.expiryMonth),
                                                 @(cardInfo.expiryYear)];

    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPicker
#pragma mark UIPicker actions

- (void)pickerDoneButtonPressed
{
    [self.view endEditing:YES];
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == kCardExpirationDatePickerViewTag) {
        return 2;
    }
    
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == kCardExpirationDatePickerViewTag) {
        if (component == 0) {
            return 12; // months
        } else {
            return 10; // years
        }
    }

    return 0;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (pickerView.tag == kCardExpirationDatePickerViewTag) {
        if (component == 0) {
            NSArray *monthsTitlesArray = @[@"01 - January", @"02 - February", @"03 - March",
                                           @"04 - April", @"05 - May", @"06 - June",
                                           @"07 - July", @"08 - August", @"09 - September",
                                           @"10 - October", @"11 - November", @"12 - December"];
            return monthsTitlesArray[row];
        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy"];
            NSInteger currentYear = [[dateFormatter stringFromDate:[NSDate date]] integerValue];
            return [NSString stringWithFormat:@"%li", (long)(currentYear + row)];
        }
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{

    if (pickerView.tag == kCardExpirationDatePickerViewTag) {
        if (component == 0) {
            self.selectedCardExpirationMonth = @(row + 1);
        } else {
            NSString *yearString = [self pickerView:self.cardExpirationDatePickerView
                                        titleForRow:row
                                       forComponent:1];
            self.selectedCardExpirationYear = @([yearString integerValue]);
        }

        if (!self.selectedCardExpirationMonth) {
            [self.cardExpirationDatePickerView selectRow:0 inComponent:0 animated:YES];
            // Default to January if no selection
            self.selectedCardExpirationMonth = @(1);
        }
        
        if (!self.selectedCardExpirationYear) {
            [self.cardExpirationDatePickerView selectRow:0 inComponent:1 animated:YES];
            NSString *yearString = [self pickerView:self.cardExpirationDatePickerView
                                        titleForRow:0
                                       forComponent:1];
            // Default to current year if no selection
            self.selectedCardExpirationYear = @([yearString integerValue]);
        }
        
        self.cardExpirationDateTextField.text = [NSString stringWithFormat:@"%@/%@",
                                                 self.selectedCardExpirationMonth,
                                                 self.selectedCardExpirationYear];
        self.cardExpirationDateTextField.textColor = [UIColor blackColor];
    }
}

#pragma mark - UITextField
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == kCardExpirationDateTextFieldTag) {
        // if the textfield is empty, we select the first rows of each component
        if (!textField.text || !textField.text.length) {
            [self pickerView:self.cardExpirationDatePickerView
                didSelectRow:0
                 inComponent:0];
            [self pickerView:self.cardExpirationDatePickerView
                didSelectRow:0
                 inComponent:1];
        }
    }
    
    [self.keyboardControls setActiveField:textField];

}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControls setActiveField:textView];
}

#pragma mark BSKeyboardDelegate

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [self.view endEditing:YES];
}

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls
           selectedField:(UIView *)field
             inDirection:(BSKeyboardControlsDirection)direction
{
    NSLog(@"xxxaaaaa");
}

@end

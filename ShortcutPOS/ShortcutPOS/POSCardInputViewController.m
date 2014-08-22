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
        , UIPickerViewDelegate
        , UIPickerViewDataSource
        , UITextFieldDelegate
    >

@property UITextField *cardNumberTextField;
@property UITextField *cardCvcTextField;
@property UITextField *cardExpirationDateTextField;
@property UIPickerView *cardExpirationDatePickerView;

@property NSNumber *selectedCardExpirationMonth;
@property NSNumber *selectedCardExpirationYear;

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
    
    // Text fields
    self.cardNumberTextField = [[UITextField alloc] init];
    self.cardNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardNumberTextField.placeholder = @"Card Number";
    [self.view addSubview:self.cardNumberTextField];
    
    self.cardCvcTextField = [[UITextField alloc] init];
    self.cardCvcTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.cardCvcTextField.placeholder = @"CVC Number";
    [self.view addSubview:self.cardCvcTextField];
    
    self.cardExpirationDateTextField = [[UITextField alloc] init];
    self.cardExpirationDateTextField.tag = kCardExpirationDateTextFieldTag;
    self.cardExpirationDateTextField.placeholder = @"Expiration Date";
    self.cardExpirationDateTextField.returnKeyType = UIReturnKeyDone;
    self.cardExpirationDateTextField.delegate = self;
    [self.view addSubview:self.cardExpirationDateTextField];
    
    [self setExpirationDatePickerView];
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
    // do something with cardInfo here
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPicker
#pragma mark UIPicker actions

- (void)setExpirationDatePickerView
{
    // Set picker view
    self.cardExpirationDatePickerView = [[UIPickerView alloc] init];
    self.cardExpirationDatePickerView.tag = kCardExpirationDatePickerViewTag;
    self.cardExpirationDatePickerView.delegate = self;
    self.cardExpirationDatePickerView.dataSource = self;
    self.cardExpirationDatePickerView.showsSelectionIndicator = YES;
    

    // Create and configure toolbar that holds "Done button"
    UIToolbar *pickerToolbar = [[UIToolbar alloc] init];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    [pickerToolbar sizeToFit];

    UIBarButtonItem *flexibleSpaceLeft =
        [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                 target:nil
                                 action:nil];

    UIBarButtonItem *doneButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(pickerDoneButtonPressed)];
    
    [doneButton setTintColor:[UIColor whiteColor]];
    [pickerToolbar setItems:[NSArray arrayWithObjects:flexibleSpaceLeft, doneButton, nil]];
    
    
    // Creating a view wrapper holding the toolbar and the picker
    UIView *pickerViewWrapper = [[UIView alloc] init];
    pickerViewWrapper.tag = kCardExpirationDateTextFieldInputViewTag;
    [pickerViewWrapper addSubview:pickerToolbar];
    [pickerViewWrapper addSubview:self.cardExpirationDatePickerView];
    
    // moving the picker down the height of the toolbar
    CGRect pickerViewFrame = self.cardExpirationDatePickerView.frame;
    pickerViewFrame.origin.y = pickerToolbar.frame.size.height;
    self.cardExpirationDatePickerView.frame = pickerViewFrame;
    
    pickerViewWrapper.frame = CGRectMake(0, 0,
                                         self.cardExpirationDatePickerView.frame.size.width,
                                         pickerViewFrame.origin.y + pickerViewFrame.size.height);
    
    self.cardExpirationDateTextField.inputView = pickerViewWrapper;
}

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
}

@end

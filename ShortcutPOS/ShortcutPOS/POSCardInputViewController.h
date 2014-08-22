//
//  POSCardInputViewController.h
//  ShortcutPOS
//
//  Created by Christophe Maximin on 22/08/2014.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POSCardInputViewController : UIViewController

@end

typedef NS_ENUM(NSInteger, POSCardInputTags) {
    kTitleLabelTag = 100,
    kCardImageViewTag,
    kCardCvcImageViewTag,
    kCardExpirationDateImageViewTag,
    kCardNumberTextFieldTag,
    kCardCvcTextFieldTag,
    kCardExpirationDateTextFieldTag,
    kCardExpirationDatePickerViewTag,
    kCardExpirationDateTextFieldInputViewTag,
    kScanCardButtonTag,
};
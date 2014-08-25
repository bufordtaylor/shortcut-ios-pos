//
//  POSCardInputViewController.h
//  ShortcutPOS
//
//  Created by Christophe Maximin on 22/08/2014.
//  Copyright (c) 2014 Shortcut. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol POSCardInputViewControllerDelegate <NSObject>

- (void)setStripeTokenId:(NSString *)stripeTokenId;

@end

@interface POSCardInputViewController : UIViewController

@property (weak) id<POSCardInputViewControllerDelegate> delegate;

- (void)cancelButtonTapped:(UITapGestureRecognizer *)recognizer;
- (void)doneButtonTapped:(UITapGestureRecognizer *)recognizer;

@end

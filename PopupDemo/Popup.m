//
//  Popup.m
//  PopupDemo
//
//  Created by Mark Miscavage on 4/16/15.
//  Copyright (c) 2015 Mark Miscavage. All rights reserved.
//

#import "Popup.h"


static const CGFloat kPopupTitleFontSize = 30;
static const CGFloat kPopupSubTitleFontSize = 15;

#define SwipeVertical @"VERTICAL"
#define SwipeHorizontal @"HORIZONTAL"

#define FlatWhiteColor [UIColor colorWithRed:0.937 green:0.945 blue:0.961 alpha:1] /*#eff1f5*/
#define FlatWhiteDarkColor [UIColor colorWithRed:0.875 green:0.882 blue:0.91 alpha:1] /*#dfe1e8*/
#define FlatBlackColor [UIColor colorWithRed:0.204 green:0.239 blue:0.275 alpha:1] /*#343d46*/

CGFloat currentKeyboardHeight = 0.0f;
CGFloat popupDimension = 300.0f;

BOOL isBlurSet = YES;

@interface Popup () <UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate /*For swiping to dimiss*/> {
    
    UIView *backgroundView;
    UIView *popupView;
    
    UIScreen *mainScreen;
    
    blocky pSuccessBlock;
    blocky pCancelBlock;
    
    PopupBackGroundBlurType popupBlurType;
    
    PopupIncomingTransitionType incomingTransitionType;
    PopupOutgoingTransitionType outgoingTransitionType;
    
    NSString *pTitle;
    NSString *pSubTitle;
    
    NSArray *pTextFieldPlaceholderArray;
    NSArray *pTextFieldArray;
    
    NSString *pCancelTitle;
    NSString *pSuccessTitle;
    
    UIButton *successBtn;
    UIButton *cancelBtn;
    
    UILabel *titleLabel;
    UILabel *subTitleLabel;
    
    NSMutableArray *panHolder;

}

@end
@implementation Popup

#pragma mark Instance Types

- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                  cancelTitle:(NSString *)cancelTitle
                 successTitle:(NSString *)successTitle {
    
    if ([super init]) {
        pTitle = title;
        pSubTitle = subTitle;
        pCancelTitle = cancelTitle;
        pSuccessTitle = successTitle;
        
        [self formulateEverything];
    }
    
    return self;

}

- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
        textFieldPlaceholders:(NSArray *)textFieldPlaceholderArray
                  cancelTitle:(NSString *)cancelTitle
                 successTitle:(NSString *)successTitle
                  cancelBlock:(blocky)cancelBlock
                 successBlock:(blocky)successBlock {
    
    if ([super init]) {
        pTitle = title;
        pSubTitle = subTitle;
        pTextFieldPlaceholderArray = textFieldPlaceholderArray;
        pCancelTitle = cancelTitle;
        pSuccessTitle = successTitle;
        pCancelBlock = cancelBlock;
        pSuccessBlock = successBlock;
        
        [self formulateEverything];
    }
    
    return self;
    
}


- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                  cancelTitle:(NSString *)cancelTitle
                 successTitle:(NSString *)successTitle
                  cancelBlock:(blocky)cancelBlock
                 successBlock:(blocky)successBlock {
    
    if ([super init]) {
        pTitle = title;
        pSubTitle = subTitle;
        pSuccessBlock = successBlock;
        pCancelTitle = cancelTitle;
        pSuccessTitle = successTitle;
        pCancelBlock = cancelBlock;
        
        [self formulateEverything];
    }
    
    return self;
    
}

#pragma mark Creation Methods

- (void)formulateEverything {

    mainScreen =  [UIScreen mainScreen];
    
    [self setFrame:mainScreen.bounds];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:YES];
    
    [self makeAlertPopupView];
    
    [self setupTitle];
    [self setupSubtitle];
    [self setupTextFields];
    [self setupButtons];
    
}

- (void)blurBackgroundWithType:(PopupBackGroundBlurType)blurType {
    
    UIVisualEffect *blurEffect;

    switch (blurType) {
        case PopupBackGroundBlurTypeDark:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            break;
        case PopupBackGroundBlurTypeExtraLight:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            break;
        case PopupBackGroundBlurTypeLight:
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            break;
        case PopupBackGroundBlurTypeNone:
            return;
            break;
        default:
            break;
    }
    
    backgroundView = [[UIView alloc] initWithFrame:mainScreen.bounds];

    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [visualEffectView setFrame:backgroundView.bounds];
    [backgroundView addSubview:visualEffectView];
    
    [backgroundView setAlpha:0.0];
    
    [self insertSubview:backgroundView belowSubview:popupView];
    
}

- (void)makeAlertPopupView {
    
    CGRect rect = CGRectMake(mainScreen.bounds.size.width/2 - 150, mainScreen.bounds.size.height/2 - 150, 300, 300);
    
    popupView = [[UIView alloc] initWithFrame:rect];
    
    [popupView setBackgroundColor:FlatWhiteColor];
    [popupView.layer setMasksToBounds:YES];
    [popupView.layer setCornerRadius:8.0];
    [popupView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [popupView.layer setBorderWidth:1.0];
    
    [self addSubview:popupView];
    
}

#pragma mark Accessor Methods

- (void)setBackgroundBlurType:(PopupBackGroundBlurType)backgroundBlurType {
    [self blurBackgroundWithType:backgroundBlurType];
}

- (void)setIncomingTransition:(PopupIncomingTransitionType)incomingTransition {
    incomingTransitionType = incomingTransition;
}

- (void)setOutgoingTransition:(PopupOutgoingTransitionType)outgoingTransition {
    outgoingTransitionType = outgoingTransition;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [popupView setBackgroundColor:backgroundColor];
}

- (void)setBorderColor:(UIColor *)borderColor {
    [popupView.layer setBorderColor:borderColor.CGColor];
    [popupView.layer setBorderWidth:1.0];
}

- (void)setTitleColor:(UIColor *)titleColor {
    [titleLabel setTextColor:titleColor];
}

- (void)setSubTitleColor:(UIColor *)subTitleColor {
    [subTitleLabel setTextColor:subTitleColor];
}

- (void)setSuccessBtnColor:(UIColor *)successBtnColor {
    [successBtn setBackgroundColor:successBtnColor];
}

- (void)setSuccessTitleColor:(UIColor *)successTitleColor {
    [successBtn setTitleColor:successTitleColor forState:UIControlStateNormal];
}

- (void)setCancelBtnColor:(UIColor *)cancelBtnColor {
    [cancelBtn setBackgroundColor:cancelBtnColor];
}

- (void)setCancelTitleColor:(UIColor *)cancelTitleColor {
    [cancelBtn setTitleColor:cancelTitleColor forState:UIControlStateNormal];
}

- (void)setRoundedCorners:(BOOL)roundedCorners {
    if (roundedCorners) {
        [popupView.layer setMasksToBounds:YES];
        [popupView.layer setCornerRadius:8.0];
    }
    else {
        [popupView.layer setMasksToBounds:YES];
        [popupView.layer setCornerRadius:0.0];
    }
}

- (void)setOverallKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
 
    for (int i = 0; i < [pTextFieldArray count]; i++) {
        UITextField *textField = pTextFieldArray[i];
        [textField setKeyboardAppearance:keyboardAppearance];
    }
    
}

- (void)setTapBackgroundToDismiss:(BOOL)tapBackgroundToDismiss {

    if (tapBackgroundToDismiss) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup:)];
        [tap setNumberOfTapsRequired:1];
        [backgroundView addGestureRecognizer:tap];
    }
    
}

- (void)setSwipeToDismiss:(BOOL)swipeToDismiss {

    if (swipeToDismiss) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [pan setDelegate:self];
        [pan setMinimumNumberOfTouches:1];
        [pan setMaximumNumberOfTouches:1];
        [popupView addGestureRecognizer:pan];
        
        if (!panHolder) {
            panHolder = [NSMutableArray array];
        }
    }
    
}

#pragma mark Setup Methods

- (void)setupTitle {
    
    if (pTitle) {
        
        if (!titleLabel) {
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, popupView.frame.size.width - 16, 40)];
            [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:kPopupTitleFontSize]];
            [titleLabel setAdjustsFontSizeToFitWidth:YES];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            [titleLabel setTextColor:[UIColor colorWithRed:0.329 green:0.396 blue:0.584 alpha:1] /*#546595*/];
        }
        
        [titleLabel setText:pTitle];

        [popupView addSubview:titleLabel];
    }
    
}

- (void)setupSubtitle {
    
    if (pSubTitle) {
        
        int titleLabelHeight = titleLabel.frame.size.height;

        if (!subTitleLabel) {
            subTitleLabel = [[UILabel alloc] init];
            [subTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:kPopupSubTitleFontSize]];
            [subTitleLabel setAdjustsFontSizeToFitWidth:YES];
            [subTitleLabel setTextAlignment:NSTextAlignmentCenter];
            [subTitleLabel setTextColor:[UIColor colorWithRed:0.408 green:0.478 blue:0.682 alpha:1] /*#687aae*/];
            [subTitleLabel setNumberOfLines:20];
        }
        
        //Adjust the subtitle frame if there are textfields present
        if ([pTextFieldPlaceholderArray count] == 0) {
            [subTitleLabel setFrame:CGRectMake(8, titleLabelHeight + 16, popupView.frame.size.width - 16, popupView.frame.size.height - 16 - 40 - (titleLabelHeight + 16))];
        }
        else {
            int textfieldHeight = 28;
            int buttonHeight = 40;

            if ([pTextFieldPlaceholderArray count] == 1) {
                [subTitleLabel setFrame:CGRectMake(8, titleLabelHeight + 16, popupView.frame.size.width - 16, popupView.frame.size.height - 16 - buttonHeight - (textfieldHeight * 2.65) - (8 * 2.65) - (titleLabelHeight + 16))];
            }
            else if ([pTextFieldPlaceholderArray count] == 2) {
                [subTitleLabel setFrame:CGRectMake(8, titleLabelHeight + 16, popupView.frame.size.width - 16, popupView.frame.size.height - 16 - buttonHeight - (textfieldHeight * 2.75) - (8 * 2.75) - (titleLabelHeight + 16))];
            }
            else if ([pTextFieldPlaceholderArray count] == 3) {
                [subTitleLabel setFrame:CGRectMake(8, titleLabelHeight + 16, popupView.frame.size.width - 16, popupView.frame.size.height - 16 - buttonHeight - (textfieldHeight * 3.5) - (8 * 3.5) - (titleLabelHeight + 16))];
            }
        }
        
        [subTitleLabel setText:pSubTitle];
        
        [popupView addSubview:subTitleLabel];
    }
    
}

- (void)setupTextFields {

    if (pTextFieldPlaceholderArray) {
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboards)];
        [tap setNumberOfTapsRequired:1];
        [tap setDelegate:self];
        [popupView addGestureRecognizer:tap];
        
        [self setKeyboardNotifications];
        
        int titleHeights = titleLabel.frame.size.height + subTitleLabel.frame.size.height;
        int textFieldHeight = 28;
        
        static UITextField *textField1 = nil;
        static UITextField *textField2 = nil;
        static UITextField *textField3 = nil;
        
        
        for (int i = 0; i < [pTextFieldPlaceholderArray count]; i++) {
            if (i == 0) {
                textField1 = [self textFieldWithPlaceholder:pTextFieldPlaceholderArray[i] numberOfField:1];
            }
            else if (i == 1) {
                textField2 = [self textFieldWithPlaceholder:pTextFieldPlaceholderArray[i] numberOfField:2];
            }
            else if (i == 2) {
                textField3 = [self textFieldWithPlaceholder:pTextFieldPlaceholderArray[i] numberOfField:3];
            }
            else {
                NSException *exception = [NSException
                                          exceptionWithName:@"Array exceeds limit."
                                          reason:@"Popups can only have at most 3 fields! TextFieldPlaceholderArray exceeds this limit. ¯|_(ツ)_/¯ "
                                          userInfo:nil];
                
                @throw exception;
            }
        }
        
        if ([pTextFieldPlaceholderArray count] == 1) {
            [textField1 setFrame:CGRectMake(8, titleHeights + 24, popupView.frame.size.width - 16, textFieldHeight)];
            
            pTextFieldArray = @[textField1];
            
            [popupView addSubview:textField1];
        }
        else if ([pTextFieldPlaceholderArray count] == 2) {
            [textField1 setFrame:CGRectMake(8, titleHeights + 24, popupView.frame.size.width - 16, textFieldHeight)];
            
            [textField2 setFrame:CGRectMake(8, titleHeights + textFieldHeight + 32, popupView.frame.size.width - 16, textFieldHeight)];
            
            pTextFieldArray = @[textField1, textField2];
            
            [popupView addSubview:textField1];
            [popupView addSubview:textField2];
        }
        else if ([pTextFieldPlaceholderArray count] == 3) {
            [textField1 setFrame:CGRectMake(8, titleHeights + 24, popupView.frame.size.width - 16, textFieldHeight)];
            
            [textField2 setFrame:CGRectMake(8, titleHeights + textFieldHeight + 32, popupView.frame.size.width - 16, textFieldHeight)];
            
            [textField3 setFrame:CGRectMake(8, titleHeights + (textFieldHeight * 2) + 40, popupView.frame.size.width - 16, textFieldHeight)];
            
            pTextFieldArray = @[textField1, textField2, textField3];
            
            [popupView addSubview:textField1];
            [popupView addSubview:textField2];
            [popupView addSubview:textField3];
        }
        
    }
    
}

- (void)setupButtons {

    if (pCancelTitle) {
        
        if (!cancelBtn) {
            cancelBtn = [[UIButton alloc] init];
            [cancelBtn setTitleColor:FlatWhiteDarkColor forState:UIControlStateNormal];
            [cancelBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
            [cancelBtn setBackgroundColor:[UIColor colorWithRed:0.91 green:0.184 blue:0.184 alpha:1] /*#e82f2f*/];
            [cancelBtn addTarget:self action:@selector(pressAlertButton:) forControlEvents:UIControlEventTouchUpInside];
            [cancelBtn.layer setCornerRadius:6.0];
            [cancelBtn.layer setMasksToBounds:YES];
        }
        
        //Change the frame to expand the whole width of Popup if there's no successBtn
        if (!pSuccessTitle) {
            [cancelBtn setFrame:CGRectMake(8, popupView.frame.size.height - 48, popupView.frame.size.width - 16, 40)];
        }
        else {
            [cancelBtn setFrame:CGRectMake(8, popupView.frame.size.height - 48, popupView.frame.size.width/2 - 12, 40)];
        }
        
        [cancelBtn setTitle:pCancelTitle forState:UIControlStateNormal];
        
        [popupView addSubview:cancelBtn];
        
    }
    if (pSuccessTitle) {
        
        if (!successBtn) {
            successBtn = [[UIButton alloc] init];
            [successBtn setTitleColor:FlatWhiteDarkColor forState:UIControlStateNormal];
            [successBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
            [successBtn setBackgroundColor:[UIColor colorWithRed:0.408 green:0.478 blue:0.682 alpha:1] /*#687aae*/];
            [successBtn addTarget:self action:@selector(pressAlertButton:) forControlEvents:UIControlEventTouchUpInside];
            [successBtn.layer setCornerRadius:6.0];
            [successBtn.layer setMasksToBounds:YES];
        }
        
        //Change the frame to expand the whole width of Popup if there's no cancelBtn
        if (!pCancelTitle) {
            [successBtn setFrame:CGRectMake(8, popupView.frame.size.height - 48, popupView.frame.size.width - 16, 40)];
        }
        else {
            [successBtn setFrame:CGRectMake(popupView.frame.size.width/2 + 4, popupView.frame.size.height - 48, popupView.frame.size.width/2 - 12, 40)];
        }
        
        [successBtn setTitle:pSuccessTitle forState:UIControlStateNormal];
        
        [popupView addSubview:successBtn];
        
    }
    
    
}

#pragma mark Presentation Methods

- (void)showPopup {
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    [window addSubview:self];
    
    if( [self.delegate respondsToSelector:@selector(popupWillAppear:)] ) {
        [self.delegate popupWillAppear:self];
    }
    
    [self showAnimation];
}

- (void)showAnimation {
    
    [UIView animateWithDuration:0.1 animations:^{
        [backgroundView setAlpha:1.0];
    }];
    
    if (incomingTransitionType) {
        [self configureIncomingAnimationFor:incomingTransitionType];
    }
    else {
        [self configureIncomingAnimationFor:PopupIncomingTransitionTypeAppearCenter];
    }
}

#pragma mark Dismissing Methods

- (void)dismissPopup:(PopupButtonType)buttonType {
    
    if (buttonType != PopupButtonSuccess && buttonType != PopupButtonCancel) {
        //For tapping and swiping to dismiss
        buttonType = PopupButtonCancel;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(popupWillDisappear:buttonType:)] ) {
        [self.delegate popupWillDisappear:self buttonType:buttonType];
    }
    
    if (outgoingTransitionType) {
        [self configureOutgoingAnimationFor:outgoingTransitionType withButtonType:buttonType];
    }
    else {
        [self configureOutgoingAnimationFor:PopupOutgoingTransitionTypeDisappearCenter withButtonType:buttonType];
    }

}

#pragma mark Button Methods

- (void)pressAlertButton:(id)sender {
    
    [self dismissKeyboards];

    UIButton *button = (UIButton *)sender;
    
    PopupButtonType buttonType;
    
    BOOL isBlock = false;
    
    if ([button isEqual:successBtn]) {
        NSLog(@"Success!");
        
        buttonType = PopupButtonSuccess;
        if (pSuccessBlock) isBlock = true;
    }
    else {
        NSLog(@"Cancel!");
        
        buttonType = PopupButtonCancel;
        if (pCancelBlock) isBlock = true;
    }
    
    if (!isBlock && [self.delegate respondsToSelector:@selector(popupPressButton:buttonType:)]) {
        [self.delegate popupPressButton:self buttonType:buttonType];
    }
    
    if (self.delegate && [pTextFieldPlaceholderArray count] > 0 && [self.delegate respondsToSelector:@selector(dictionary:forpopup:stringsFromTextFields:)]) {
        [self.delegate dictionary:[self createDictionaryForTextfields] forpopup:self stringsFromTextFields:[self arrayForStringOfTextfields]];
    }
    
    [self dismissPopup:buttonType];
    
}

#pragma mark UIPanGestureRecognizer Methods

- (void)panFired:(id)sender {
    
    //Make sure this delegate method only gets called once
    static int i = 1;
    if (i == 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(popupWillDisappear:buttonType:)] ) {
            [self.delegate popupWillDisappear:self buttonType:PopupButtonCancel];
            i = 0;
        }
    }
    
    UIPanGestureRecognizer *panRecog = (UIPanGestureRecognizer *)sender;
    CGPoint vel = [panRecog velocityInView:popupView];
    
    UIView *recogView = [panRecog view];
    
    CGPoint translation = [panRecog translationInView:popupView];
    CGFloat curY = popupView.frame.origin.y;
    
    [self endEditing:YES];
    
    if (panRecog.state == UIGestureRecognizerStateChanged) {
        //drag view vertially
        CGRect frame = popupView.frame;
        frame.origin.y = curY + translation.y;
        recogView.frame = frame;
        [panRecog setTranslation:CGPointMake(0.0f, 0.0f) inView:popupView];
    }
    else if (panRecog.state == UIGestureRecognizerStateEnded) {
        
        CGFloat finalX = popupView.frame.origin.x;
        CGFloat finalY = 50.0f;
        CGFloat curY = popupView.frame.origin.y;
        
        CGFloat distance = curY - finalY;
        
        //Normalize velocity
        //Multiply by -1 in this case since final desitination y < curY
        //and recog's y velocity is negative when draggin up
        //(therefore also works when released when dragging down)
        CGFloat springVelocity = -1.0f * vel.y / distance;
        
        //If the springVelocity is really slow, speed it up a bit
        if (springVelocity > 1.5f) {
            springVelocity = -1.5f;
        }
        
        [UIView animateWithDuration:springVelocity delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            CGRect frame = popupView.frame;
            frame.origin.x = finalX;
            frame.origin.y = finalY;
            popupView.frame = frame;
            
            [backgroundView setAlpha:0.0];
            if (curY > 115.1) {
                [UIView animateWithDuration:0.1 animations:^{
                    popupView.frame = CGRectMake(30, 600, 300, 300);
                } completion:^(BOOL finished) {
                    popupView.alpha = 0.0;
                }];
            }
            else {
                [UIView animateWithDuration:0.1 animations:^{
                    popupView.frame = CGRectMake(30, -400, 300, 300);
                } completion:^(BOOL finished) {
                    popupView.alpha = 0.0;
                }];
            }
            
        } completion:^(BOOL finished) {
            [self endWithButtonType:PopupButtonCancel];
        }];
 
    }
}

#pragma mark Textfield Getter Methods

- (NSMutableDictionary *)createDictionaryForTextfields {
    
    static NSMutableDictionary *dictionary = nil;
    
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc] init];
    }
    
    for (int i = 0; i < [pTextFieldArray count]; i++) {
        if (i == 0) {
            UITextField *textField1 = pTextFieldArray[i];
            
            [dictionary setObject:textField1.text forKey:pTextFieldPlaceholderArray[i]];
        }
        else if (i == 1) {
            UITextField *textField2 = pTextFieldArray[i];
            
            [dictionary setObject:textField2.text forKey:pTextFieldPlaceholderArray[i]];
        }
        else if (i == 2) {
            UITextField *textField3 = pTextFieldArray[i];
            
            [dictionary setObject:textField3.text forKey:pTextFieldPlaceholderArray[i]];
        }
    }
    
    return dictionary;
    
}

- (NSArray *)arrayForStringOfTextfields {
    
    NSString *textField1String = nil;
    NSString *textField2String = nil;
    NSString *textField3String = nil;
    
    
    for (int i = 0; i < [pTextFieldArray count]; i++) {
        if (i == 0) {
            UITextField *textField1 = pTextFieldArray[i];
            textField1String = textField1.text;
        }
        else if (i == 1) {
            UITextField *textField2 = pTextFieldArray[i];
            textField2String = textField2.text;
        }
        else if (i == 2) {
            UITextField *textField3 = pTextFieldArray[i];
            textField3String = textField3.text;
        }
        else {
            NSException *exception = [NSException
                                      exceptionWithName:@"Array exceeds limit."
                                      reason:@"Popups can only have at most 3 fields, TextFieldArray exceeds this limit."
                                      userInfo:nil];
            
            @throw exception;
        }
    }
    
    if ([pTextFieldPlaceholderArray count] == 1) {
        return @[textField1String];
    }
    else if ([pTextFieldPlaceholderArray count] == 2) {
        return @[textField1String, textField2String];
    }
    else if ([pTextFieldPlaceholderArray count] == 3) {
        return @[textField1String, textField2String, textField3String];
    }
    else return nil;
    
    
}

#pragma mark UITextField Methods

- (void)setTextFieldTypeForTextFields:(NSArray *)textFieldTypeArray {
    
    NSArray *canBeArray = @[@"",
                            @"DEFAULT",
                            @"PASSWORD"];
    
    int counter = 0;

    for (NSString *type in textFieldTypeArray) {
        if ([type isKindOfClass:[NSString class]]) {
            if ([canBeArray containsObject:type]) {
                if ([type isEqualToString:@"PASSWORD"]) {
                    if (counter < 3) {
                        
                        UITextField *field = pTextFieldArray[counter];
                        [field setSecureTextEntry:YES];
                    
                    }
                    else {
                        NSException *exception = [NSException
                                                  exceptionWithName:@"Array exceeds limit."
                                                  reason:@"Popups can only have at most 3 fields, TextFieldTypeArray exceeds this limit."
                                                  userInfo:nil];
                        
                        @throw exception;
                    }
                }
            }
            else {
                NSString *canBeString = [canBeArray componentsJoinedByString:@", "];
                
                NSException *exception = [NSException
                                          exceptionWithName:@"Not a valid textfield type."
                                          reason:[NSString stringWithFormat:@"TextField type needs to be of type NSString and either: %@", canBeString]
                                          userInfo:nil];
                @throw exception;
            }
        }
        else {
            NSException *exception = [NSException
                                      exceptionWithName:@"Not a valid textfield class type."
                                      reason:@"TextField type needs to be of type NSString."
                                      userInfo:nil];
            @throw exception;
        }
        
        counter ++;
        
    }
    
    
}

- (void)setKeyboardTypeForTextFields:(NSArray *)keyboardTypeArray {
    
    NSArray *canBeArray = @[@"",
                            @"DEFAULT",
                            @"ASCIICAPABLE",
                            @"NUMBERSANDPUNCTUATION",
                            @"URL",
                            @"NUMBER",
                            @"PHONE",
                            @"NAMEPHONE",
                            @"EMAIL",
                            @"DECIMAL",
                            @"TWITTER",
                            @"WEBSEARCH"];
    
    int counter = 0;

    for (NSString *type in keyboardTypeArray) {
        if ([type isKindOfClass:[NSString class]]) {
            if ([canBeArray containsObject:type]) {
                if (counter < 3) {
                    UITextField *field = pTextFieldArray[counter];
                    [field setKeyboardType:[self getKeyboardTypeFromString:type]];
                }
                else {
                    NSException *exception = [NSException
                                              exceptionWithName:@"Array exceeds limit."
                                              reason:@"Popups can only have at most 3 fields, KeyboardTypeArray exceeds this limit."
                                              userInfo:nil];
                
                    @throw exception;
                }
            }
            else {
                NSString *canBeString = [canBeArray componentsJoinedByString:@", "];

                NSException *exception = [NSException
                                            exceptionWithName:@"Not a valid textfield type."
                                            reason:[NSString stringWithFormat:@"Keyboard type needs to be of type NSString and either: %@", canBeString]
                                            userInfo:nil];
                @throw exception;
            }
        }
        else {
            NSException *exception = [NSException
                                        exceptionWithName:@"Not a valid textfield class type."
                                        reason:@"Keyboard type needs to be of type NSString."
                                        userInfo:nil];
            @throw exception;
        }
        counter ++;
    }
    
    
}

- (UIKeyboardType)getKeyboardTypeFromString:(NSString *)string {
    
    UIKeyboardType keyboardType;

    if ([string isEqualToString:@""]) {
        keyboardType = UIKeyboardTypeDefault;
    }
    else if ([string isEqualToString:@"DEFAULT"]) {
        keyboardType = UIKeyboardTypeDefault;
    }
    else if ([string isEqualToString:@"ASCIICAPABLE"]) {
        keyboardType = UIKeyboardTypeASCIICapable;
    }
    else if ([string isEqualToString:@"NUMBERSANDPUNCTUATION"]) {
        keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    else if ([string isEqualToString:@"URL"]) {
        keyboardType = UIKeyboardTypeURL;
    }
    else if ([string isEqualToString:@"NUMBER"]) {
        keyboardType = UIKeyboardTypeNumberPad;
    }
    else if ([string isEqualToString:@"PHONE"]) {
        keyboardType = UIKeyboardTypePhonePad;
    }
    else if ([string isEqualToString:@"NAMEPHONE"]) {
        keyboardType = UIKeyboardTypeNamePhonePad;
    }
    else if ([string isEqualToString:@"EMAIL"]) {
        keyboardType = UIKeyboardTypeEmailAddress;
    }
    else if ([string isEqualToString:@"DECIMAL"]) {
        keyboardType = UIKeyboardTypeDecimalPad;
    }
    else if ([string isEqualToString:@"TWITTER"]) {
        keyboardType = UIKeyboardTypeTwitter;
    }
    else if ([string isEqualToString:@"WEBSEARCH"]) {
        keyboardType = UIKeyboardTypeWebSearch;
    }
    else {
        keyboardType = UIKeyboardTypeDefault;
    }
    
    return keyboardType;
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholderText numberOfField:(int)num {
    
    UITextField *textField;
    textField = [[UITextField alloc] init];
    [textField setKeyboardType:UIKeyboardTypeDefault];
    [textField setBorderStyle:UITextBorderStyleNone];
    [textField setDelegate:self];
    [textField setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    [textField setTextColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9]];
    [textField setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
    [textField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [textField setTag:num];
    [textField setPlaceholder:placeholderText];
    [textField.layer setBorderColor:[UIColor colorWithWhite:0.8 alpha:1.0].CGColor];
    [textField.layer setBorderWidth:1.0];
    [textField.layer setCornerRadius:4.0];
    [textField.layer setMasksToBounds:YES];
    
    if (num == [pTextFieldPlaceholderArray count]) {
        [textField setReturnKeyType:UIReturnKeyDone];
    }
    else {
        [textField setReturnKeyType:UIReturnKeyNext];
    }
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    [textField setLeftView:paddingView];
    [textField setLeftViewMode:UITextFieldViewModeAlways];
    
    return textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField tag] == [pTextFieldPlaceholderArray count]) {
        [self dismissKeyboards];
    }
    else {
        UITextField *fieldAddOne = (UITextField *)[self viewWithTag:[textField tag]+1];
        
        if ([textField tag] == 1) {
            [textField resignFirstResponder];
            [fieldAddOne becomeFirstResponder];
        }
        else if ([textField tag] == 2) {
            [textField resignFirstResponder];
            [fieldAddOne becomeFirstResponder];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self setPopupFrameForTextField:(int)[textField tag]];
    
    return YES;
}

- (void)setPopupFrameForTextField:(int)num {
    
    currentKeyboardHeight = 216;
    
    //Integrate for iPhone 4, 5, 6, 6+ screen sizes
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        //If is iPhone4
        [UIView animateWithDuration:0.2 animations:^{
            [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - 150, mainScreen.bounds.size.height/2 - currentKeyboardHeight - 70, 300, 300)];
        }];
    }
    else if ([UIScreen mainScreen].bounds.size.height == 568) {
        //If is iPhone5
        [UIView animateWithDuration:0.2 animations:^{
            [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - 150, mainScreen.bounds.size.height/2 - currentKeyboardHeight - 30, 300, 300)];
        }];
    }
    else if ([UIScreen mainScreen].bounds.size.height > 568) {
        //If is iPhone6, 6+
        [UIView animateWithDuration:0.2 animations:^{
            [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - 150, mainScreen.bounds.size.height/2 - currentKeyboardHeight, 300, 300)];
        }];
    }
}

- (void)dismissKeyboards {
    //Dismiss all and any keyboards
    [self endEditing:YES];
    
    //Reset the frame of Popup
    [UIView animateWithDuration:0.2 animations:^{
        [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - 150, mainScreen.bounds.size.height/2 - 150, 300, 300)];
    }];
}

#pragma mark Keyboard Methods

- (void)setKeyboardNotifications {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
}

- (void)keyboardWillShow:(NSNotification*)notification {
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    currentKeyboardHeight = kbSize.height;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Transition Methods

- (void)configureIncomingAnimationFor:(PopupIncomingTransitionType)trannyType {

    CGRect mainRect = CGRectMake(mainScreen.bounds.size.width/2 - 150, mainScreen.bounds.size.height/2 - 150, 300, 300);
    
    switch (trannyType) {
        case PopupIncomingTransitionTypeBounceFromCenter: {

            popupView.transform = CGAffineTransformMakeScale(0.4, 0.4);

            [UIView animateWithDuration:0.35 delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:1.0 options:UIViewAnimationOptionTransitionNone animations:^{
                popupView.transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeSlideFromLeft: {
            
            [popupView setFrame:CGRectMake(-300, mainScreen.bounds.size.height/2 - 150, 300, 300)];
            
            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:mainRect];

            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            
            break;
        }
        case PopupIncomingTransitionTypeSlideFromTop: {
            
            [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - 150, -300, 300, 300)];
            
            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:mainRect];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeSlideFromBottom: {
            
            [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - 150, mainScreen.bounds.size.height+300, 300, 300)];
            
            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:mainRect];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeSlideFromRight: {
            
            [popupView setFrame:CGRectMake(mainScreen.bounds.size.width + 300, mainScreen.bounds.size.height/2 - 150, 300, 300)];
            
            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:mainRect];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeEaseFromCenter: {
            
            [popupView setAlpha:0.0];
            popupView.transform = CGAffineTransformMakeScale(0.75, 0.75);
            
            [UIView animateWithDuration:0.25 animations:^{
                popupView.transform = CGAffineTransformIdentity;
                [popupView setAlpha:1.0];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeAppearCenter: {
            
            [popupView setAlpha:0.0];
            
            [UIView animateWithDuration:0.05 animations:^{
                [popupView setAlpha:1.0];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeFallWithGravity: {
            
            [popupView setFrame:CGRectMake(mainScreen.bounds.size.width/2 - 150, -300, 300, 300)];
            
            [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionNone animations:^{
                [popupView setFrame:mainRect];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
    
            break;
        }
        case PopupIncomingTransitionTypeGhostAppear: {
            
            [popupView setAlpha:0.0];
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^ {
                [popupView setAlpha:1.0];

            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        case PopupIncomingTransitionTypeShrinkAppear: {

            [popupView setAlpha:0.0];
            popupView.transform = CGAffineTransformMakeScale(1.25, 1.25);
            
            [UIView animateWithDuration:0.25 animations:^{
                popupView.transform = CGAffineTransformIdentity;
                [popupView setAlpha:1.0];
                
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(popupDidAppear:)]) {
                    [self.delegate popupDidAppear:self];
                }
            }];
            
            break;
        }
        default: {
            break;
        }
    }

}

- (void)configureOutgoingAnimationFor:(PopupOutgoingTransitionType)trannyType withButtonType:(PopupButtonType)buttonType {
    
    //Make the blur/background fade away
    [UIView animateWithDuration:0.175 animations:^{
        [backgroundView setAlpha:0.0];
    }];

    switch (trannyType) {
        case PopupOutgoingTransitionTypeBounceFromCenter: {

            [UIView animateWithDuration:0.1 delay:0.0 usingSpringWithDamping:0.55 initialSpringVelocity:1.0 options:UIViewAnimationOptionTransitionNone animations:^{
                popupView.transform = CGAffineTransformMakeScale(1.15, 1.15);
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    
                    popupView.transform = CGAffineTransformMakeScale(0.75, 0.75);
                    
                } completion:^(BOOL finished) {
                    [self endWithButtonType:buttonType];
                }];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeSlideToLeft: {
            
            CGRect rect = CGRectMake(-300, mainScreen.bounds.size.height/2 - 150, 300, 300);

            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:rect];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeSlideToTop: {

            CGRect rect = CGRectMake(mainScreen.bounds.size.width/2 - 150, -300, 300, 300);

            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:rect];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];

            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeSlideToBottom: {

            CGRect rect = CGRectMake(mainScreen.bounds.size.width/2 - 150, mainScreen.bounds.size.height + 300, 300, 300);

            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:rect];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];

            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeSlideToRight: {

            CGRect rect = CGRectMake(mainScreen.bounds.size.width + 300, mainScreen.bounds.size.height/2 - 150, 300, 300);

            [UIView animateWithDuration:0.125 animations:^{
                [popupView setFrame:rect];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeEaseToCenter: {
            
            [UIView animateWithDuration:0.2 animations:^{
                popupView.transform = CGAffineTransformMakeScale(0.75, 0.75);
                [popupView setAlpha:0.0];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeDisappearCenter: {
            
            [UIView animateWithDuration:0.25 animations:^{
                popupView.transform = CGAffineTransformMakeScale(0.65, 0.65);
                [popupView setAlpha:0.0];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeFallWithGravity: {
            
            CGRect initialRect = CGRectMake(mainScreen.bounds.size.width/2 - 150, mainScreen.bounds.size.height/2 - 150, 300, 300);
            CGRect endingRect = CGRectMake(mainScreen.bounds.size.width/2 - 150, mainScreen.bounds.size.height + 300, 300, 300);

            [UIView animateWithDuration:0.1 delay:0.0 usingSpringWithDamping:0.24 initialSpringVelocity:0.9 options:UIViewAnimationOptionTransitionNone animations:^{
                [popupView setFrame:initialRect];

            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.35 animations:^{
                    [popupView setFrame:endingRect];

                } completion:^(BOOL finished) {
                    [self endWithButtonType:buttonType];
                }];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeGhostDisappear: {
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                [popupView setAlpha:0.0];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        case PopupOutgoingTransitionTypeGrowDisappear: {
            
            [UIView animateWithDuration:0.25 animations:^{
                popupView.transform = CGAffineTransformMakeScale(1.25, 1.25);
                [popupView setAlpha:0.0];
                
            } completion:^(BOOL finished) {
                [self endWithButtonType:buttonType];
            }];
            
            break;
        }
        default: {
            break;
        }
    }
    
}

- (void)endWithButtonType:(PopupButtonType)buttonType {

    blocky blockster;
    
    if (buttonType == PopupTypeSuccess) {
        pSuccessBlock ? blockster = pSuccessBlock: nil;
    }
    else {
        pCancelBlock ? blockster = pCancelBlock: nil;
    }
    
    [self removeFromSuperview];
    
    if (blockster) blockster();
    else if (self.delegate && [self.delegate respondsToSelector:@selector(popupDidDisappear:buttonType:)]) {
        [self.delegate popupDidDisappear:self buttonType:buttonType];
    }
    
}

@end
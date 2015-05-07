//
//  Popup.h
//  PopupDemo
//
//  Created by Mark Miscavage on 4/16/15.
//  Copyright (c) 2015 Mark Miscavage. All rights reserved.
//

#import <UIKit/UIKit.h>

//Popup button types
typedef NS_ENUM(NSInteger, PopupButtonType) {
    PopupButtonSuccess = 0,
    PopupButtonCancel
};

//Popup types
typedef NS_ENUM(NSInteger, PopupType) {
    PopupTypeSuccess = 0,
    PopupTypeError
};

//Background blur types
typedef NS_ENUM(NSInteger, PopupBackGroundBlurType) {
    PopupBackGroundBlurTypeDark = 0,
    PopupBackGroundBlurTypeLight,
    PopupBackGroundBlurTypeExtraLight,
    PopupBackGroundBlurTypeNone
};

//Incoming transition types
typedef NS_ENUM(NSUInteger, PopupIncomingTransitionType) {
    PopupIncomingTransitionTypeBounceFromCenter = 1,
    PopupIncomingTransitionTypeSlideFromLeft,
    PopupIncomingTransitionTypeSlideFromTop,
    PopupIncomingTransitionTypeSlideFromBottom,
    PopupIncomingTransitionTypeSlideFromRight,
    PopupIncomingTransitionTypeEaseFromCenter,
    PopupIncomingTransitionTypeAppearCenter,
    PopupIncomingTransitionTypeFallWithGravity,
    PopupIncomingTransitionTypeGhostAppear,
    PopupIncomingTransitionTypeShrinkAppear
};

//Outgoing transition types
typedef NS_ENUM(NSUInteger, PopupOutgoingTransitionType) {
    PopupOutgoingTransitionTypeBounceFromCenter = 1,
    PopupOutgoingTransitionTypeSlideToLeft,
    PopupOutgoingTransitionTypeSlideToTop,
    PopupOutgoingTransitionTypeSlideToBottom,
    PopupOutgoingTransitionTypeSlideToRight,
    PopupOutgoingTransitionTypeEaseToCenter,
    PopupOutgoingTransitionTypeDisappearCenter,
    PopupOutgoingTransitionTypeFallWithGravity,
    PopupOutgoingTransitionTypeGhostDisappear,
    PopupOutgoingTransitionTypeGrowDisappear
};

//Block for success and cancel buttons
typedef void (^blocky)(void);


@class Popup;

@protocol PopupDelegate;

@interface Popup : UIView

//Delegate for Popup
@property (nonatomic, weak) id <PopupDelegate> delegate;

//Create a basic Popup
- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                  cancelTitle:(NSString *)cancelTitle
                 successTitle:(NSString *)successTitle;

//Create a basic Popup with success and cancel blocks
- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                  cancelTitle:(NSString *)cancelTitle
                 successTitle:(NSString *)successTitle
                  cancelBlock:(blocky)cancelBlock
                 successBlock:(blocky)successBlock;

//Create a Popup with textfields and success and cancel blocks
- (instancetype)initWithTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
        textFieldPlaceholders:(NSArray *)textFieldPlaceholderArray
                  cancelTitle:(NSString *)cancelTitle
                 successTitle:(NSString *)successTitle
                  cancelBlock:(blocky)cancelBlock
                 successBlock:(blocky)successBlock;

//The transitions for Popup
@property (nonatomic, assign) PopupIncomingTransitionType incomingTransition;
@property (nonatomic, assign) PopupOutgoingTransitionType outgoingTransition;

//Type of blurred background behind Popup
@property (nonatomic, assign) PopupBackGroundBlurType backgroundBlurType;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *subTitleColor;
@property (nonatomic, strong) UIColor *successBtnColor;
@property (nonatomic, strong) UIColor *successTitleColor;
@property (nonatomic, strong) UIColor *cancelBtnColor;
@property (nonatomic, strong) UIColor *cancelTitleColor;

//Showing and Dismissing methods
- (void)showPopup;
- (void)dismissPopup:(PopupButtonType)buttonType;

//Set the appearance of all keyboards in your Popup
- (void)setOverallKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance;

//Set the keyboard type for each individual keyboard in your Popup
- (void)setKeyboardTypeForTextFields:(NSArray *)keyboardTypeArray;

//Set certain textfields if they are secure or not
- (void)setTextFieldTypeForTextFields:(NSArray *)textFieldTypeArray;

//Does your Popup have rounded corners or doesn't it?
@property (nonatomic, assign) BOOL roundedCorners;

//Tap the background of Popup to dismiss
//Returns PopupButtonCancel
//Automatically set to NO
@property (nonatomic, assign) BOOL tapBackgroundToDismiss;

//Swipe to dismiss Popup just like swiping to dismiss photos in Facebook app
//Automatically set to NO
@property (nonatomic, assign) BOOL swipeToDismiss;

@end

@protocol PopupDelegate <NSObject>

@optional

//Called when your popup is transitioning to the center of the screen
- (void)popupWillAppear:(Popup *)popup;

//Called when your popup is in the center of the screen after animating
- (void)popupDidAppear:(Popup *)popup;

//Called when your popup is transitioning away from the center of the screen
//Returns your popup and what button was pressed
- (void)popupWillDisappear:(Popup *)popup buttonType:(PopupButtonType)buttonType;

//Called when your popup has disappeared from the screen
//Returns your popup and what button was pressed
- (void)popupDidDisappear:(Popup *)popup buttonType:(PopupButtonType)buttonType;

//Figure out what button was pressed on your Popup
- (void)popupPressButton:(Popup *)popup buttonType:(PopupButtonType)buttonType;

//Get a dictionary and array from your textfields to easily find out what the user typed
//Dictionary returns placeholder as key and input as value
//Array returns all inputs ordered by what textfield they correspond to
- (void)dictionary:(NSMutableDictionary *)dictionary forpopup:(Popup *)popup stringsFromTextFields:(NSArray *)stringArray;

@end
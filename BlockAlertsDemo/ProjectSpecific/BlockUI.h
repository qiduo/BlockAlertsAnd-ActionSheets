//
//  BlockUI.h
//
//  Created by Gustavo Ambrozio on 14/2/12.
//

#ifndef BlockUI_h
#define BlockUI_h

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
#define NSTextAlignmentCenter       UITextAlignmentCenter
#define NSLineBreakByWordWrapping   UILineBreakModeWordWrap
#define NSLineBreakByClipping       UILineBreakModeClip

#endif

#ifndef IOS_LESS_THAN_6
#define IOS_LESS_THAN_6 !([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending)

#endif

#define NeedsLandscapePhoneTweaks (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)


// Action Sheet constants

#define kActionSheetAnimationDuration   0.25

#define kActionSheetBounce         10
#define kActionSheetButtonHeight   45
#define kActionSheetTopMargin      5
#define kActionSheetBorderHorizontal  13
#define kActionSheetBorderVertical    0

#define kActionSheetTitleFont           [UIFont systemFontOfSize:18]
#define kActionSheetTitleTextColor      [UIColor grayColor]
#define kActionSheetTitleShadowColor    [UIColor grayColor]
#define kActionSheetTitleShadowOffset   CGSizeMake(0, 0)

#define kActionSheetButtonFont          [UIFont systemFontOfSize:18]
#define kActionSheetButtonTextColor     [UIColor colorWithWhite:0.235 alpha:1.0f]
#define kActionSheetButtonShadowColor   [UIColor whiteColor]
#define kActionSheetButtonShadowOffset  CGSizeMake(0, 0)

#define kActionSheetCancelButtonTextColor           [UIColor colorWithRed:22/255.0f green:116/255.0f blue:229/255.0f alpha:1.0f]
#define kActionSheetDestructiveButtonTextColor      [UIColor redColor]

#define kActionSheetBackground              @"action-sheet-panel"
#define kActionSheetBackgroundCapHeight     5
#define kActionSheetBackgroundCapWidth      5


// Alert View constants

#define kAlertViewBackgroundWidth   260

#define kAlertViewTopMargin      10
#define kAlertViewBounce         20
#define kAlertButtonHeight       (NeedsLandscapePhoneTweaks ? 32 : 42)
#define kAlertViewBorderHorizontal          (NeedsLandscapePhoneTweaks ? 4 : 8)
#define kAlertViewBorderVertical            6
#define kAlertViewMessageBottomMargin       20

#define kAlertViewTitleFont             [UIFont boldSystemFontOfSize:18]
#define kAlertViewTitleTextColor        [UIColor colorWithWhite:0.235 alpha:1.0f]
#define kAlertViewTitleShadowColor      [UIColor whiteColor]
#define kAlertViewTitleShadowOffset     CGSizeMake(0, 0)

#define kAlertViewMessageFont           [UIFont systemFontOfSize:14]
#define kAlertViewMessageTextColor      [UIColor colorWithWhite:0.235 alpha:1.0f]
#define kAlertViewMessageShadowColor    [UIColor whiteColor]
#define kAlertViewMessageShadowOffset   CGSizeMake(0, 0)

#define kAlertViewButtonFont            [UIFont boldSystemFontOfSize:16]
#define kAlertViewButtonTextColor       [UIColor colorWithWhite:0.235 alpha:1.0f]
#define kAlertViewButtonShadowColor     [UIColor whiteColor]
#define kAlertViewButtonShadowOffset    CGSizeMake(0, 0)

#define kAlertViewCancelButtonTextColor         [UIColor colorWithWhite:0.235 alpha:1.0f]
#define kAlertViewDestructiveButtonTextColor    [UIColor colorWithRed:22/255.0f green:116/255.0f blue:229/255.0f alpha:1.0f]

#define kAlertViewBackground            @"alert-window"
#define kAlertViewBackgroundLandscape   @"alert-window"
#define kAlertViewBackgroundCapHeight   5
#define kAlertViewBackgroundCapWidth    5

#endif

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
#define kActionSheetButtonHeight   36
#define kActionSheetTopMargin      15
#define kActionSheetBorderHorizontal  13
#define kActionSheetBorderVertical    5

#define kActionSheetTitleFont           [UIFont systemFontOfSize:18]
#define kActionSheetTitleTextColor      [UIColor grayColor]
#define kActionSheetTitleShadowColor    [UIColor blackColor]
#define kActionSheetTitleShadowOffset   CGSizeMake(0, 0)

#define kActionSheetButtonFont          [UIFont systemFontOfSize:20]
#define kActionSheetButtonTextColor     [UIColor blueColor]
#define kActionSheetButtonShadowColor   [UIColor whiteColor]
#define kActionSheetButtonShadowOffset  CGSizeMake(0, 0)

#define kActionSheetBackground              @"action-sheet-panel"
#define kActionSheetBackgroundCapHeight     5
#define kActionSheetBackgroundCapWidth      5


// Alert View constants

#define kAlertViewBackgroundWidth   230

#define kAlertViewBounce         20
#define kAlertViewBorder         (NeedsLandscapePhoneTweaks ? 5 : 10)
#define kAlertButtonHeight       (NeedsLandscapePhoneTweaks ? 35 : 44)

#define kAlertViewTitleFont             [UIFont boldSystemFontOfSize:16]
#define kAlertViewTitleTextColor        [UIColor blackColor]
#define kAlertViewTitleShadowColor      [UIColor whiteColor]
#define kAlertViewTitleShadowOffset     CGSizeMake(0, 0)

#define kAlertViewMessageFont           [UIFont systemFontOfSize:14]
#define kAlertViewMessageTextColor      [UIColor blackColor]
#define kAlertViewMessageShadowColor    [UIColor whiteColor]
#define kAlertViewMessageShadowOffset   CGSizeMake(0, 0)

#define kAlertViewButtonFont            [UIFont boldSystemFontOfSize:16]
#define kAlertViewButtonTextColor       [UIColor blackColor]
#define kAlertViewButtonShadowColor     [UIColor whiteColor]
#define kAlertViewButtonShadowOffset    CGSizeMake(0, 0)

#define kAlertViewBackground            @"alert-window"
#define kAlertViewBackgroundLandscape   @"alert-window"
#define kAlertViewBackgroundCapHeight   5
#define kAlertViewBackgroundCapWidth    5

#endif

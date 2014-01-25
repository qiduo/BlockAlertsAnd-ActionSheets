//
//  BlockAlertView.m
//
//

#import "BlockAlertView.h"
#import "BlockBackground.h"
#import "BlockUI.h"

@implementation BlockAlertView

@synthesize view = _view;
@synthesize backgroundImage = _backgroundImage;
@synthesize vignetteBackground = _vignetteBackground;

static UIImage *background = nil;
static UIImage *backgroundlandscape = nil;
static UIFont *titleFont = nil;
static UIFont *messageFont = nil;
static UIFont *buttonFont = nil;


#pragma mark - init

+ (void)initialize
{
    if (self == [BlockAlertView class])
    {
        background = [UIImage imageNamed:kAlertViewBackground];
        background = [[background stretchableImageWithLeftCapWidth:kAlertViewBackgroundCapWidth topCapHeight:kAlertViewBackgroundCapHeight] retain];
        
        backgroundlandscape = [UIImage imageNamed:kAlertViewBackgroundLandscape];
        backgroundlandscape = [[backgroundlandscape stretchableImageWithLeftCapWidth:kAlertViewBackgroundCapWidth topCapHeight:kAlertViewBackgroundCapHeight] retain];
        
        titleFont = [kAlertViewTitleFont retain];
        messageFont = [kAlertViewMessageFont retain];
        buttonFont = [kAlertViewButtonFont retain];
    }
}

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message
{
    return [[[BlockAlertView alloc] initWithTitle:title message:message] autorelease];
}

+ (void)showInfoAlertWithTitle:(NSString *)title message:(NSString *)message
{
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:title message:message];
    [alert setDestructiveButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
    [alert show];
    [alert release];
}

+ (void)showErrorAlert:(NSError *)error
{
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:NSLocalizedString(@"Operation Failed", nil) message:[NSString stringWithFormat:NSLocalizedString(@"The operation did not complete successfully: %@", nil), error]];
    [alert setDestructiveButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
    [alert show];
    [alert release];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (void)addComponents:(CGRect)frame {
    if (_title || !_title.length)
    {
        CGSize size = [_title sizeWithFont:titleFont
                         constrainedToSize:CGSizeMake(frame.size.width-kAlertViewBorderHorizontal*2, 1000)
                             lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kAlertViewBorderHorizontal, _height, frame.size.width-kAlertViewBorderHorizontal*2, size.height)];
        labelView.font = titleFont;
        labelView.numberOfLines = 0;
        labelView.lineBreakMode = NSLineBreakByWordWrapping;
        labelView.textColor = kAlertViewTitleTextColor;
        labelView.backgroundColor = [UIColor clearColor];
        labelView.textAlignment = NSTextAlignmentCenter;
        labelView.shadowColor = kAlertViewTitleShadowColor;
        labelView.shadowOffset = kAlertViewTitleShadowOffset;
        labelView.text = _title;
        [_view addSubview:labelView];
        [labelView release];
        
        _height += size.height + kAlertViewTitleBottomMargin;
    }
    
    if (_message)
    {
        if (!_title || !_title.length) {
            _height += 4.0f;
        }
        CGSize size = [_message sizeWithFont:messageFont
                           constrainedToSize:CGSizeMake(frame.size.width-kAlertViewBorderHorizontal*2, 1000)
                               lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kAlertViewBorderHorizontal, _height, frame.size.width-kAlertViewBorderHorizontal*2, size.height)];
        labelView.font = messageFont;
        labelView.numberOfLines = 0;
        labelView.lineBreakMode = NSLineBreakByWordWrapping;
        labelView.textColor = kAlertViewMessageTextColor;
        labelView.backgroundColor = [UIColor clearColor];
        labelView.textAlignment = NSTextAlignmentCenter;
        labelView.shadowColor = kAlertViewMessageShadowColor;
        labelView.shadowOffset = kAlertViewMessageShadowOffset;
        labelView.text = _message;
        [_view addSubview:labelView];
        [labelView release];
        
        _height += size.height + kAlertViewMessageBottomMargin;
    }
    
    if (_message || _title) {
        _height += kAlertViewButtonPartTopMargin;
    }
}

- (void)setupDisplay
{
    [[_view subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    UIWindow *parentView = [BlockBackground sharedInstance];
    CGRect frame = parentView.bounds;
    frame.origin.x = floorf((frame.size.width - kAlertViewBackgroundWidth) * 0.5);
    frame.size.width = kAlertViewBackgroundWidth;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        frame.size.width += 150;
        frame.origin.x -= 75;
    }
    
    _view.frame = frame;
    
    _height = kAlertViewBorderVertical + kAlertViewTopMargin;
    
    if (NeedsLandscapePhoneTweaks) {
        _height -= roundf(kAlertViewTopMargin * 0.5); // landscape phones need to trimmed a bit
    }

    [self addComponents:frame];

    if (_shown)
        [self show];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message 
{
    self = [super init];
    
    if (self)
    {
        _title = [title copy];
        _message = [message copy];
        
        _view = [[UIView alloc] init];
        
        _view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        _blocks = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(setupDisplay) 
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification 
                                                   object:nil];   
        
        if ([self class] == [BlockAlertView class])
            [self setupDisplay];
        
        _vignetteBackground = NO;
    }
    
    return self;
}

- (void)dealloc 
{
    [_title release];
    [_message release];
    [_backgroundImage release];
    [_view release];
    [_blocks release];
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)addButtonWithTitle:(NSString *)title color:(UIColor *)color block:(void (^)())block
{
    [_blocks addObject:[NSArray arrayWithObjects:
                        block ? [[block copy] autorelease] : [NSNull null],
                        title,
                        color,
                        nil]];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:kAlertViewButtonTextColor block:block];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:kAlertViewCancelButtonTextColor block:block];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:kAlertViewDestructiveButtonTextColor block:block];
}

- (void)show
{
    _shown = YES;
    
    BOOL isSecondButton = NO;
    CGFloat maxWidth = _view.bounds.size.width;
    CGFloat maxHalfWidth = floorf(maxWidth * 0.5);
    
    for (NSUInteger i = 0; i < _blocks.count; i++) {
        NSArray *block = [_blocks objectAtIndex:i];
        NSString *title = [block objectAtIndex:1];
        UIColor *color = [block objectAtIndex:2];
        
        CGFloat width = maxWidth;
        CGFloat xOffset = 0;
        UIImage *backgroundImage;
        
        if (isSecondButton) {
            width = maxHalfWidth;
            xOffset = width + 1;
            isSecondButton = NO;
        }
        else if (i + 1 < _blocks.count) {
            // In this case there's another button.
            // Let's check if they fit on the same line.
            CGSize size = [title sizeWithFont:buttonFont 
                                  minFontSize:10 
                               actualFontSize:nil
                                     forWidth:maxWidth
                                lineBreakMode:NSLineBreakByClipping];
            
            if (size.width < maxHalfWidth) {
                // It might fit. Check the next Button
                NSArray *block2 = [_blocks objectAtIndex:i+1];
                NSString *title2 = [block2 objectAtIndex:1];
                size = [title2 sizeWithFont:buttonFont 
                                minFontSize:10 
                             actualFontSize:nil
                                   forWidth:maxWidth
                              lineBreakMode:NSLineBreakByClipping];
                
                if (size.width < maxHalfWidth) {
                    // They'll fit!
                    isSecondButton = YES;  // For the next iteration
                    width = maxHalfWidth;
                }
            }
        }
        else if (_blocks.count  == 1) {
            // In this case this is the ony button.
            width = maxWidth;
            xOffset = 0;
        }
        
        // Separator
        if (width == maxWidth || isSecondButton) {
            UIImage *separatorImage = [[UIImage imageNamed:@"alert-action-separator-horizontal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
            UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
            separatorImageView.frame = CGRectMake(kAlertViewBorderHorizontal, _height, _view.bounds.size.width - kAlertViewBorderHorizontal * 2, 1);
            [_view addSubview:separatorImageView];
        } else {
            UIImage *separatorImage = [[UIImage imageNamed:@"alert-action-separator-vertical"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
            UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
            separatorImageView.frame = CGRectMake(maxHalfWidth, _height, 1, kAlertButtonHeight);
            [_view addSubview:separatorImageView];
        }
        
        // Button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(xOffset, _height, width, kAlertButtonHeight);
        
        if (_blocks.count == 1) {
            backgroundImage = [[UIImage imageNamed:kAlertViewButtonBackgroundHighlightedBottom] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        } else if (i < _blocks.count - 1) {
            if (width == maxHalfWidth && i == _blocks.count - 2) {
                backgroundImage = [[UIImage imageNamed:kAlertViewButtonBackgroundHighlightedBottomLeft] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
            } else {
                backgroundImage = [[UIImage imageNamed:kAlertViewButtonBackgroundHighlightedMiddle] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
            }
        } else {
            if (width == maxWidth) {
                backgroundImage = [[UIImage imageNamed:kAlertViewButtonBackgroundHighlightedBottom] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
            } else {
                backgroundImage = [[UIImage imageNamed:kAlertViewButtonBackgroundHighlightedBottomRight] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
            }
        }
        [button setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];
        
        button.titleLabel.font = buttonFont;
        if (IOS_LESS_THAN_6) {
#pragma clan diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            button.titleLabel.minimumFontSize = 10;
#pragma clan diagnostic pop
        }
        else {
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            button.titleLabel.adjustsLetterSpacingToFitWidth = YES;
            button.titleLabel.minimumScaleFactor = 0.1;
        }
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.shadowOffset = kAlertViewButtonShadowOffset;
        button.backgroundColor = [UIColor clearColor];
        button.tag = i+1;
        
        UIColor *titleColor = color;
        if (titleColor == nil) {
            titleColor = kAlertViewButtonTextColor;
        }
        [button setTitleColor:titleColor forState:UIControlStateNormal];
        [button setTitleColor:kAlertViewButtonTextColorHighlighted forState:UIControlStateHighlighted];
        [button setTitleShadowColor:kAlertViewButtonShadowColor forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.accessibilityLabel = title;
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_view addSubview:button];
        
        if (width == maxWidth || isSecondButton == NO) {
            _height += kAlertButtonHeight + kAlertViewBorderVertical;
        }
    }

    //_height += 10;  // Margin for the shadow // not sure where this came from, but it's making things look strange (I don't see a shadow, either)
    
    if (_height < background.size.height)
    {
        CGFloat offset = background.size.height - _height;
        _height = background.size.height;
        CGRect frame;
        for (NSUInteger i = 0; i < _blocks.count; i++)
        {
            UIButton *btn = (UIButton *)[_view viewWithTag:i+1];
            frame = btn.frame;
            frame.origin.y += offset;
            btn.frame = frame;
        }
    }
    
    
    CGRect frame = _view.frame;
    frame.origin.y = - _height;
    frame.size.height = _height;
    _view.frame = frame;
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:_view.bounds];
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        modalBackground.image = backgroundlandscape;
    else
        modalBackground.image = background;

    modalBackground.contentMode = UIViewContentModeScaleToFill;
    modalBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_view insertSubview:modalBackground atIndex:0];
    [modalBackground release];
    
    if (_backgroundImage)
    {
        [BlockBackground sharedInstance].backgroundImage = _backgroundImage;
        [_backgroundImage release];
        _backgroundImage = nil;
    }
    
    [BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
    [[BlockBackground sharedInstance] addToMainWindow:_view];

    __block CGPoint center = _view.center;
    center.y = floorf([BlockBackground sharedInstance].bounds.size.height * 0.5) + kAlertViewBounce;
    
    _cancelBounce = NO;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [BlockBackground sharedInstance].alpha = 1.0f;
                         _view.center = center;
                     } 
                     completion:^(BOOL finished) {
                         if (_cancelBounce) return;
                         
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:0
                                          animations:^{
                                              center.y -= kAlertViewBounce;
                                              _view.center = center;
                                          } 
                                          completion:^(BOOL finished) {
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"AlertViewFinishedAnimations" object:self];
                                          }];
                     }];
    
    [self retain];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated 
{
    _shown = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (buttonIndex >= 0 && buttonIndex < [_blocks count])
    {
        id obj = [[_blocks objectAtIndex: buttonIndex] objectAtIndex:0];
        if (![obj isEqual:[NSNull null]])
        {
            ((void (^)())obj)();
        }
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:0
                         animations:^{
                             CGPoint center = _view.center;
                             center.y += 20;
                             _view.center = center;
                         } 
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.4
                                                   delay:0.0 
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  CGRect frame = _view.frame;
                                                  frame.origin.y = -frame.size.height;
                                                  _view.frame = frame;
                                                  [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
                                              } 
                                              completion:^(BOOL finished) {
                                                  [[BlockBackground sharedInstance] removeView:_view];
                                                  [_view release]; _view = nil;
                                                  [self autorelease];
                                              }];
                         }];
    }
    else
    {
        [[BlockBackground sharedInstance] removeView:_view];
        [_view release]; _view = nil;
        [self autorelease];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action

- (void)buttonClicked:(id)sender 
{
    /* Run the button's block */
    int buttonIndex = [(UIButton *)sender tag] - 1;
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end

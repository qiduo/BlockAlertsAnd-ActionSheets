//
//  BlockActionSheet.m
//
//

#import "BlockActionSheet.h"
#import "BlockBackground.h"
#import "BlockUI.h"

@interface BlockActionSheet ()
@property (nonatomic, assign) BOOL hasTitle;
@end

@implementation BlockActionSheet

@synthesize view = _view;
@synthesize vignetteBackground = _vignetteBackground;

static UIImage *background = nil;
static UIFont *titleFont = nil;
static UIFont *buttonFont = nil;

#pragma mark - init

+ (void)initialize
{
    if (self == [BlockActionSheet class])
    {
        background = [UIImage imageNamed:kActionSheetBackground];
        background = [[background stretchableImageWithLeftCapWidth:kActionSheetBackgroundCapWidth topCapHeight:kActionSheetBackgroundCapHeight] retain];
        titleFont = [kActionSheetTitleFont retain];
        buttonFont = [kActionSheetButtonFont retain];
    }
}

+ (id)sheetWithTitle:(NSString *)title
{
    return [[[BlockActionSheet alloc] initWithTitle:title] autorelease];
}

- (id)initWithTitle:(NSString *)title 
{
    if ((self = [super init]))
    {
        UIWindow *parentView = [BlockBackground sharedInstance];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundClicked:)];
        [parentView addGestureRecognizer:tapGestureRecognizer];

        CGRect frame = parentView.bounds;
        
        _view = [[UIView alloc] initWithFrame:frame];
        
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        _blocks = [[NSMutableArray alloc] init];
        _height = kActionSheetTopMargin;

        if (title) {
            CGSize size = [title sizeWithFont:titleFont
                            constrainedToSize:CGSizeMake(frame.size.width-kActionSheetBorderHorizontal*2, 1000)
                                lineBreakMode:NSLineBreakByWordWrapping];
            
            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kActionSheetBorderHorizontal, _height + kActionSheetTitleVerticalMargin, frame.size.width-kActionSheetBorderHorizontal*2, size.height)];
            labelView.font = titleFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = NSLineBreakByWordWrapping;
            labelView.textColor = kActionSheetTitleTextColor;
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = NSTextAlignmentCenter;
            labelView.shadowColor = kActionSheetTitleShadowColor;
            labelView.shadowOffset = kActionSheetTitleShadowOffset;
            labelView.text = title;
            
            labelView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            [_view addSubview:labelView];
            [labelView release];
            
            _height += size.height + kActionSheetTitleVerticalMargin * 2;
            _hasTitle = YES;
        } else {
            _hasTitle = NO;
        }
        _vignetteBackground = NO;
    }
    
    return self;
}

- (void) dealloc 
{
    [_view release];
    [_blocks release];
    [super dealloc];
}

- (NSUInteger)buttonCount
{
    return _blocks.count;
}

- (void)addButtonWithTitle:(NSString *)title color:(UIColor *)color block:(void (^)())block atIndex:(NSInteger)index
{
    if (index >= 0)
    {
        [_blocks insertObject:[NSArray arrayWithObjects:
                               block ? [[block copy] autorelease] : [NSNull null],
                               title,
                               color,
                               nil]
                      atIndex:index];
    }
    else
    {
        [_blocks addObject:[NSArray arrayWithObjects:
                            block ? [[block copy] autorelease] : [NSNull null],
                            title,
                            color,
                            nil]];
    }
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:kActionSheetDestructiveButtonTextColor block:block atIndex:-1];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:kActionSheetCancelButtonTextColor block:block atIndex:-1];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:kActionSheetButtonTextColor block:block atIndex:-1];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title color:kActionSheetDestructiveButtonTextColor block:block atIndex:index];
}

- (void)setCancelButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title color:kActionSheetCancelButtonTextColor block:block atIndex:index];
}

- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block 
{
    [self addButtonWithTitle:title color:kActionSheetButtonTextColor block:block atIndex:index];
}

- (void)showInView:(UIView *)view
{
    NSUInteger i = 1;   // Why?
    for (NSArray *block in _blocks)
    {
        // Separator
        if (_height > kActionSheetTopMargin) {
            UIImage *separatorImage = [[UIImage imageNamed:@"alert-action-separator-horizontal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
            UIImageView *separatorImageView = [[UIImageView alloc] initWithImage:separatorImage];
            separatorImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            separatorImageView.frame = CGRectMake(kActionSheetBorderHorizontal, _height, _view.bounds.size.width - kActionSheetBorderHorizontal * 2, 1);
            [_view addSubview:separatorImageView];
        }
        
        NSString *title = [block objectAtIndex:1];
        UIColor *color = [block objectAtIndex:2];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, _height, _view.bounds.size.width, kActionSheetButtonHeight);
        
        UIImage *backgroundImage;
        if (_blocks.count == 1) {
            if (self.hasTitle) {
                backgroundImage = [[UIImage imageNamed:kActionSheetButtonBackgroundHighlightedBottom] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
            } else {
                backgroundImage = [[UIImage imageNamed:kActionSheetButtonBackgroundHighlightedBoth] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
            }
        } else if (i == 1) {
            if (self.hasTitle) {
                backgroundImage = [[UIImage imageNamed:kActionSheetButtonBackgroundHighlightedMiddle] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
            } else {
                backgroundImage = [[UIImage imageNamed:kActionSheetButtonBackgroundHighlightedTop] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
            }
        } else if (i == [self buttonCount]) {
            backgroundImage = [[UIImage imageNamed:kActionSheetButtonBackgroundHighlightedBottom] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        } else {
            backgroundImage = [[UIImage imageNamed:kActionSheetButtonBackgroundHighlightedMiddle] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
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
            button.titleLabel.minimumScaleFactor = 0.1;
        }
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.shadowOffset = kActionSheetButtonShadowOffset;
        button.backgroundColor = [UIColor clearColor];
        button.tag = i++;
        
        if (color) {
            [button setTitleColor:color forState:UIControlStateNormal];
        } else {
            [button setTitleColor:kActionSheetButtonTextColor forState:UIControlStateNormal];
        }
        [button setTitleColor:kActionSheetButtonTextColorHighlighted forState:UIControlStateHighlighted];
        [button setTitleShadowColor:kActionSheetButtonShadowColor forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.accessibilityLabel = title;
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [_view addSubview:button];
        _height += kActionSheetButtonHeight + kActionSheetBorderVertical;
    }
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:_view.bounds];
    modalBackground.image = background;
    modalBackground.contentMode = UIViewContentModeScaleToFill;
    modalBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_view insertSubview:modalBackground atIndex:0];
    [modalBackground release];
    
    [BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
    [[BlockBackground sharedInstance] addToMainWindow:_view];
    CGRect frame = _view.frame;
    frame.origin.x += 8;
    frame.origin.y = [BlockBackground sharedInstance].bounds.size.height - 8;
    frame.size.width -= 16;
    frame.size.height = _height;
    _view.frame = frame;
    
    __block CGPoint center = _view.center;
    center.y -= _height + kActionSheetBounce;
    
    [UIView animateWithDuration:kActionSheetAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [BlockBackground sharedInstance].alpha = 1.0f;
                         _view.center = center;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              center.y += kActionSheetBounce;
                                              _view.center = center;
                                          } completion:nil];
                     }];
    
    [self retain];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated 
{
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
        CGPoint center = _view.center;
        center.y += _view.bounds.size.height;
        [UIView animateWithDuration:kActionSheetAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _view.center = center;
                             [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
                         } completion:^(BOOL finished) {
                             [[BlockBackground sharedInstance] removeView:_view];
                             [_view release]; _view = nil;
                             [self autorelease];
                         }];
    }
    else
    {
        [[BlockBackground sharedInstance] removeView:_view];
        [_view release]; _view = nil;
        [self autorelease];
    }
}

#pragma mark - Action

- (void)buttonClicked:(id)sender 
{
    /* Run the button's block */
    int buttonIndex = [(UIButton *)sender tag] - 1;
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}


- (void)backgroundClicked:(id)sender
{
    [self dismissWithClickedButtonIndex:-1 animated:YES];
}


@end

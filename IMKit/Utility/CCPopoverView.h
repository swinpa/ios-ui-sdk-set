
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CCPopoverArrowDirection) {
    CCPopoverArrowDirectionUp,
    CCPopoverArrowDirectionDown,
    CCPopoverArrowDirectionLeft,
    CCPopoverArrowDirectionRight,
    CCPopoverArrowDirectionNone,
};

@interface CCPopoverView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CGSize arrowSize;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, assign) BOOL dismissOnBackgroundTap;
@property (nonatomic, assign, readonly) CCPopoverArrowDirection arrowDirection;

- (void)showFromView:(UIView *)fromView;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END

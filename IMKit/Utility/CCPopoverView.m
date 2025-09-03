
#import "CCPopoverView.h"

@interface CCPopoverView ()
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, assign, readwrite) CCPopoverArrowDirection arrowDirection;
@end

@implementation CCPopoverView

- (instancetype)init {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _arrowSize = CGSizeMake(12, 8);
        _contentInset = UIEdgeInsetsMake(8, 8, 8, 8);
        _maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
        _dismissOnBackgroundTap = YES;
        self.backgroundColor = UIColor.clearColor;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)showFromView:(UIView *)fromView {
    if (!self.contentView) return;
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (!window) return;
    
    CGRect fromFrame = [fromView.superview convertRect:fromView.frame toView:window];
    CGFloat screenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenH = UIScreen.mainScreen.bounds.size.height;
    
    CGFloat contentW = self.contentView.bounds.size.width;
    CGFloat contentH = self.contentView.bounds.size.height;
    
    CCPopoverArrowDirection bestDirection = CCPopoverArrowDirectionDown;
    CGFloat availableTop = CGRectGetMinY(fromFrame);
    CGFloat availableBottom = screenH - CGRectGetMaxY(fromFrame);
    CGFloat availableLeft = CGRectGetMinX(fromFrame);
    CGFloat availableRight = screenW - CGRectGetMaxX(fromFrame);
    
    if (availableBottom >= contentH + self.arrowSize.height) {
        bestDirection = CCPopoverArrowDirectionDown;
    } else if (availableTop >= contentH + self.arrowSize.height) {
        bestDirection = CCPopoverArrowDirectionUp;
    } else if (availableRight >= contentW + self.arrowSize.height) {
        bestDirection = CCPopoverArrowDirectionRight;
    } else if (availableLeft >= contentW + self.arrowSize.height) {
        bestDirection = CCPopoverArrowDirectionLeft;
    } else {
        bestDirection = CCPopoverArrowDirectionNone;
    }
    self.arrowDirection = bestDirection;
    
    CGRect contentFrame = CGRectZero;
    switch (bestDirection) {
        case CCPopoverArrowDirectionDown: {
            CGFloat x = CGRectGetMidX(fromFrame) - contentW/2;
            x = MAX(8, MIN(x, screenW - contentW - 8));
            contentFrame = CGRectMake(x, CGRectGetMaxY(fromFrame) + self.arrowSize.height, contentW, contentH);
        } break;
        case CCPopoverArrowDirectionUp: {
            CGFloat x = CGRectGetMidX(fromFrame) - contentW/2;
            x = MAX(8, MIN(x, screenW - contentW - 8));
            contentFrame = CGRectMake(x, CGRectGetMinY(fromFrame) - contentH - self.arrowSize.height, contentW, contentH);
        } break;
        case CCPopoverArrowDirectionRight: {
            CGFloat y = CGRectGetMidY(fromFrame) - contentH/2;
            y = MAX(8, MIN(y, screenH - contentH - 8));
            contentFrame = CGRectMake(CGRectGetMaxX(fromFrame) + self.arrowSize.height, y, contentW, contentH);
        } break;
        case CCPopoverArrowDirectionLeft: {
            CGFloat y = CGRectGetMidY(fromFrame) - contentH/2;
            y = MAX(8, MIN(y, screenH - contentH - 8));
            contentFrame = CGRectMake(CGRectGetMinX(fromFrame) - contentW - self.arrowSize.height, y, contentW, contentH);
        } break;
        case CCPopoverArrowDirectionNone: {
            contentFrame = CGRectMake((screenW - contentW)/2, (screenH - contentH)/2, contentW, contentH);
        } break;
    }
    
    UIBezierPath *path = [self createBackgroundPathWithFrame:contentFrame fromRect:fromFrame];
    if (!self.backgroundLayer) {
        self.backgroundLayer = [CAShapeLayer layer];
        [self.layer addSublayer:self.backgroundLayer];
    }
    self.backgroundLayer.path = path.CGPath;
    self.backgroundLayer.fillColor = UIColor.whiteColor.CGColor;
    self.backgroundLayer.shadowColor = UIColor.blackColor.CGColor;
    self.backgroundLayer.shadowOpacity = 0.15;
    self.backgroundLayer.shadowRadius = 4;
    
    self.contentView.frame = contentFrame;
    [self addSubview:self.contentView];
    [window addSubview:self];
    
    self.alpha = 0;
    self.contentView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
        self.contentView.transform = CGAffineTransformIdentity;
    }];
}

- (UIBezierPath *)createBackgroundPathWithFrame:(CGRect)frame fromRect:(CGRect)fromRect {
    CGFloat radius = 8;
    CGFloat arrowW = self.arrowSize.width;
    CGFloat arrowH = self.arrowSize.height;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat minX = CGRectGetMinX(frame);
    CGFloat maxX = CGRectGetMaxX(frame);
    CGFloat minY = CGRectGetMinY(frame);
    CGFloat maxY = CGRectGetMaxY(frame);
    
    // 省略具体绘制逻辑，保持原有代码
    
    return path;
}

- (void)onBackgroundTap {
    if (self.dismissOnBackgroundTap) {
        [self dismiss];
    }
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        self.contentView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self.maskColor setFill];
    UIRectFillUsingBlendMode(rect, kCGBlendModeNormal);
}

@end

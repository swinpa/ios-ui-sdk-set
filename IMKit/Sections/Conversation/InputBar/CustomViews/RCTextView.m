//
//  RCTextView.m
//  RongExtensionKit
//
//  Created by Liv on 14/10/30.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "RCTextView.h"

@implementation RCTextView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _disableActionMenu = NO;
    }
    return self;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.disableActionMenu) {
        return NO;
    }
    
    return [super canPerformAction:action withSender:sender];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _disableActionMenu = NO;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (self.textChangeDelegate && [self.textChangeDelegate respondsToSelector:@selector(rctextView:textDidChange:)]) {
        [self.textChangeDelegate rctextView:self textDidChange:text];
    }
}

- (void)paste:(id)sender {
    self.isPasting = YES;
    [super paste:sender];
    // 延迟清除标志，防止误判
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        self.isPasting = NO;
    });
}


@end

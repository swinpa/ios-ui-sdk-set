//
//  XSRCChatSessionInputToolBar.m
//  RongCloudOpenSource
//
//  Created by laowu on 2025/8/28.
//

#import "XSRCChatSessionInputToolBar.h"
#import "RCKitCommonDefine.h"

@interface XSRCChatSessionInputToolBar ()

@property (strong, nonatomic) UIStackView *stackView;

@end

@implementation XSRCChatSessionInputToolBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setupView {
    [super setupView];
    [self addSubview:self.stackView];
}

- (RCButton *)albumButton {
    if (!_albumButton) {
        _albumButton = [[RCButton alloc] initWithFrame:CGRectZero];
        [_albumButton setImage:XSRCResourceImage(@"icon_im_conversatoin_inputbar_abulum",@"")
                           forState:UIControlStateNormal];
        [_albumButton setExclusiveTouch:YES];
        [_albumButton addTarget:self
                              action:@selector(didClickAlbumButton:)
                    forControlEvents:UIControlEventTouchUpInside];
    }
    return _albumButton;
}

- (RCButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [[RCButton alloc] initWithFrame:CGRectZero];
        [_cameraButton setImage:XSRCResourceImage(@"icon_im_conversatoin_inputbar_camera",@"xs_im")
                           forState:UIControlStateNormal];
        [_cameraButton setExclusiveTouch:YES];
        [_cameraButton addTarget:self
                              action:@selector(didClickCameraButton:)
                    forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (RCButton *)giftButton {
    if (!_giftButton) {
        _giftButton = [[RCButton alloc] initWithFrame:CGRectZero];
        [_giftButton setImage:XSRCResourceImage(@"icon_im_conversatoin_inputbar_gift",@"xs_im")
                           forState:UIControlStateNormal];
        [_giftButton setExclusiveTouch:YES];
        [_giftButton addTarget:self
                              action:@selector(didClickGiftButton:)
                    forControlEvents:UIControlEventTouchUpInside];
    }
    return _giftButton;
}

- (RCButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [[RCButton alloc] initWithFrame:CGRectZero];
        [_emojiButton setImage:XSRCResourceImage(@"icon_im_conversatoin_inputbar_emoji",@"xs_im")
                           forState:UIControlStateNormal];
        [_emojiButton setExclusiveTouch:YES];
        [_emojiButton addTarget:self
                              action:@selector(didClickEmojiButton:)
                    forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiButton;
}


- (UIStackView *)stackView {
    if (!_stackView) {
        _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
            self.albumButton,
            self.cameraButton,
            self.giftButton,
            self.emojiButton
        ]];
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.alignment = UIStackViewAlignmentCenter;   // 垂直居中
        _stackView.distribution = UIStackViewDistributionEqualSpacing; // 等间距
        _stackView.spacing = 0;
    }
    return _stackView;
}



- (void)makeLayout {
    CGFloat topBottomMargin = 10.0;
    CGFloat buttonSize = 28.0;
    CGFloat sideMargin = 33.0;

    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.albumButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.giftButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.emojiButton.translatesAutoresizingMaskIntoConstraints = NO;


    // StackView 左右上下约束
    [NSLayoutConstraint activateConstraints:@[
        [self.stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:sideMargin],
        [self.stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-sideMargin],
        [self.stackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:topBottomMargin],
        [self.stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-topBottomMargin]
    ]];

    // 按钮固定大小
    for (UIButton *button in self.stackView.arrangedSubviews) {
        [NSLayoutConstraint activateConstraints:@[
            [button.widthAnchor constraintEqualToConstant:buttonSize],
            [button.heightAnchor constraintEqualToConstant:buttonSize]
        ]];
    }

    // 组件高度 = 按钮高度 + 上下间距
    [NSLayoutConstraint activateConstraints:@[
        [self.heightAnchor constraintEqualToConstant:(topBottomMargin * 2 + buttonSize)]
    ]];
}

- (void)didClickAlbumButton:(UIButton *)sender {
    
}
- (void)didClickCameraButton:(UIButton *)sender {
    
}

- (void)didClickGiftButton:(UIButton *)sender {
    
}
- (void)didClickEmojiButton:(UIButton *)sender {
    
}

@end

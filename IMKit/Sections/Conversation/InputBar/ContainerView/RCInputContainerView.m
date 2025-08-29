//
//  RCInputContainerView.m
//  RongIMKit
//
//  Created by 张改红 on 2020/5/26.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCInputContainerView.h"
#import "RCKitCommonDefine.h"
#import "RCChatSessionInputBarControl.h"
#import "RCExtensionService.h"
#import "RCKitConfig.h"
#define TextViewLineHeight 20.f              //输入框每行文字高度
#define TextViewSpaceHeight_LessThanMax 17.f //输入框小于最大行时除文字外上下空隙高度
#define TextViewSpaceHeight 13.f             //输入框大于等于最大行时除文字外上下空隙高度
#define TextViewRectY 7
#define TextViewMaxInputLines 6 //输入框最大行数设置
#define TextViewMinInputLines 1 //输入框最小行数设置
@interface RCInputContainerView ()<UITextViewDelegate, RCTextViewDelegate,XSRCChatSessionInputToolBarDelegate>
{
    BOOL _hideEmojiButton;
}
@property (nonatomic, strong) NSMutableArray *inputContainerSubViewConstraints;
@property (nonatomic, assign) BOOL textViewBeginEditing;
@property (nonatomic, assign) RCChatSessionInputBarControlStyle style;
@property (nonatomic, strong) UIView *inputContainer;



@end
@implementation RCInputContainerView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self rcinit];
    }
    return self;
}

- (void)rcinit {
    self.maxInputLines = 4;
}

- (BOOL)hideEmojiButton {
    return _hideEmojiButton;
}

- (void)setHideEmojiButton:(BOOL)hideEmojiButton {
    if (hideEmojiButton != _hideEmojiButton) {
        _hideEmojiButton = hideEmojiButton;
        [self resetInputContainerView];
        [self setupSubViews];
        [self setLayoutForInputContainerView:self.style];
    }
}
#pragma mark - Public API
- (void)setInputBarStyle:(RCChatSessionInputBarControlStyle)style {
    self.style = style;
    [self resetInputContainerView];
    [self setupSubViews];
    [self setLayoutForInputContainerView:style];
}

- (void)setBottomBarWithStatus:(KBottomBarStatus)bottomBarStatus {
    _currentBottomBarStatus = bottomBarStatus;
    switch (bottomBarStatus) {
    case KBottomBarRecordStatus: {
        [self inputTextViewBecomeFirstResponder:NO];
        [self switchToRecord];
    } break;
    case KBottomBarKeyboardStatus: {
        [self inputTextViewBecomeFirstResponder:YES];
        [self showInputTextView];
    } break;
    case KBottomBarDestructStatus:
        [self beginDestructMsgMode];
    case KBottomBarDefaultStatus:
    case KBottomBarPluginStatus:
    case KBottomBarEmojiStatus:
    case KBottomBarCommonPhrasesStatus:
    default:
        [self inputTextViewBecomeFirstResponder:NO];
        [self showInputTextView];
        break;
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL isShould = [self.delegate inputTextView:textView shouldChangeTextInRange:range replacementText:text];
    if ([text isEqualToString:@"\n"]) {
        self.inputTextView.text = @"";
        [self textViewDidChange:textView];
    }else{
        [self changeInputTextViewRange];
    }
    
    [[RCExtensionService sharedService] inputTextViewDidChange:textView inInputBar:(RCChatSessionInputBarControl *)self.superview];
    return isShould;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
     DebugLog(@"%s, %@", __FUNCTION__, textView);
    self.textViewBeginEditing = YES;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    DebugLog(@"%s, %@", __FUNCTION__, textView.text);
    self.textViewBeginEditing = NO;
    // filter the space
}

- (void)textViewDidChange:(UITextView *)textView {
    [self inputTextViewDidChange:textView];
}

#pragma mark - RCTextViewDelegate
- (void)rctextView:(RCTextView *)textView textDidChange:(NSString *)text {
    [self.inputTextView layoutIfNeeded];
    [self inputTextViewDidChange:textView];
}

#pragma mark - Target Action
- (void)switchInputBoxOrRecord {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerViewSwitchButtonClicked:)]) {
        [self.delegate inputContainerViewSwitchButtonClicked:self];
    }
}

- (void)voiceRecordButtonTouchDown:(UIButton *)sender {
    sender.backgroundColor = RCDYCOLOR(0xe0e2e3,0x323232);
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerView:forControlEvents:)]) {
        [self.delegate inputContainerView:self forControlEvents:UIControlEventTouchDown];
    }
}

- (void)voiceRecordButtonTouchUpInside:(UIButton *)sender {
    sender.backgroundColor = RCDYCOLOR(0xffffff,0x2d2d2d);
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerView:forControlEvents:)]) {
        [self.delegate inputContainerView:self forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)voiceRecordButtonTouchCancel:(UIButton *)sender {
    sender.backgroundColor = RCDYCOLOR(0xffffff,0x2d2d2d);
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerView:forControlEvents:)]) {
        [self.delegate inputContainerView:self forControlEvents:UIControlEventTouchCancel];
    }
}

- (void)voiceRecordButtonTouchDragExit:(UIButton *)sender {
    sender.backgroundColor = RCDYCOLOR(0xffffff,0x2d2d2d);
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerView:forControlEvents:)]) {
        [self.delegate inputContainerView:self forControlEvents:UIControlEventTouchDragExit];
    }
}

- (void)voiceRecordButtonTouchDragEnter:(UIButton *)sender {
    sender.backgroundColor = RCDYCOLOR(0xe0e2e3,0x323232);
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerView:forControlEvents:)]) {
        [self.delegate inputContainerView:self forControlEvents:UIControlEventTouchDragEnter];
    }
}

- (void)voiceRecordButtonTouchUpOutside:(UIButton *)sender {
    sender.backgroundColor = RCDYCOLOR(0xffffff,0x323232);
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerView:forControlEvents:)]) {
        [self.delegate inputContainerView:self forControlEvents:UIControlEventTouchUpOutside];
    }
}

- (void)didTouchEmojiDown:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerViewEmojiButtonClicked:)]) {
        [self.delegate inputContainerViewEmojiButtonClicked:self];
    }
}

- (void)didTouchAddtionalDown:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerViewAdditionalButtonClicked:)]) {
        [self.delegate inputContainerViewAdditionalButtonClicked:self];
    }
    
    if (self.destructMessageMode) {
        [self endDestructMsgMode];
    }
}

#pragma mark - Private Methods
- (void)inputTextViewDidChange:(UITextView *)textView{
    [self changeInputTextViewRange];
    [[RCExtensionService sharedService] inputTextViewDidChange:textView inInputBar:(RCChatSessionInputBarControl *)self.superview];
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidChange:)]) {
        [self.delegate inputTextViewDidChange:textView];
    }
}

- (void)beginDestructMsgMode {
    self.destructMessageMode = YES;
    [self.switchButton setImage:RCResourceImage(self.recordButton.hidden ? @"voice_burn" : @"keyboard_burn")
                       forState:UIControlStateNormal];
    [self.switchButton setImage:RCResourceImage(self.recordButton.hidden ? @"voice_burn" : @"keyboard_burn")
                       forState:UIControlStateHighlighted];
    [self.additionalButton setImage:RCResourceImage(@"close_burn") forState:UIControlStateNormal];
    [self.emojiButton setImage:RCResourceImage(@"photo_burn") forState:UIControlStateNormal];

    [self.recordButton setTitleColor:HEXCOLOR(0xF4B50B) forState:UIControlStateNormal];
    self.recordButton.layer.borderWidth = 0.5;
    self.recordButton.layer.borderColor = HEXCOLOR(0xFA9d3b).CGColor;
}

- (void)endDestructMsgMode {
    self.destructMessageMode = NO;
    [self.switchButton setImage:RCResourceImage(self.recordButton.hidden ? @"inputbar_voice"
                                                                                  : @"inputbar_keyboard")
                       forState:UIControlStateNormal];
    [self.additionalButton setImage:RCResourceImage(@"inputbar_add")
                           forState:UIControlStateNormal];
    [self.emojiButton setImage:RCResourceImage(@"inputbar_emoji") forState:UIControlStateNormal];
    [self.recordButton setTitleColor:RCDYCOLOR(0x000000, 0xffffff) forState:UIControlStateNormal];
    self.recordButton.layer.borderWidth = 0;
    self.recordButton.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)inputTextViewBecomeFirstResponder:(BOOL)isBecome {
    if (isBecome && ![self.inputTextView isFirstResponder]) {
        [self.inputTextView becomeFirstResponder];
    }
    if (!isBecome && [self.inputTextView isFirstResponder]) {
        [self.inputTextView resignFirstResponder];
    }
}

#pragma mark - UI
- (void)setupSubViews {
    
    if(self.style == RC_CHAT_INPUT_BAR_STYLE_TOOLBAR) {
        
        [self addSubview:self.inputTextView];
        [self addSubview:self.recordButton];
        [self addSubview:self.switchButton];
//        
//        [self addSubview:self.inputContainer];
        [self addSubview:self.toolBar];
    }else{
        [self addSubview:self.switchButton];
        [self addSubview:self.inputTextView];
        [self addSubview:self.recordButton];
        [self addSubview:self.emojiButton];
        [self addSubview:self.additionalButton];
    }
    
//    [self addSubview:self.switchButton];
//    [self addSubview:self.inputTextView];
//    [self addSubview:self.recordButton];
//    [self addSubview:self.emojiButton];
//    [self addSubview:self.additionalButton];
//    [self addSubview:self.toolBar];
}

- (void)showInputTextView {
    [self layoutInputBoxUIIfNeed];
    [self updateButtonImage];
}

- (void)switchToRecord {
    [self layoutInputBoxUIIfNeed];
    [self updateButtonImage];
}

- (void)updateButtonImage {
    if (self.currentBottomBarStatus != KBottomBarEmojiStatus) {
        if (self.destructMessageMode) {
            [self.emojiButton setImage:RCResourceImage(@"photo_burn") forState:UIControlStateNormal];
        } else {
            [self.emojiButton setImage:RCResourceImage(@"inputbar_emoji")
                              forState:UIControlStateNormal];
        }
    } else {
        [self.emojiButton setImage:RCResourceImage(@"inputbar_keyboard")
                          forState:UIControlStateNormal];
    }

    if (self.destructMessageMode) {
        [self.switchButton
            setImage:RCResourceImage(self.recordButton.hidden ? @"voice_burn" : @"keyboard_burn")
            forState:UIControlStateNormal];
    } else {
        [self.switchButton setImage:RCResourceImage(self.recordButton.hidden ? @"inputbar_voice"
                                                                                      : @"inputbar_keyboard")
                           forState:UIControlStateNormal];
    }
}

- (void)layoutInputBoxUIIfNeed {
    CGFloat changedBeforeHeight = self.frame.size.height;
     CGRect rectFrame = self.frame;
    if (self.currentBottomBarStatus == KBottomBarRecordStatus) {
        self.inputTextView.hidden = YES;
        self.recordButton.hidden = NO;
        rectFrame.size.height = RC_ChatSessionInputBarHeight(self.style);
    }else{
        self.recordButton.hidden = YES;
        self.inputTextView.hidden = NO;

        self.inputTextView.frame = [self getInputTextViewFrame];
        rectFrame.size.height = RC_ChatSessionInputBarHeight(self.style) +
                                (self.inputTextView.frame.size.height - [self getTextViewHeightWithLines:1]);
    }
    
    if (changedBeforeHeight != rectFrame.size.height) {
        self.frame = rectFrame;
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerView:didChangeFrame:)]) {
            [self.delegate inputContainerView:self didChangeFrame:self.frame];
        }
    }
}

- (void)changeInputTextViewRange {
    CGFloat changedBeforeHeight = self.frame.size.height;
    [self layoutInputBoxUIIfNeed];
    if (changedBeforeHeight != self.frame.size.height && self.inputTextView.text > 0) {
        [UIView animateWithDuration:0.5 animations:^{
            [self.inputTextView scrollRangeToVisible:[self.inputTextView selectedRange]];
        }];
    }
}

- (CGRect)getInputTextViewFrame {
    CGFloat inputTextview_height = [self getTextViewHeightWithLines:1];
    if (self.inputTextView.contentSize.height > [self getTextViewHeightWithLines:1] &&
        self.inputTextView.contentSize.height <= [self getTextViewHeightWithLines:self.maxInputLines - 1]) {
        inputTextview_height = self.inputTextView.contentSize.height;
    }
    if (self.inputTextView.contentSize.height > [self getTextViewHeightWithLines:self.maxInputLines - 1]) {
        inputTextview_height = [self getTextViewHeightWithLines:self.maxInputLines];
    }
    CGRect inputTextRect = self.inputTextView.frame;
    inputTextRect.size.height = inputTextview_height;
    inputTextRect.origin.y = TextViewRectY;
    return inputTextRect;
}

- (CGFloat)getTextViewHeightWithLines:(NSInteger)lines {
    CGFloat totalHeight = lines * TextViewLineHeight + TextViewSpaceHeight_LessThanMax;
    if (lines >= self.maxInputLines) {
        totalHeight = lines * TextViewLineHeight + TextViewSpaceHeight;
    }
    return totalHeight;
}

- (void)resetInputContainerView {
    if (self.inputContainerSubViewConstraints.count > 0) {
        [self removeConstraints:self.inputContainerSubViewConstraints];
        [self.inputContainerSubViewConstraints removeAllObjects];
    }

    if (self.switchButton) {
        [self.switchButton removeFromSuperview];
        self.switchButton = nil;
    }
    if (self.recordButton) {
        [self.recordButton removeFromSuperview];
        self.recordButton = nil;
    }
    if (self.inputTextView) {
        [self.inputTextView removeFromSuperview];
        if (self.inputTextView.text.length <= 0) {
            self.inputTextView = nil;
        }
    }
    if (self.emojiButton) {
        [self.emojiButton removeFromSuperview];
        self.emojiButton = nil;
    }
    if (self.additionalButton) {
        [self.additionalButton removeFromSuperview];
        self.additionalButton = nil;
    }
    if (self.inputContainer) {
        [self.inputContainer removeFromSuperview];
        self.inputContainer = nil;
    }
    if (self.toolBar) {
        [self.toolBar removeFromSuperview];
        self.toolBar = nil;
    }
}


// 设置输入容器布局方法，根据不同的样式 style 排列按钮
- (void)setLayoutForInputContainerView:(RCChatSessionInputBarControlStyle)style {
    // 关闭自动将 AutoresizingMask 转换为 AutoLayout 约束（手动写约束需要关闭）
    self.switchButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.recordButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.emojiButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.additionalButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 将子视图绑定成字典，供 VFL（Visual Format Language）使用
    NSDictionary *_bindingViews =
        NSDictionaryOfVariableBindings(_switchButton, _inputTextView, _recordButton, _emojiButton, _additionalButton);

    // 存放水平布局的 VFL 格式字符串
    NSString *format;

    // 根据不同的 style，决定按钮水平排列顺序
    switch (style) {
    case RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION:
        // 顺序：左 -> switchButton -> recordButton -> emojiButton -> additionalButton -> 右
        format = @"H:|-8-[_switchButton(BUTTONWIDTH)]-8-[_recordButton]-8-[_emojiButton(EMOJIBUTTONWIDTH)]-8-[_additionalButton(BUTTONWIDTH)]-8-|";
        break;
    case RC_CHAT_INPUT_BAR_STYLE_EXTENTION_CONTAINER_SWITCH:
        // 顺序：左 -> additionalButton -> recordButton -> emojiButton -> switchButton -> 右
        format = @"H:|-8-[_additionalButton(BUTTONWIDTH)]-8-[_recordButton]-8-[_emojiButton(EMOJIBUTTONWIDTH)]-8-[_switchButton(BUTTONWIDTH)]-8-|";
        break;
    case RC_CHAT_INPUT_BAR_STYLE_CONTAINER_SWITCH_EXTENTION:
        // 顺序：左 -> recordButton -> emojiButton -> switchButton -> additionalButton -> 右
        format = @"H:|-8-[_recordButton]-8-[_emojiButton(EMOJIBUTTONWIDTH)]-8-[_switchButton(BUTTONWIDTH)]-8-[_additionalButton(BUTTONWIDTH)]-8-|";
        break;
    case RC_CHAT_INPUT_BAR_STYLE_CONTAINER_EXTENTION_SWITCH:
        // 顺序：左 -> recordButton -> emojiButton -> additionalButton -> switchButton -> 右
        format = @"H:|-8-[_recordButton]-8-[_emojiButton(EMOJIBUTTONWIDTH)]-8-[_additionalButton(BUTTONWIDTH)]-8-[_switchButton(BUTTONWIDTH)]-8-|";
        break;
    case RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER:
        // 顺序：左 -> switchButton -> recordButton -> emojiButton -> additionalButton(隐藏) -> 右
        format = @"H:|-8-[_switchButton(BUTTONWIDTH)]-8-[_recordButton]-8-[_emojiButton(EMOJIBUTTONWIDTH)]-8-[_additionalButton(0)]-8-|";
        break;
    case RC_CHAT_INPUT_BAR_STYLE_CONTAINER_SWITCH:
        // 顺序：左 -> recordButton -> emojiButton -> switchButton -> additionalButton(隐藏) -> 右
        format = @"H:|-8-[_recordButton]-8-[_emojiButton(EMOJIBUTTONWIDTH)]-8-[_switchButton(BUTTONWIDTH)]-8-[_additionalButton(0)]-8-|";
        break;
    case RC_CHAT_INPUT_BAR_STYLE_EXTENTION_CONTAINER:
        // 顺序：左 -> additionalButton -> recordButton -> emojiButton -> switchButton(隐藏) -> 右
        format = @"H:|-8-[_additionalButton(BUTTONWIDTH)]-8-[_recordButton]-8-[_emojiButton(EMOJIBUTTONWIDTH)]-8-[_switchButton(0)]-8-|";
        break;
    case RC_CHAT_INPUT_BAR_STYLE_CONTAINER_EXTENTION:
        // 顺序：左 -> recordButton -> emojiButton -> additionalButton -> switchButton(隐藏) -> 右
        format = @"H:|-8-[_recordButton]-8-[_emojiButton(EMOJIBUTTONWIDTH)]-8-[_additionalButton(BUTTONWIDTH)]-8-[_switchButton(0)]-8-|";
        break;
    case RC_CHAT_INPUT_BAR_STYLE_CONTAINER:
        // 顺序：左 -> switchButton(隐藏) -> recordButton -> emojiButton -> additionalButton(隐藏) -> 右
        format = @"H:|-0-[_switchButton(0)]-8-[_recordButton]-8-[_emojiButton(EMOJIBUTTONWIDTH)]-8-[_additionalButton(0)]-8-|";
        break;
    case RC_CHAT_INPUT_BAR_STYLE_TOOLBAR:
        // 顺序：左 -> switchButton(隐藏) -> recordButton -> emojiButton -> additionalButton(隐藏) -> 右
        format = @"H:|-16-[_recordButton]-8-[_switchButton(BUTTONWIDTH)]-16-|";
        break;
    default:
        break;
    }

    // 如果需要隐藏 emoji 按钮，宽度设为 0，否则宽度为 32
    NSInteger emojiBtnWidth = self.hideEmojiButton ? 0 : 32;

    CGFloat BUTTONWIDTH = 32;
    if (self.style == RC_CHAT_INPUT_BAR_STYLE_TOOLBAR) {
        BUTTONWIDTH = 36;
    }
    
    // 添加水平约束（按钮排列顺序）
    [self.inputContainerSubViewConstraints
        addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                    options:0
                                                                    metrics:@{@"BUTTONWIDTH":@(BUTTONWIDTH), @"EMOJIBUTTONWIDTH":@(emojiBtnWidth)}
                                                                      views:_bindingViews]];
    // switchButton 的垂直约束：顶部 8.5，高度 32
    if(self.style == RC_CHAT_INPUT_BAR_STYLE_TOOLBAR){
        
        // 让 recordButton 的右边和 inputTextView 右边对齐
        [self.inputContainerSubViewConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:self.switchButton
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:(NSLayoutRelationEqual)
                                            toItem:self.inputTextView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1
                                          constant:-2.83]]];
    }else{
        [self.inputContainerSubViewConstraints
            addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8.5-[_switchButton(BUTTONWIDTH)]"
                                                                        options:0
                                                                        metrics:@{@"BUTTONWIDTH":@(32)}
                                                                          views:_bindingViews]];
    }
    // recordButton 的垂直约束：顶部 6，高度 36（稍高于其他按钮）
    [self.inputContainerSubViewConstraints
        addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_recordButton(36)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:_bindingViews]];

   
    if(self.style != RC_CHAT_INPUT_BAR_STYLE_TOOLBAR){
        // emojiButton 的垂直约束：顶部 8.5，高度 32
        [self.inputContainerSubViewConstraints
         addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8.5-[_emojiButton(BUTTONWIDTH)]"
                                                                     options:kNilOptions
                                                                     metrics:@{@"BUTTONWIDTH":@(32)}
                                                                       views:_bindingViews]];
        // additionalButton 的垂直约束：顶部 8.5，高度 32
        [self.inputContainerSubViewConstraints
            addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8.5-[_additionalButton(BUTTONWIDTH)]"
                                                                        options:kNilOptions
                                                                        metrics:@{@"BUTTONWIDTH":@(32)}
                                                                          views:_bindingViews]];
    }

    
    
    // 让 recordButton 的左边和 inputTextView 左边对齐
    [self.inputContainerSubViewConstraints addObjectsFromArray:@[
        [NSLayoutConstraint constraintWithItem:self.recordButton
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:(NSLayoutRelationEqual)
                                        toItem:self.inputTextView
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1
                                      constant:0]]];
    
    // 让 recordButton 的右边和 inputTextView 右边对齐
    [self.inputContainerSubViewConstraints addObjectsFromArray:@[
        [NSLayoutConstraint constraintWithItem:self.recordButton
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:(NSLayoutRelationEqual)
                                        toItem:self.inputTextView
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1
                                      constant:0]]];
    
    // 让 recordButton 的顶部和 inputTextView 顶部对齐
    [self.inputContainerSubViewConstraints addObjectsFromArray:@[
        [NSLayoutConstraint constraintWithItem:self.recordButton
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:(NSLayoutRelationEqual)
                                        toItem:self.inputTextView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1
                                      constant:0]]];
    if(style == RC_CHAT_INPUT_BAR_STYLE_TOOLBAR) {
        // 让 inputTextView 的底部距离父视图底部 6
        [self.inputContainerSubViewConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:self.inputTextView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:(NSLayoutRelationEqual)
                                            toItem:self.toolBar
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1
                                          constant:-6]]];
        
        // 添加约束
        [NSLayoutConstraint activateConstraints:@[
            // toolBar 左边与父视图左边对齐
            [self.toolBar.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0],
            
            // toolBar 右边与父视图右边对齐
            [self.toolBar.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0],
            
            // toolBar 顶部距离 inputTextView 底部 10
            [self.toolBar.topAnchor constraintEqualToAnchor:self.inputTextView.bottomAnchor constant:10],
            
            // toolBar 高度固定 48.0
            [self.toolBar.heightAnchor constraintEqualToConstant:48.0],
            
            // toolBar 底部与父视图底部对齐
            [self.toolBar.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0]
        ]];
        
    }else{
        [self.inputContainerSubViewConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:self.inputTextView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:(NSLayoutRelationEqual)
                                            toItem:self
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1
                                          constant:-6]]];
    }
    // 将所有约束一次性加到父视图
    [self addConstraints:self.inputContainerSubViewConstraints];
    // 通知系统更新约束并刷新布局
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}


#pragma mark - Getter & Setter
- (RCButton *)switchButton {
    if (!_switchButton) {
        _switchButton = [[RCButton alloc] initWithFrame:CGRectZero];
        [_switchButton setImage:RCResourceImage(@"inputbar_voice")
                       forState:UIControlStateNormal];
        [_switchButton addTarget:self
                          action:@selector(switchInputBoxOrRecord)
                forControlEvents:UIControlEventTouchUpInside];
        [_switchButton setExclusiveTouch:YES];
    }
    return _switchButton;
}

- (RCTextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[RCTextView alloc] initWithFrame:CGRectZero];
        _inputTextView.delegate = self;
        _inputTextView.textChangeDelegate = self;
        UIEdgeInsets textEdge = self.inputTextView.textContainerInset;
        textEdge.left = 5;
        textEdge.right = 5;
        _inputTextView.textContainerInset = textEdge;
        [_inputTextView setExclusiveTouch:YES];
//        [_inputTextView setTextColor:[RCKitUtility generateDynamicColor:HEXCOLOR(0x999999) darkColor:RCMASKCOLOR(0xffffff, 0.8)]];
        [_inputTextView setTextColor:HEXCOLOR(0x999999)];
        [_inputTextView setFont:[[RCKitConfig defaultConfig].font fontOfSecondLevel]];
        [_inputTextView setReturnKeyType:UIReturnKeySend];
        _inputTextView.backgroundColor = HEXCOLOR(0xF7F7F7);//RCDYCOLOR(0xffffff, 0x2d2d2d);
        _inputTextView.enablesReturnKeyAutomatically = YES;
        _inputTextView.layer.cornerRadius = 8;
        _inputTextView.layer.masksToBounds = YES;
        [_inputTextView setAccessibilityLabel:@"chat_input_textView"];
        _inputTextView.tintColor = HEXCOLOR(0x11D8C3);
    }
    return _inputTextView;
}

- (RCButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [[RCButton alloc] initWithFrame:CGRectZero];
        [_recordButton setExclusiveTouch:YES];
        [_recordButton setHidden:YES];
        [_recordButton setTitle:RCLocalizedString(@"hold_to_talk_title") forState:UIControlStateNormal];
        _recordButton.titleLabel.font = [[RCKitConfig defaultConfig].font fontOfGuideLevel];
        [_recordButton setTitle:RCLocalizedString(@"release_to_send_title")
                       forState:UIControlStateHighlighted];
        [_recordButton setTitleColor:RCDYCOLOR(0x999999, 0xffffff) forState:UIControlStateNormal];
        _recordButton.backgroundColor = HEXCOLOR(0xF7F7F7);//RCDYCOLOR(0xffffff,0x2d2d2d);
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchDown:)
                forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchUpInside:)
                forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchUpOutside:)
                forControlEvents:UIControlEventTouchUpOutside];
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchDragExit:)
                forControlEvents:UIControlEventTouchDragExit];
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchDragEnter:)
                forControlEvents:UIControlEventTouchDragEnter];
        [_recordButton addTarget:self
                          action:@selector(voiceRecordButtonTouchCancel:)
                forControlEvents:UIControlEventTouchCancel];
        _recordButton.layer.cornerRadius = 8;
        _recordButton.layer.masksToBounds = YES;
    }
    return _recordButton;
}

- (RCButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [[RCButton alloc] initWithFrame:CGRectZero];
        [_emojiButton setImage:RCResourceImage(@"inputbar_emoji") forState:UIControlStateNormal];
        [_emojiButton setExclusiveTouch:YES];
        [_emojiButton addTarget:self action:@selector(didTouchEmojiDown:) forControlEvents:UIControlEventTouchUpInside];
        _emojiButton.hidden = self.hideEmojiButton;
    }
    return _emojiButton;
}

- (RCButton *)additionalButton {
    if (!_additionalButton) {
        _additionalButton = [[RCButton alloc] initWithFrame:CGRectZero];
        [_additionalButton setImage:RCResourceImage(@"inputbar_add")
                           forState:UIControlStateNormal];
        [_additionalButton setExclusiveTouch:YES];
        [_additionalButton addTarget:self
                              action:@selector(didTouchAddtionalDown:)
                    forControlEvents:UIControlEventTouchUpInside];
    }
    return _additionalButton;
}

- (UIView *)inputContainer {
    if (!_inputContainer) {
        _inputContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _inputContainer.backgroundColor = HEXCOLOR(0xF7F7F7);
    }
    return _inputContainer;
}

- (XSRCChatSessionInputToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[XSRCChatSessionInputToolBar alloc] initWithFrame:CGRectZero];
        _toolBar.delegate = self;
    }
    return _toolBar;
}

- (NSMutableArray *)inputContainerSubViewConstraints {
    if (!_inputContainerSubViewConstraints) {
        _inputContainerSubViewConstraints = [[NSMutableArray alloc] init];
    }
    return _inputContainerSubViewConstraints;
}

- (void)setMaxInputLines:(NSInteger)maxInputLines {
    if (maxInputLines > TextViewMaxInputLines) {
        maxInputLines = TextViewMaxInputLines;
    }
    if (maxInputLines < TextViewMinInputLines) {
        maxInputLines = TextViewMinInputLines;
    }
    _maxInputLines = maxInputLines;
}

- (void)handleButtonEvent:(UIButton*)button event:(XSRCChatSessionInputToolBarEvent)event {
    switch (event) {
        case XSRCChatSessionInputToolBarEventAlbum:
            if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerViewAlbumButtonClicked:)]) {
                [self.delegate inputContainerViewAlbumButtonClicked:self];
            }
            break;
        case XSRCChatSessionInputToolBarEventCamera:
            if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerViewCameraButtonClicked:)]) {
                [self.delegate inputContainerViewCameraButtonClicked:self];
            }
            break;
        case XSRCChatSessionInputToolBarEventGift:
            if (self.delegate && [self.delegate respondsToSelector:@selector(inputContainerViewGiftButtonClicked:)]) {
                [self.delegate inputContainerViewGiftButtonClicked:self];
            }
            break;
        case XSRCChatSessionInputToolBarEventEmoji:
            [self didTouchEmojiDown:button];
            break;
    }
}


@end

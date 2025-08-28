//
//  XSRCChatSessionInputToolBar.h
//  RongCloudOpenSource
//
//  Created by laowu on 2025/8/28.
//

#import "RCBaseView.h"
#import "RCButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface XSRCChatSessionInputToolBar : RCBaseView

/// 语音与文本输入切换的按钮
@property (strong, nonatomic) RCButton *albumButton;

/// 录制语音消息的按钮
@property (nonatomic, strong) RCButton *cameraButton;

/// 文本输入框
@property (nonatomic, strong) RCButton *giftButton;

/// 表情的按钮
@property (nonatomic, strong) RCButton *emojiButton;

@end

NS_ASSUME_NONNULL_END

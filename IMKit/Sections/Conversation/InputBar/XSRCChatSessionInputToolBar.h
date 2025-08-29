//
//  XSRCChatSessionInputToolBar.h
//  RongCloudOpenSource
//
//  Created by laowu on 2025/8/28.
//

#import "RCBaseView.h"
#import "RCButton.h"

NS_ASSUME_NONNULL_BEGIN


/*!
 输入工具栏事件
 */
typedef NS_ENUM(NSInteger, XSRCChatSessionInputToolBarEvent) {
    /*!
     相册按钮点击事件
     */
    XSRCChatSessionInputToolBarEventAlbum = 0,
    /*!
     相机按钮点击事件
     */
    XSRCChatSessionInputToolBarEventCamera = 1,
    /*!
     礼物按钮点击事件
     */
    XSRCChatSessionInputToolBarEventGift = 2,
    /*!
     表情按钮点击事件
     */
    XSRCChatSessionInputToolBarEventEmoji = 3
};


/*!
 输入工具栏的点击监听器
 */
@protocol XSRCChatSessionInputToolBarDelegate <NSObject>

/*!
 - Parameter event: 按钮事件
 */
- (void)handleButtonEvent:(UIButton*)button event:(XSRCChatSessionInputToolBarEvent)event;
@end


@interface XSRCChatSessionInputToolBar : RCBaseView

@property (nonatomic, weak) id<XSRCChatSessionInputToolBarDelegate> delegate;

/// 相册按钮
@property (nonatomic, strong) RCButton *albumButton;

/// 相机按钮
@property (nonatomic, strong) RCButton *cameraButton;

/// 礼物按钮
@property (nonatomic, strong) RCButton *giftButton;

/// 表情按钮
@property (nonatomic, strong) RCButton *emojiButton;

@end

NS_ASSUME_NONNULL_END

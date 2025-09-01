//
//  RCAlumListTableViewController.h
//  RongExtensionKit
//
//  Created by 张改红 on 16/3/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCBaseTableViewController.h"


typedef enum : NSUInteger {
    /// 同步远端消息成功失败都加载消息
    RCAlbumTypePhotos,
    /// 同步远端消息失败时询问是否加载本地消息
    RCAlbumTypeVideos,
    /// 同步远端消息成功再加载消息
    RCAlbumTypeAll,
} RCAlbumType;

@protocol RCAlbumListViewControllerDelegate;

@interface RCAlumListTableViewController : RCBaseTableViewController
@property (nonatomic, assign) RCAlbumType type;
@property (nonatomic, strong) NSArray *libraryList;
@property (nonatomic, weak) id<RCAlbumListViewControllerDelegate> delegate;
@end

@protocol RCAlbumListViewControllerDelegate <NSObject>

- (void)albumListViewController:(RCAlumListTableViewController *)albumListViewController
                 selectedImages:(NSArray *)selectedImages
                isSendFullImage:(BOOL)enable;

@end

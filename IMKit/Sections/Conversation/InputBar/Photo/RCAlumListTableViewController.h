//
//  RCAlumListTableViewController.h
//  RongExtensionKit
//
//  Created by 张改红 on 16/3/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCBaseTableViewController.h"

@protocol RCAlbumListViewControllerDelegate;
@interface RCAlumListTableViewController : RCBaseTableViewController
@property (nonatomic, strong) NSArray *libraryList;
@property (nonatomic, weak) id<RCAlbumListViewControllerDelegate> delegate;
@property (nonatomic, copy) void (^openCameraHandler)( void );
@property (nonatomic, assign) BOOL isHalfScreen;
- (void)dismissCurrentModelViewController;
@end

@protocol RCAlbumListViewControllerDelegate <NSObject>

- (void)albumListViewController:(RCAlumListTableViewController *)albumListViewController
                 selectedImages:(NSArray *)selectedImages
                isSendFullImage:(BOOL)enable;

@end

typedef void(^DidFinishPickingHandler)(UIImage *image,NSDictionary *editingInfo);

@interface UIImagePickerController (Block)

@property (nonatomic, copy,nullable) DidFinishPickingHandler finishPickingHandler;


@end

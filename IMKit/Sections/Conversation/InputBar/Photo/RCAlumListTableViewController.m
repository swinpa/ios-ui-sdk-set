//
//  RCAlumListTableViewController.m
//  RongExtensionKit
//
//  Created by 张改红 on 16/3/18.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCAlumListTableViewController.h"
#import "RCAlbumModel.h"
#import "RCAlbumTableCell.h"
#import "RCAssetModel.h"
#import "RCKitCommonDefine.h"
#import "RCPhotosPickerController.h"
#import "RCMBProgressHUD.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "RCKitConfig.h"
#import "RCAlertView.h"

static NSString *const cellReuseIdentifier = @"cell";

@interface RCAlumListTableViewController ()
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) RCMBProgressHUD *progressHUD;
@property (nonatomic, assign) BOOL isShowHUD;
@end

@implementation RCAlumListTableViewController
#pragma mark - Life Cycle
- (void)dealloc {
    
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.libraryList = [NSMutableArray new];
        self.type = RCAlbumTypeAll;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = RCLocalizedString(@"Albums");
    [self setNavigationItem];
    [self setupTableView];
    [self setAuthorizationStatusAuthorized];
    [self getDataSourceAndReloadView];
    [self configNavigationBar];
    self.view.backgroundColor = HEXCOLOR(0x1D1618);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.libraryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCAlbumTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell configCellWithItem:self.libraryList[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCAlbumModel *assetsGroup = self.libraryList[indexPath.row];
    [self pushImagePickerController:assetsGroup animated:YES];
}

#pragma mark - Private Methods
- (void)setNavigationItem{
    UIView *rightBarView = [[UIView alloc] init];
    rightBarView.frame = CGRectMake(0, 0, 80, 40);
    UILabel *doneTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    doneTitleLabel.text = RCLocalizedString(@"Cancel");
    if([RCKitUtility isRTL]){
        doneTitleLabel.textAlignment = NSTextAlignmentLeft;
    }else{
        doneTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    doneTitleLabel.font = [[RCKitConfig defaultConfig].font fontOfSecondLevel];
    
//    doneTitleLabel.textColor = [RCKitUtility
//                                generateDynamicColor:RCResourceColor(@"photoPicker_cancel", @"0x0099ff")
//                                darkColor:RCResourceColor(@"photoPicker_cancel", @"0x0099ff")];
//    
    doneTitleLabel.textColor = [UIColor whiteColor];
    [rightBarView addSubview:doneTitleLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCurrentModelViewController)];
    [rightBarView addGestureRecognizer:tap];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarView];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    
//    
    
    
}

- (void)configNavigationBar {
    if (@available(iOS 15.0, *)) {
        self.navigationController.navigationBar.translucent = NO;
        
        UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
        navigationBarAppearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]
        };
        
        navigationBarAppearance.buttonAppearance.normal.backgroundImagePositionAdjustment = UIOffsetMake(-20, 0);
        navigationBarAppearance.backButtonAppearance.normal.backgroundImagePositionAdjustment = UIOffsetMake(-20, 0);
        
        [navigationBarAppearance configureWithOpaqueBackground];
        
        navigationBarAppearance.backgroundColor = HEXCOLOR(0x1D1618);
        navigationBarAppearance.backgroundEffect = nil;
        
        navigationBarAppearance.shadowImage = [UIImage new];
        
        self.navigationController.navigationBar.standardAppearance = navigationBarAppearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance;
    } else {
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = HEXCOLOR(0x1D1618);
        
//        CGSize size = self.navigationController ? self.navigationController.navigationBar.bounds.size : CGSizeMake(screenWidth, 44 + safeTop);
//        [self.navigationController.navigationBar setBackgroundImage:[self.navigationBarBackgroundColor toImageWithSize:size] forBarMetrics:UIBarMetricsDefault];
//        
        self.navigationController.navigationBar.shadowImage = [UIImage new];
    }

}


- (void)setupTableView{
    [self.tableView registerClass:[RCAlbumTableCell class] forCellReuseIdentifier:cellReuseIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 65.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = HEXCOLOR(0x1D1618);
    self.tableView.separatorColor = RCMASKCOLOR(0xF7F7F7, 0.05);
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (void)getDataSourceAndReloadView{
    RCAssetHelper *sharedAssetHelper = [RCAssetHelper shareAssetHelper];
    NSArray *cacheAssetGroup = [sharedAssetHelper getCachePhotoGroups];
    if (cacheAssetGroup && cacheAssetGroup.count > 0) {
        self.libraryList = cacheAssetGroup;
        RCAlbumModel *assetsGroup = self.libraryList[0];
        //能获取到相册说明有权限，此时隐藏权限提示
        if (self.tipsLabel) {
            [self.tipsLabel setHidden:YES];
        }
        [self pushImagePickerController:assetsGroup animated:NO];
        [self.tableView reloadData];
    } else {
        [RCKitUtility showProgressViewFor:self.tableView text:nil animated:YES];
        
        NSInteger mediatype = 0;
        if(self.type == RCAlbumTypePhotos) {
            mediatype = 1;
        }else if(self.type == RCAlbumTypeVideos) {
            mediatype = 2;
        }
        
        [sharedAssetHelper
         getAlbumsFromSystem:mediatype completion:^(NSArray *assetGroup) {
                              if (assetGroup) {
                                  self.libraryList = assetGroup;
                              }
            
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  BOOL isFirstRun = [[NSUserDefaults standardUserDefaults] boolForKey:@"rckit_first_happen"];
                                  //处理过，不要再处理，除非重装app
                                  if (assetGroup.count == 0 && !isFirstRun) {
                                      if (@available(iOS 15, *)) {
                                          // nothing to do
                                      } else if (@available(iOS 14, *)) {
                                          [RCKitUtility hideProgressViewFor:self.tableView animated:YES];
                                          // 相册bug https://developer.apple.com/forums/thread/658114
                                          [RCAlertView showAlertController:RCLocalizedString(@"PhotoLibraryBugErrorAlert") message:nil actionTitles:nil cancelTitle:RCLocalizedString(@"Cancel") confirmTitle:RCLocalizedString(@"restartApp") preferredStyle:UIAlertControllerStyleAlert actionsBlock:nil cancelBlock:nil confirmBlock:^{
                                              // 首次发生并重启后问题解决，记录一下， 下次不必再处理此case
                                              [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"rckit_first_happen"];
                                              [[NSUserDefaults standardUserDefaults] synchronize];
                                              
                                              exit(0);
                                          } inViewController:self];
                                          
                                          return;
                                      } else {
                                          // nothing to do
                                      }
                                  }

                                  
                                  [RCKitUtility hideProgressViewFor:self.tableView animated:YES];

                                  if (self.libraryList.count) {
                                      RCAlbumModel *assetsGroup = self.libraryList[0];
                                      [self pushImagePickerController:assetsGroup animated:NO];
                                      //能获取到相册说明有权限，此时隐藏权限提示
                                      [self.tipsLabel setHidden:YES];
                                  } else {
                                      if ([[RCAssetHelper shareAssetHelper] hasAuthorizationStatusAuthorized]) {
                                          [self.tipsLabel setHidden:YES];
                                      }else{
                                          [self.tipsLabel setHidden:NO];
                                      }
                                  }
                                  [self.tableView reloadData];

                              });
                          }];
    }
}
- (NSString *)moveVideoFileAt:(NSString *)filePath {
    /*
     在发送之前拷贝一次, 是因为相册的文件路径, 再次访问时, 文件是不存在的, 只能使用
     临时目录(第一次发送失败后, 重启应用, 再次发送无法访问原相册目录)
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        long long millisecond = [[NSDate date] timeIntervalSince1970] * 1000;
        NSString *name = [NSString stringWithFormat:@"rongcloud_tmp_video_%lld.mp4", millisecond];
        NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
        NSError *error = nil;
        [fileManager copyItemAtPath:filePath toPath:localPath error:&error];
        if (error) {
            return filePath;
        }
        return localPath;
    }
    return filePath;
}

- (void)handlePhotos:(NSMutableArray *)photos result:(NSMutableArray *)results full:(BOOL)isFull {
    if (photos.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressHUD hideAnimated:YES];
            self.isShowHUD = NO;
            if ([self.delegate respondsToSelector:@selector(albumListViewController:selectedImages:isSendFullImage:)] &&
                results.count) {
                [self.delegate albumListViewController:nil selectedImages:results isSendFullImage:isFull];
            }
            [self dismissCurrentModelViewController];
        });
    } else {
        RCAssetModel *model = [photos objectAtIndex:0];
        [photos removeObjectAtIndex:0];
        if (model.mediaType == PHAssetMediaTypeVideo && NSClassFromString(@"RCSightCapturer")) {
            [self p_getOriginVideo:model photos:photos result:results full:isFull];
        } else {
            [self p_getOriginImageData:model photos:photos result:results full:isFull];
        }
    }
}

- (void)p_getOriginVideo:(RCAssetModel *)model photos:(NSMutableArray *)photos result:(NSMutableArray *)results full:(BOOL)isFull{
    __weak typeof(self) weakSelf = self;
    [[RCAssetHelper shareAssetHelper] getOriginVideoWithAsset:model.asset
        result:^(AVAsset *avAsset, NSDictionary *info, NSString *imageIdentifier) {
            if (![[[RCAssetHelper shareAssetHelper] getAssetIdentifier:model.asset] isEqualToString:imageIdentifier]) {
                return;
            }
            if (avAsset) {
                NSMutableDictionary *assetInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
                if (avAsset) {
                    [assetInfo setObject:avAsset forKey:@"avAsset"];
                }
                if (model.thumbnailImage) {
                    [assetInfo setObject:model.thumbnailImage forKey:@"thumbnail"];
                }
                NSString *localPath = @"";
                if (@available(iOS 13.0, *)) {
                    AVURLAsset *urlAsset = (AVURLAsset *)avAsset;
                    // 添加判断，如果选择的是慢动作视频，这里返回的是 AVComposition 对象，这个时候没有 URL 属性
                    if ([urlAsset respondsToSelector:@selector(URL)]) {
                        NSURL *url = urlAsset.URL;
                        NSString *tempString = [url relativePath];
                        localPath = tempString;
                    }
                }
                if (localPath == nil || localPath.length < 1) {
                    NSArray *localPaths =
                        [info[@"PHImageFileSandboxExtensionTokenKey"] componentsSeparatedByString:@";"];
                    if (localPaths.count > 0) {
                        localPath = [localPaths lastObject];
                    }
                }
                localPath = [self moveVideoFileAt:localPath];

                [assetInfo setObject:localPath forKey:@"localPath"];

                // NSDictionary* assetInfo = @{@"avAsset":model.avAsset,@"thumbnail":!model.thumbnailImage ?
                // [NSNull null] : model.thumbnailImage};
                [results addObject:[assetInfo copy]];
            }
            [self handlePhotos:photos result:results full:isFull];
        }
        progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
            if (progress < 1 && !error && !strongSelf.isShowHUD) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    strongSelf.isShowHUD = YES;
                    strongSelf.progressHUD =
                        [RCMBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                    strongSelf.progressHUD.label.text = RCLocalizedString(@"iCloudDownloading");
                });
            }
            if (error) {
                // from iCloud download error
                strongSelf.progressHUD.label.text = RCLocalizedString(@"iCloudDownloadFail");
                [strongSelf.progressHUD hideAnimated:YES afterDelay:1];
                strongSelf.isShowHUD = NO;
            }
    }];
}

- (void)p_getOriginImageData:(RCAssetModel *)model photos:(NSMutableArray *)photos result:(NSMutableArray *)results full:(BOOL)isFull{
    __weak typeof(self) weakself = self;
    [[RCAssetHelper shareAssetHelper] getOriginImageDataWithAsset:model
        result:^(NSData *imageData, NSDictionary *info, RCAssetModel *assetModel) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] &&
                                    ![info objectForKey:PHImageErrorKey] &&
                                    ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            if (downloadFinined && imageData) {
                if ([[model.asset valueForKey:@"uniformTypeIdentifier"]
                        isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                    NSMutableDictionary *gifInfo = [[NSMutableDictionary alloc] init];
                    [gifInfo setObject:@"GIF" forKey:@"GIF"];
                    [gifInfo setObject:imageData forKey:@"imageData"];
                    [results addObject:gifInfo];
                } else {
                    [results addObject:imageData];
                }
                [weakself handlePhotos:photos result:results full:isFull];
            }
        }
        progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            if (progress < 1 && !error && !weakself.isShowHUD) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakself.isShowHUD = YES;
                    weakself.progressHUD =
                        [RCMBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                             animated:YES];
                    weakself.progressHUD.label.text = RCLocalizedString(@"iCloudDownloading");
                });
            }
            if (error) {
                // from iCloud download error
                weakself.progressHUD.label.text = RCLocalizedString(@"iCloudDownloadFail");
                [weakself.progressHUD hideAnimated:YES afterDelay:1];
                weakself.isShowHUD = NO;
            }
        }];
}

- (void)pushImagePickerController:(RCAlbumModel *)assetsGroup animated:(BOOL)animated {

    RCPhotosPickerController *imagePickerVC = [RCPhotosPickerController imagePickerViewController];
    imagePickerVC.count = assetsGroup.count;
    imagePickerVC.currentAsset = assetsGroup.asset;
    imagePickerVC.title = assetsGroup.albumName;
    __weak typeof(self) weakself = self;
    [imagePickerVC setSendPhotosBlock:^(NSArray *photos, BOOL isFull) {
        NSMutableArray *selectedPhotos = [NSMutableArray array];
        [weakself handlePhotos:[photos mutableCopy] result:selectedPhotos full:isFull];
    }];

    [self.navigationController pushViewController:imagePickerVC animated:animated];
}

- (void)dismissCurrentModelViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setAuthorizationStatusAuthorized {
    if (![[RCAssetHelper shareAssetHelper] hasAuthorizationStatusAuthorized] && [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusNotDetermined) {
        self.tipsLabel.hidden = NO;
    }
}

- (UILabel *)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.frame = CGRectMake(8, 64, self.view.frame.size.width - 16, 100);
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.numberOfLines = 0;
        _tipsLabel.font = [[RCKitConfig defaultConfig].font fontOfSecondLevel];
        _tipsLabel.textColor = [UIColor blackColor];
        _tipsLabel.text = RCLocalizedString(@"PhotoAccessRight");
        [self.view addSubview:_tipsLabel];
        _tipsLabel.hidden = YES;
    }
    return _tipsLabel;
}
@end

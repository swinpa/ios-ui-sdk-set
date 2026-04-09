//
//  EGOImageView.m
//  EGOImageLoading
//
//  Created by Shaun Harrison on 9/15/09.
//  Copyright (c) 2009-2010 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RCloudImageView.h"
#import <RongIMLibCore/RongIMLibCore.h>
#import "RCloudMediaManager.h"
#import "RCloudImageLoader.h"
#import "RCloudCache.h"
#import <ImageIO/ImageIO.h>

@implementation RCloudImageView
@synthesize imageURL, placeholderImage, delegate;

- (instancetype)initWithPlaceholderImage:(UIImage *)anImage {
    return [self initWithPlaceholderImage:anImage delegate:nil];
}

- (instancetype)initWithPlaceholderImage:(UIImage *)anImage delegate:(id<RCloudImageViewDelegate>)aDelegate {
    if ((self = [super initWithImage:anImage])) {
        self.placeholderImage = anImage;
        self.delegate = aDelegate;
    }

    return self;
}
- (void)setPlaceholderImage:(UIImage *)__placeholderImage {
    if (placeholderImage) {
        placeholderImage = nil;
    }
    placeholderImage = __placeholderImage;

    self.image = placeholderImage;
}
- (void)setImageURL:(NSURL *)aURL {
    //    self.contentMode = UIViewContentModeScaleAspectFill;
    if (imageURL) {
        [[RCloudImageLoader sharedImageLoader] removeObserver:self forURL:imageURL];
        imageURL = nil;
    }

    if (!aURL) {
        self.image = self.placeholderImage;
        [self p_stopGIFAnimation];
        return;
    } else {
        imageURL = aURL;
    }
    [self p_downloadImage];
}

#pragma mark - GIF Support

- (BOOL)p_isGIFData:(NSData *)data {
    if (data.length < 3) return NO;
    uint8_t header[3];
    [data getBytes:header length:3];
    // GIF magic number: 0x47 0x49 0x46 ("GIF")
    return (header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46);
}

- (BOOL)p_trySetAnimatedGIF:(NSData *)data {
    if (!data || ![self p_isGIFData:data]) return NO;

    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (!source) return NO;

    size_t frameCount = CGImageSourceGetCount(source);
    if (frameCount <= 1) {
        CFRelease(source);
        return NO;
    }

    NSMutableArray<UIImage *> *frames = [NSMutableArray arrayWithCapacity:frameCount];
    NSTimeInterval totalDuration = 0;

    for (size_t i = 0; i < frameCount; i++) {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!cgImage) continue;

        UIImage *frame = [UIImage imageWithCGImage:cgImage];
        [frames addObject:frame];
        CGImageRelease(cgImage);

        // Get frame duration
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
        if (properties) {
            CFDictionaryRef gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
            if (gifProperties) {
                NSNumber *delayTime = CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
                if (!delayTime || delayTime.doubleValue <= 0) {
                    delayTime = CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
                }
                if (delayTime && delayTime.doubleValue > 0) {
                    totalDuration += delayTime.doubleValue;
                } else {
                    totalDuration += 0.1;
                }
            } else {
                totalDuration += 0.1;
            }
            CFRelease(properties);
        } else {
            totalDuration += 0.1;
        }
    }

    CFRelease(source);

    if (frames.count == 0) return NO;

    dispatch_async(dispatch_get_main_queue(), ^{
        self.animationImages = frames;
        self.animationDuration = totalDuration;
        self.animationRepeatCount = 0;
        self.image = frames.firstObject;
        [self startAnimating];
    });

    return YES;
}

- (void)p_stopGIFAnimation {
    if (self.isAnimating) {
        [self stopAnimating];
    }
    self.animationImages = nil;
}

- (void)p_setStaticImage:(UIImage *)image {
    [self p_stopGIFAnimation];
    self.image = image;
}

- (void)p_downloadImage{
    [self p_stopGIFAnimation];

    if (!imageURL.scheme || [imageURL.scheme.lowercaseString isEqualToString:@"file"]) {
        NSString *path = imageURL.absoluteString;
        if ([path length] > 0) {
            path = [RCUtilities getCorrectedFilePath:path];

            // Check if local file is GIF
            if (self.enableGIF) {
                NSData *fileData = [NSData dataWithContentsOfFile:path];
                if (fileData && [self p_isGIFData:fileData]) {
                    [self p_trySetAnimatedGIF:fileData];
                    return;
                }
            }

            UIImage *anImage = [[UIImage alloc] initWithContentsOfFile:path];
            if (anImage) {
                // 图片特别小时会立即返回，可以正常显示，如果图片特别大则是异步返回，图片由小块最后生成原图
                [[RCloudMediaManager sharedManager] downsizeImage:anImage
                    completionBlock:^(UIImage *image, BOOL doNothing) {
                        if (image) {
                            if ([NSThread isMainThread]) {
                                self.image = image;
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    self.image = image;
                                    if ([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
                                        [self.delegate imageViewLoadedImage:self];
                                    }
                                });
                            }
                        }
                        if (!doNothing && image) {
                            NSData *imageResource = UIImagePNGRepresentation(image);
                            [imageResource writeToFile:path atomically:YES];
                        }

                    }
                    progressBlock:^(UIImage *image, BOOL doNothing){

                    }];
                return;
            }
        } else {
            self.image = self.placeholderImage;
            return;
        }
    }

    [[RCloudImageLoader sharedImageLoader] removeObserver:self];

    // Check cached data for GIF before using static image path
    if (self.enableGIF) {
        NSData *cachedData = [[RCloudImageLoader sharedImageLoader] getImageDataForURL:imageURL];
        if (cachedData && [self p_isGIFData:cachedData]) {
            if ([self p_trySetAnimatedGIF:cachedData]) {
                if ([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
                    [self.delegate imageViewLoadedImage:self];
                }
                return;
            }
        }
    }

    UIImage *anImage = [[RCloudImageLoader sharedImageLoader] imageForURL:imageURL shouldLoadWithObserver:self];

    if (anImage) {
        [[RCloudMediaManager sharedManager] downsizeImage:anImage
            completionBlock:^(UIImage *image, BOOL doNothing) {
                if (image) {
                    if ([NSThread isMainThread]) {
                        self.image = image;
                        if ([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
                            [self.delegate imageViewLoadedImage:self];
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.image = image;
                            if ([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
                                [self.delegate imageViewLoadedImage:self];
                            }
                        });
                    }
                    if (!doNothing) {
                        NSData *imageResource = UIImagePNGRepresentation(image);
                        NSString *imagePath = [[RCloudImageLoader sharedImageLoader] cachePathForURL:imageURL];
                        [imageResource writeToFile:imagePath atomically:YES];
                    }
                }
            }
            progressBlock:^(UIImage *image, BOOL doNothing){

            }];

    } else {
        self.image = self.placeholderImage;
    }
}

- (NSData *)originalImageData {
    NSData *imageData = [[RCloudImageLoader sharedImageLoader] getImageDataForURL:imageURL];
    if (!imageData) {
        imageData = UIImageJPEGRepresentation(self.placeholderImage, 1.0);
    }
    return imageData;
}

#pragma mark -
#pragma mark Image loading

- (void)cancelImageLoad {
    [[RCloudImageLoader sharedImageLoader] cancelLoadForURL:self.imageURL];
    [[RCloudImageLoader sharedImageLoader] removeObserver:self forURL:self.imageURL];
}

- (void)imageLoaderDidLoad:(NSNotification *)notification {
    NSURL *notifyURL = [notification userInfo][@"imageURL"];
    if (![notifyURL isKindOfClass:[NSURL class]]) return;
    if (![self.imageURL isEqual:notifyURL]) return;

    // Check if original data is GIF
    if (self.enableGIF) {
        NSData *originalData = [notification userInfo][@"originalImageData"];
        if (originalData && [originalData isKindOfClass:[NSData class]] && [self p_isGIFData:originalData]) {
            if ([self p_trySetAnimatedGIF:originalData]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
                        [self.delegate imageViewLoadedImage:self];
                    }
                });
                return;
            }
        }
    }

    UIImage *anImage = [notification userInfo][@"image"];
    if (!anImage || ![anImage isKindOfClass:[UIImage class]]) return;
    [[RCloudMediaManager sharedManager] downsizeImage:anImage
                                      completionBlock:^(UIImage *image, BOOL doNothing) {
        if (!image || ![self.imageURL isEqual:notifyURL]) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = image;
            if ([self.delegate respondsToSelector:@selector(imageViewLoadedImage:)]) {
                [self.delegate imageViewLoadedImage:self];
            }
            [self setNeedsDisplay];
        });
        if (!doNothing) {
            NSData *imageResource = UIImagePNGRepresentation(image);
            NSString *imagePath = [[RCloudImageLoader sharedImageLoader] cachePathForURL:self.imageURL];
            [imageResource writeToFile:imagePath atomically:YES];
        }
    } progressBlock:^(UIImage *image, BOOL doNothing){}];
}

- (void)imageLoaderDidFailToLoad:(NSNotification *)notification {
    if (![[notification userInfo][@"imageURL"] isEqual:self.imageURL])
        return;

    if ([self.delegate respondsToSelector:@selector(imageViewFailedToLoadImage:error:)]) {
        [self.delegate imageViewFailedToLoadImage:self error:[notification userInfo][@"error"]];
    }
}

#pragma mark -
- (void)dealloc {
    [self p_stopGIFAnimation];
    [[RCloudImageLoader sharedImageLoader] removeObserver:self];
    delegate = nil;
#if !__has_feature(objc_arc)
    [imageURL release];
    imageURL = nil;
    [placeholderImage release];
    placeholderImage = nil;
    [super dealloc];
#else
    imageURL = nil;
    placeholderImage = nil;
#endif
}

@end

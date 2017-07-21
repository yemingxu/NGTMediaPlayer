//
//  NGTMediaPlayerManager.h
//  Youdoneed
//
//  Created by JoeXu on 2017/7/10.
//  Copyright © 2017年 李凌辉. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NGTMediaPlayer.h"

@class NGTMediaPlayerManager;

@protocol NGTMediaPlayerManagerDelegate <NSObject>

@optional;
//用来初始化操作，例如：视频总时长
- (void)videoPlayDidPrepareOfManager:(NGTMediaPlayerManager *)manager;

//播放时间已更新
- (void)videoPlayManager:(NGTMediaPlayerManager *)manager
    didUpdateCurrentTime:(NSUInteger)currentTime;

- (void)videoPlayStateIsPlayingOfManager:(NGTMediaPlayerManager *)manager;

- (void)videoPlayStateIsPausingOfManager:(NGTMediaPlayerManager *)manager;

- (void)videoPlayStateIsBufferingOfManager:(NGTMediaPlayerManager *)manager;

- (void)videoPlayStateIsBufferedOfManager:(NGTMediaPlayerManager *)manager;

- (void)videoPlayDidErrorWillShutdownOfManager:(NGTMediaPlayerManager *)manager;

@end

@interface NGTMediaPlayerManager : NSObject

@property (nonatomic,weak) id<NGTMediaPlayerManagerDelegate> delegate;

@property (nonatomic,strong,readonly) NSURL *playingURL;

@property (nonatomic,readonly) int videoWidth;
@property (nonatomic,readonly) int videoHeight;
@property (nonatomic,readonly) float videoSizeScale;

@property (nonatomic,readonly) NSTimeInterval currentTime;

@property (nonatomic,readonly) NSTimeInterval duration;

@property (nonatomic,readonly) float playProgress;

@property (nonatomic,readonly) float bufferProgress;

@property (nonatomic,copy,readonly) NSString *currentTimeString;

@property (nonatomic,copy,readonly) NSString *durationString;

@property (nonatomic,readonly) NGTMediaPlayerState state;
@property (nonatomic,readonly) NGTMediaPlayerLoadState loadState;


@property (nonatomic,strong,readonly) UIView *drawView;


//加载视频
//备注：加载视频在主线程进行，所以不能在跳转时加载，会卡顿。
- (void)loadURL:(NSURL *)url;

- (void)play;

- (void)pause;

- (void)seekToTime:(NSTimeInterval)time;
- (void)seekToProgress:(float)progress;//0.0~1.0之间

- (void)setupVolume:(CGFloat)volume;

- (void)shutdown;

+ (instancetype)manager;

@end





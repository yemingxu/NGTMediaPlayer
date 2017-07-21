//
//  NGTMediaPlayer.h
//  AVF_PlayerDemo
//
//  Created by JoeXu on 2017/6/14.
//  Copyright © 2017年 JoeXu. All rights reserved.
//

/** 依赖导入
 AudioToolbox.framework
 VideoToolbox.framework
 CoreMedia.framework
 CoreVideo.framework
 CoreAudio.framework
 AVFoundation.framework
 MediaPlayer.framework
 libstdc++.6.0.9.tbd
 libiconv.2.tbd
 libc++.1.tbd
 libz.1.tbd
 libbz2.1.0.tbd
 
 
 MobileVLCKit.framework
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NGTMediaPlayerLoadState){
    NGTMediaPlayerLoadStateOpening,        ///< Stream is opening
    NGTMediaPlayerLoadStatePrepared,        ///< Stream is Prepared
    NGTMediaPlayerLoadStateBuffering,      ///< Stream is buffering
    NGTMediaPlayerLoadStateBuffered,      ///< Stream is buffered
};

typedef NS_ENUM(NSInteger, NGTMediaPlayerState){
    NGTMediaPlayerStateStopped,        ///< Player has stopped
    NGTMediaPlayerStatePlaying,        ///< Stream is playing
    NGTMediaPlayerStatePaused,          ///< Stream is paused

    NGTMediaPlayerStateEnded,          ///< Stream has ended
    NGTMediaPlayerStateError,          ///< Player has generated an error
    
};
extern NSString * NGTMediaPlayerStateToString(NGTMediaPlayerState state);
extern NSString * NGTMediaPlayerLoadStateToString(NGTMediaPlayerLoadState loadState);

@class NGTMediaPlayer;
@protocol NGTMediaPlayerDelegate <NSObject>
@optional;

//缓冲到时间Time
- (void)videoPlayer:(NGTMediaPlayer *)player bufferingInTime:(NSTimeInterval)time;

//播放到了的时间Time
- (void)videoPlayer:(NGTMediaPlayer *)player playingInTime:(NSTimeInterval)time;

//视频加载状态改变
- (void)videoPlayer:(NGTMediaPlayer *)player didChangeLoadState:(NGTMediaPlayerLoadState)loadState;

//播放状态改变
- (void)videoPlayer:(NGTMediaPlayer *)player didChangeState:(NGTMediaPlayerState)state;


@end
@interface NGTMediaPlayer : NSObject

@property (nonatomic,copy,readonly) NSURL *url;
@property (nonatomic,weak) id<NGTMediaPlayerDelegate> delegate;

@property (nonatomic,readonly) NGTMediaPlayerState state;
@property (nonatomic,readonly) NGTMediaPlayerLoadState loadState;

@property (nonatomic,readonly,getter=isPreparedToPlay) BOOL preparedToPlay;
@property (nonatomic,readonly) NSTimeInterval currentTime;
@property (nonatomic,readonly) NSTimeInterval duration;
@property (nonatomic,readonly) NSString *currentTimeString;
@property (nonatomic,readonly) NSString *durationString;

@property (nonatomic,assign) CGFloat volume;//音量
@property (nonatomic,readonly) int videoWidth;
@property (nonatomic,readonly) int videoHeight;
@property (nonatomic,readonly) NSTimeInterval playableDuration;
@property (nonatomic,readonly) NSInteger bufferingProgress;

/*
 @property(nonatomic, readonly)  NSTimeInterval playableDuration;
 @property(nonatomic, readonly)  NSInteger bufferingProgress;
 
 */


@property (nonatomic,strong,readonly) UIView *drawView;


+ (instancetype)playerWithURL:(NSURL *)url delegate:(id<NGTMediaPlayerDelegate>)delegate;
- (instancetype)initWithURL:(NSURL *)url delegate:(id<NGTMediaPlayerDelegate>)delegate;

- (void)play;

- (void)pause;

/*
 等于[obj seekTo:0.0];
 */
- (void)replay;

- (void)seekTo:(NSUInteger)time;

- (void)shutdown;

/*
 Stop代表放弃此视频，一般没有用
 一旦调用只能放弃此播放器，重新创建
 */
- (void)stop;


//截取当前时刻的缩略图
- (UIImage *)thumbnailImageAtCurrentTime;
@end

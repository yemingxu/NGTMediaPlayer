//
//  NGTMediaPlayer.m
//  AVF_PlayerDemo
//
//  Created by JoeXu on 2017/6/14.
//  Copyright © 2017年 JoeXu. All rights reserved.
//

#import "NGTMediaPlayer.h"
#import <IJKMediaFramework/IJKMediaFramework.h>


NSString * NGTMediaPlayerLoadStateToString(NGTMediaPlayerLoadState loadState){
    switch (loadState) {
        case NGTMediaPlayerLoadStateOpening:
            return @"NGTMediaPlayerLoadStateOpening";
        case NGTMediaPlayerLoadStatePrepared:
            return @"NGTMediaPlayerLoadStatePrepared";
        case NGTMediaPlayerLoadStateBuffering:
            return @"NGTMediaPlayerLoadStateBuffering";
        case NGTMediaPlayerLoadStateBuffered:
            return @"NGTMediaPlayerLoadStateBuffered";
    }
}

NSString * NGTMediaPlayerStateToString(NGTMediaPlayerState state){
    switch (state) {
        case NGTMediaPlayerStatePlaying:
            return @"NGTMediaPlayerStatePlaying";
        case NGTMediaPlayerStatePaused:
            return @"NGTMediaPlayerStatePaused";
        case NGTMediaPlayerStateStopped:
            return @"NGTMediaPlayerStateStopped";
        case NGTMediaPlayerStateEnded:
            return @"NGTMediaPlayerStateEnded";
        case NGTMediaPlayerStateError:
            return @"NGTMediaPlayerStateError";
            break;
        default:
            break;
    }
}
static inline NGTMediaPlayerLoadState NGTMediaPlayerLoadStateConverFromIJK_Load(IJKMPMovieLoadState loadState){
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        return NGTMediaPlayerLoadStateBuffered;
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        return NGTMediaPlayerLoadStateBuffering;
    } else {
        return NGTMediaPlayerLoadStateBuffered;
    }
}

static inline NGTMediaPlayerState NGTMediaPlayerStateConverFromIJK(IJKMPMoviePlaybackState state){
    switch (state) {
        case IJKMPMoviePlaybackStateStopped:
            return NGTMediaPlayerStateStopped;
            break;

        case IJKMPMoviePlaybackStatePlaying:
            return NGTMediaPlayerStatePlaying;
            break;
        case IJKMPMoviePlaybackStatePaused:
            return NGTMediaPlayerStatePaused;
            break;
        case IJKMPMoviePlaybackStateInterrupted:
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward:
            return NGTMediaPlayerStatePaused;
        default:
            break;
    }
}

@interface NGTMediaPlayer(){
    BOOL _isFirstPlay;
    BOOL _didShutdown;
}
@property (nonatomic,strong) IJKFFMoviePlayerController *innerPlayer;

@property (nonatomic,readwrite) NSTimeInterval currentTime;
@property (nonatomic,strong) NSTimer *timeTimer;

@property (nonatomic,readwrite) NGTMediaPlayerState state;
@property (nonatomic,readwrite) NGTMediaPlayerLoadState loadState;

@property (nonatomic,strong,readwrite) UIView *drawView;

@property (nonatomic,assign,getter=isNeedRotateVideo) BOOL needRotateVideo;


@end
@implementation NGTMediaPlayer
- (instancetype)init{
    return nil;
}
+ (instancetype)playerWithURL:(NSURL *)url delegate:(id<NGTMediaPlayerDelegate>)delegate{
    return [[NGTMediaPlayer alloc] initWithURL:url delegate:delegate];
}
- (instancetype)initWithURL:(NSURL *)url delegate:(id<NGTMediaPlayerDelegate>)delegate{
    if (self = [super init]){
        _url = [url copy];
        _isFirstPlay = YES;
        _delegate = delegate;
        
        if(url == nil
           ||[url.absoluteString isEqualToString:@""]){
            _drawView = [UIView new];
            return self;
        }
        
        if([url.absoluteString hasSuffix:@".MOV"]
           ||[url.absoluteString hasSuffix:@".mov"]){
            _needRotateVideo = YES;
        }
        

        
        
        [self configInit];
    }
    return self;
}
- (void)dealloc{
    [self shutdown];
    [self removeMovieNotificationObservers];
}

- (void)configInit{
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setOptionIntValue:29.97 forKey:@"r" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setOptionIntValue:60 forKey:@"max-fps" ofCategory:kIJKFFOptionCategoryPlayer];
    

    IJKFFMoviePlayerController *player = [[IJKFFMoviePlayerController alloc] initWithContentURL:_url withOptions:options];
    
    if (_needRotateVideo){
        player.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    
//    player.shouldShowHudView = YES;
    player.playbackVolume = 0.0;
    [player setPauseInBackground:YES];
    [player setScalingMode:IJKMPMovieScalingModeNone];
    player.view.frame = [UIScreen mainScreen].bounds;
    _innerPlayer = player;
    _drawView = player.view;
    
    [self installMovieNotificationObservers];
    
    player.shouldAutoplay = NO;
    [player prepareToPlay];
}

- (void)setVolume:(CGFloat)volume{
    self.innerPlayer.playbackVolume = (volume>1 ? 1.0 : volume);
}
- (CGFloat)volume{
    return self.innerPlayer.playbackVolume ?: 0.0;
}
- (int)videoHeight{
    if (_needRotateVideo){
        return self.innerPlayer.naturalSize.width ?: 0.0;
    }
    return self.innerPlayer.naturalSize.height ?: 0.0;
}
- (int)videoWidth{
    if (_needRotateVideo){
        return self.innerPlayer.naturalSize.height ?: 0.0;
    }
    return self.innerPlayer.naturalSize.width ?: 0.0;
}
- (NSTimeInterval)duration{
    return self.innerPlayer.duration ?: 0.0;
}
- (NSTimeInterval)currentTime{
    if (_state == NGTMediaPlayerStateEnded){
        return self.duration;
    }
    return self.innerPlayer.currentPlaybackTime ?: 0.0;
}
- (NSString *)durationString{
    return [self p_timeStringWithTime:(int)self.duration];
}
- (NSString *)currentTimeString{
    if (_state == NGTMediaPlayerStateEnded){
        return self.durationString;
    }
    return [self p_timeStringWithTime:(int)self.currentTime];
}
- (NSTimeInterval)playableDuration{
    return self.innerPlayer.playableDuration ?: 0.0;
}
- (NSInteger)bufferingProgress{
    return self.innerPlayer.bufferingProgress ?: 0.0;
}
- (NSString *)p_timeStringWithTime:(int)time{
    int hour = time/3600;
    int minute = (time-hour*3600)/60;
    int sec = time-hour*3600 - minute*60;
    NSString *sec_output = [self p_timeStringWithNum:sec];
    NSString *minute_output = [self p_timeStringWithNum:minute];
    NSString *hour_output = [self p_timeStringWithNum:hour];
    
    if (hour>0){
        return [NSString stringWithFormat:@"%@:%@:%@",hour_output,minute_output,sec_output];
    }else if(minute>0){
        return [NSString stringWithFormat:@"%@:%@",minute_output,sec_output];
    }else{
        return [NSString stringWithFormat:@"00:%@",sec_output];
    }
}
- (NSString *)p_timeStringWithNum:(int)num{
    if (num < 0){
        return @"00";
    }
    if (num>9){
        return [NSString stringWithFormat:@"%i",num];
    }else{
        return [NSString stringWithFormat:@"0%i",num];
    }
}
- (BOOL)isPreparedToPlay{
    return self.innerPlayer.isPreparedToPlay;
}


- (void)seekTo:(NSUInteger)time{
    self.innerPlayer.currentPlaybackTime = time;
}
- (void)replay{
    if (self.state == NGTMediaPlayerStateError){return;}

    [self seekTo:0];
    [self play];
}
- (void)play{
    if (self.state == NGTMediaPlayerStateError){return;}

    if (self.innerPlayer.isPreparedToPlay == NO){ return;}
    if (self.innerPlayer.isPlaying){return;}

    [self.innerPlayer play];
    
    if (!_timeTimer){
        _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(readCurrentTimeTimer:) userInfo:nil repeats:YES];
    }
}

- (void)pause{
    if (self.state == NGTMediaPlayerStateError){return;}

    if (self.innerPlayer.isPreparedToPlay == NO){ return;}

    [self.innerPlayer pause];
}

- (void)stop{
    if (self.innerPlayer.isPreparedToPlay == NO){ return;}
    if (self.state == NGTMediaPlayerStateEnded){return;}
    
    [self.innerPlayer stop];
    
    self.state = NGTMediaPlayerStateStopped;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeState:)]){
        [self.delegate videoPlayer:self didChangeState:NGTMediaPlayerStateStopped];
    }
}
- (void)shutdown{
    if (_didShutdown){return;}
    
    [self.timeTimer invalidate];
    self.timeTimer = nil;
    [self.innerPlayer shutdown];
    [self.innerPlayer.view removeFromSuperview];
    self.innerPlayer = nil;
    self.drawView = nil;
    _didShutdown = YES;
}
- (UIImage *)thumbnailImageAtCurrentTime{
    return [self.innerPlayer thumbnailImageAtCurrentTime];
}

- (void)readCurrentTimeTimer:(NSTimer *)timer{
    if (self.state == NGTMediaPlayerStateError){return;}
    
    if (self.innerPlayer.isPlaying == NO){
        if (_currentTime != self.currentTime){
            [self p_changeTime];
        }
        return;
    }
    [self p_changeTime];
}
- (void)p_changeTime{
    NSTimeInterval c_time = self.currentTime;
    self.currentTime = c_time;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:playingInTime:)]){
        [self.delegate videoPlayer:self playingInTime:c_time];
    }
}

#pragma mark - 通知---缓冲进度

- (void)loadStateDidChange:(NSNotification*)notification{
    
    //    MPMovieLoadStateUnknown        = 0,未知
    
    //    MPMovieLoadStatePlayable      = 1 << 0,缓冲结束可以播放
    
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES 缓冲结束自动播放
    
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    //暂停
    
    IJKMPMovieLoadState loadState = _innerPlayer.loadState;
    NGTMediaPlayerLoadState __loadState = NGTMediaPlayerLoadStateConverFromIJK_Load(loadState);
    
    int debug = 1;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        debug = 1;
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        debug = 2;
    }else if ((loadState & MPMovieLoadStatePlayable) != 0) {
        debug = 2;
    } else {
        debug = -1;
        return;
        
    }
    if (__loadState != self.loadState){
        self.loadState = __loadState;
        if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeLoadState:)]){
            [self.delegate videoPlayer:self didChangeLoadState:__loadState];
        }
    }
}

#pragma mark - 通知---播放已完成(未兼容直播)
- (void)moviePlayBackDidFinish:(NSNotification*)notification{
    
    //    MPMovieFinishReasonPlaybackEnded, 直播结束/播放结束
    //    MPMovieFinishReasonPlaybackError, 直播错误/播放出错
    //    MPMovieFinishReasonUserExited  用户退出
    
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    NGTMediaPlayerState currentState = self.state;
    switch (reason) {
            
        case IJKMPMovieFinishReasonPlaybackEnded:
            currentState = NGTMediaPlayerStateEnded;
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            currentState = NGTMediaPlayerStateError;
            break;
            
    }
    if (currentState != self.state){
        self.state = currentState;
        if (currentState == NGTMediaPlayerStateEnded
            ||currentState == NGTMediaPlayerStateError){
            if ([self.delegate respondsToSelector:@selector(videoPlayer:playingInTime:)]){
                [self.delegate videoPlayer:self playingInTime:self.duration];
            }
        }
        if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeState:)]){
            [self.delegate videoPlayer:self didChangeState:currentState];
        }
    }
}

//1.8


#pragma mark - 通知---播放状态以改变
- (void)moviePlayBackStateDidChange:(NSNotification*)notification{
    
    //    MPMoviePlaybackStateStopped,
    
    //    MPMoviePlaybackStatePlaying,
    
    //    MPMoviePlaybackStatePaused,
    
    //    MPMoviePlaybackStateInterrupted,
    
    //    MPMoviePlaybackStateSeekingForward,
    
    //    MPMoviePlaybackStateSeekingBackward
    IJKMPMoviePlaybackState playbackState = _innerPlayer.playbackState;
    NGTMediaPlayerState currentState = NGTMediaPlayerStateConverFromIJK(playbackState);

    switch (playbackState){
            
        case IJKMPMoviePlaybackStateStopped: {
            return;
            break;
        }
            
        case IJKMPMoviePlaybackStatePlaying: {
            break;
        }
            
        case IJKMPMoviePlaybackStatePaused: {
            break;
        }
            
        case IJKMPMoviePlaybackStateInterrupted: {
            break;
        }
            
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            break;
        }
            
        default: {
            break;
        }
            
    }
    if (currentState != self.state){
        self.state = currentState;
        if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeState:)]){
            [self.delegate videoPlayer:self didChangeState:currentState];
        }
    }
}
#pragma mark - 通知---视频已准备就绪
- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification{
    self.loadState = NGTMediaPlayerLoadStatePrepared;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeLoadState:)]){
        [self.delegate videoPlayer:self didChangeLoadState:NGTMediaPlayerLoadStatePrepared];
    }
}

#pragma mark - 添加通知的监听
-(void)installMovieNotificationObservers{
    
    //监听网络环境，监听缓冲方法
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(loadStateDidChange:)
     
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
     
                                               object:_innerPlayer];
    
    //监听直播完成回调
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(moviePlayBackDidFinish:)
     
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
     
                                               object:_innerPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
     
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
     
                                               object:_innerPlayer];
    
    //监听用户主动操作
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(moviePlayBackStateDidChange:)
     
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
     
                                               object:_innerPlayer];
    
}

#pragma mark - 删除通知的监听

//1.5

/* Remove the movie notification observers from the movie object. */

-(void)removeMovieNotificationObservers{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_innerPlayer];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_innerPlayer];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_innerPlayer];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_innerPlayer];
    
}

@end

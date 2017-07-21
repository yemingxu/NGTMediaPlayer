//
//  NGTMediaPlayerManager.m
//  Youdoneed
//
//  Created by JoeXu on 2017/7/10.
//  Copyright © 2017年 李凌辉. All rights reserved.
//

#import "NGTMediaPlayerManager.h"



@interface NGTMediaPlayerManager()<NGTMediaPlayerDelegate>

@property (nonatomic,strong,readwrite) NGTMediaPlayer *player;

@property (nonatomic,strong,readwrite) UIView *drawView;

@property (nonatomic,strong) UIActivityIndicatorView *bufferingHUD;

@property (nonatomic) dispatch_queue_t loadVideoQueue;

@end


@implementation NGTMediaPlayerManager

+ (instancetype)manager{
    static NGTMediaPlayerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NGTMediaPlayerManager alloc] init];

    });
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _loadVideoQueue = dispatch_queue_create(@"loadVideoQueue".UTF8String, NULL);
        
        UIView *drawView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [drawView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        _drawView = drawView;
        
        UIActivityIndicatorView *bufferingHUD = [[UIActivityIndicatorView alloc] init];
        bufferingHUD.hidden = YES;
        _bufferingHUD = bufferingHUD;
        [_drawView addSubview:bufferingHUD];
    }
    return self;
}

- (void)videoPlayer:(NGTMediaPlayer *)player didChangeState:(NGTMediaPlayerState)state{
    NSLog(@"\n-----\n%@\n------\n\n",NGTMediaPlayerStateToString(state));
    if (state == NGTMediaPlayerStateError){
        
        [self shutdown];

    }else if (state == NGTMediaPlayerStateEnded){
        
        if ([self.delegate respondsToSelector:@selector(videoPlayManager:didUpdateCurrentTime:)]){
            [self.delegate videoPlayManager:self didUpdateCurrentTime:self.duration];
        }
        if ([self.delegate respondsToSelector:@selector(videoPlayStateIsPausingOfManager:)]){
            [self.delegate videoPlayStateIsPausingOfManager:self];
        }
        
    }else if(state == NGTMediaPlayerStatePlaying){
        if ([self.delegate respondsToSelector:@selector(videoPlayStateIsPlayingOfManager:)]){
            [self.delegate videoPlayStateIsPlayingOfManager:self];
        }
        
    }else if(state == NGTMediaPlayerStatePaused){
        
        _bufferingHUD.hidden = YES;
        [_bufferingHUD stopAnimating];
        
        if ([self.delegate respondsToSelector:@selector(videoPlayStateIsPausingOfManager:)]){
            [self.delegate videoPlayStateIsPausingOfManager:self];
        }
    }
}
- (void)videoPlayer:(NGTMediaPlayer *)player didChangeLoadState:(NGTMediaPlayerLoadState)loadState{
    NSLog(@"\n-----\n%@\n------\n\n",NGTMediaPlayerLoadStateToString(loadState));
    if (loadState == NGTMediaPlayerLoadStatePrepared){
        
        [self play];
        if ([self.delegate respondsToSelector:@selector(videoPlayDidPrepareOfManager:)]){
            [self.delegate videoPlayDidPrepareOfManager:self];
        }
        
    }else if(loadState == NGTMediaPlayerLoadStateBuffering){
        
        _bufferingHUD.hidden = NO;
        [_bufferingHUD startAnimating];
        
        if ([self.delegate respondsToSelector:@selector(videoPlayStateIsBufferingOfManager:)]){
            [self.delegate videoPlayStateIsBufferingOfManager:self];
        }
        
    }else if(loadState == NGTMediaPlayerLoadStateBuffered){
        
        _bufferingHUD.hidden = YES;
        [_bufferingHUD stopAnimating];
        
        if ([self.delegate respondsToSelector:@selector(videoPlayStateIsBufferedOfManager:)]){
            [self.delegate videoPlayStateIsBufferedOfManager:self];
        }
    }
}
- (void)videoPlayer:(NGTMediaPlayer *)player playingInTime:(NSTimeInterval)time{
    //    NSLog(@"\n-----\n%f/%f\n-----\n\n",time,player.duration);

    if ([self.delegate respondsToSelector:@selector(videoPlayManager:didUpdateCurrentTime:)]){
        [self.delegate videoPlayManager:self didUpdateCurrentTime:time];
    }
}
- (int)videoWidth{
    return self.player.videoWidth;
}
- (int)videoHeight{
    return self.player.videoHeight;
}
- (float)videoSizeScale{
    return ((float)self.videoWidth)/(self.videoHeight);
}
- (NSTimeInterval)duration{
    return [self.player duration];
}
- (NSTimeInterval)currentTime{
    return self.player.currentTime;
}
- (NSString *)currentTimeString{
    return self.player.currentTimeString;
}
- (NSString *)durationString{
    return self.player.durationString;
}
- (float)playProgress{
    return (self.duration == 0) ? 0.0:self.currentTime/self.duration;
}
- (float)bufferProgress{
    return (self.duration == 0) ? 0.0:(self.player.playableDuration+self.currentTime)/self.duration;
}
- (NGTMediaPlayerState)state{
    return self.player.state;
}
- (NGTMediaPlayerLoadState)loadState{
    return self.player.loadState;
}

- (void)loadURL:(NSURL *)url{

    if (url && [url.absoluteString isEqualToString:_playingURL.absoluteString]){
        [self seekToProgress:0.0];
        [self player];
        return;
    }
    
    [self shutdown];
    
    _playingURL = [url copy];
    
    if (url == nil){
        return;
    }
    self.player = [[NGTMediaPlayer alloc] initWithURL:url delegate:self];
    self.player.drawView.frame = self.drawView.bounds;
    [self.drawView.layer insertSublayer:self.player.drawView.layer atIndex:0];
//    [self.drawView insertSubview:self.player.drawView atIndex:0];
}

- (void)play{
    [self.player play];
}

- (void)pause{
    [self.player pause];
}
- (void)seekToTime:(NSTimeInterval)time{
    float _time = time;
    if (time>self.duration) _time = self.duration;
    [self.player seekTo:_time];
}

//0.0~1.0之间
- (void)seekToProgress:(float)progress{
    float _progress = progress;
    if (progress<0) _progress = 0;
    if (progress>1.0) _progress = 1.0;
    
    NSTimeInterval seekTime = self.duration * _progress;
    
    [self seekToTime:seekTime];
}
- (void)setupVolume:(CGFloat)volume{
    self.player.volume = volume;
}
- (void)shutdown{
    _playingURL = nil;
    
    [self.player.drawView.layer removeFromSuperlayer];
    [self.player.drawView removeFromSuperview];
    
//    [self.player stop];
    
    [self.player shutdown];
    
    self.player = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    //_drawView的frame已更新
    
    [self updateLayout];
}
- (void)updateLayout{
    
    self.player.drawView.frame = self.drawView.bounds;
    
    self.bufferingHUD.center = (CGPoint){
        self.drawView.frame.size.width/2.0,
        self.drawView.frame.size.height/2.0};
}

- (void)dealloc{
    [self.drawView removeObserver:self forKeyPath:@"frame"];
    
    if (self.player){
        [self shutdown];
    }
    [self.drawView removeFromSuperview];;
    
    self.drawView = nil;
}

@end

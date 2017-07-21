//
//  YNNSVideoPlayerManagerViewBinder.m
//  Youdoneed
//
//  Created by JoeXu on 2017/7/11.
//  Copyright © 2017年 李凌辉. All rights reserved.
//

#import "NGTMediaPlayerManagerViewBinder.h"

#import "NGTMediaPlayerManager.h"

#import "NGTMediaPlayerView.h"

@interface NGTMediaPlayerManagerViewBinder()<NGTMediaPlayerManagerDelegate>

@property (nonatomic,weak) NGTMediaPlayerManager *manager;

@property (nonatomic,weak) NGTMediaPlayerActionView *actionView;

@property (nonatomic,weak) UIButton *playPauseButton;

@property (nonatomic,assign) BOOL viewShowing;

@end
@implementation NGTMediaPlayerManagerViewBinder
- (void)unbind{
    if (self.manager.delegate == self){
        self.manager.delegate = nil;
    }
}
- (void)bindManager:(NGTMediaPlayerManager *)manager
      forActionView:(NGTMediaPlayerActionView *)actionView
otherPlayPauseButton:(UIButton *)playPauseButton{
    if (manager == self.manager
        &&actionView == self.actionView
        &&playPauseButton == self.playPauseButton
        &&manager.delegate == self){
        return;
    }
    self.actionView = actionView;
    self.playPauseButton = playPauseButton;
    self.manager = manager;
    manager.delegate = self;
    
    if (manager && manager.loadState>=NGTMediaPlayerLoadStatePrepared){
        [actionView setupDurationTimeStr:manager.durationString];
        [self updatePlayTimeProgress];
    }
    
    __weak typeof(self) weakSelf = self;
    [actionView setupSliderBlock:^(float progress) {
        [weakSelf.manager seekToProgress:progress];
    }];
    
    
    
    [actionView setupPlayPauseTapBlock:^(UIButton *sender) {
        if (sender.selected){
            [weakSelf.manager pause];
        }else{
            [weakSelf.manager play];
        }
    }];
    [playPauseButton addTarget:self action:@selector(playPauseButtonTap:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)playPauseButtonTap:(UIButton *)sender{
    if (sender.selected){
        [self.manager pause];
    }else{
        [self.manager play];
    }
}
//更新播放进度UI
- (void)updatePlayTimeProgress{
    [self.actionView setupCurrentTimeStr:self.manager.currentTimeString];
    [self.actionView setupProgress:self.manager.playProgress];
    [self.actionView setupProgressOfBuffered:self.manager.bufferProgress];
}
//用来初始化操作，例如：视频总时长
- (void)videoPlayDidPrepareOfManager:(NGTMediaPlayerManager *)manager{
    [self.actionView setupDurationTimeStr:manager.durationString];
}

//播放时间已更新
- (void)videoPlayManager:(NGTMediaPlayerManager *)manager
    didUpdateCurrentTime:(NSUInteger)currentTime{
    [self updatePlayTimeProgress];
}

- (void)videoPlayStateIsPlayingOfManager:(NGTMediaPlayerManager *)manager{
    self.playPauseButton.selected = YES;
    self.actionView.selectedOfPlayPause = YES;
    
    self.actionView.userInteractionEnabled = YES;
    self.playPauseButton.userInteractionEnabled = YES;
}

- (void)videoPlayStateIsPausingOfManager:(NGTMediaPlayerManager *)manager{
    self.playPauseButton.selected = NO;
    self.actionView.selectedOfPlayPause = NO;

}

- (void)videoPlayStateIsBufferingOfManager:(NGTMediaPlayerManager *)manager{
    self.actionView.userInteractionEnabled = NO;
    self.playPauseButton.userInteractionEnabled = NO;
    
}
- (void)videoPlayStateIsBufferedOfManager:(NGTMediaPlayerManager *)manager{
    self.actionView.userInteractionEnabled = YES;
    self.playPauseButton.userInteractionEnabled = YES;
}
- (void)videoPlayDidErrorWillShutdownOfManager:(NGTMediaPlayerManager *)manager{
    
}
@end

//
//  NGTMediaPlayerView.m
//  Youdoneed
//
//  Created by JoeXu on 2017/7/11.
//  Copyright © 2017年 李凌辉. All rights reserved.
//

#import "NGTMediaPlayerView.h"

@implementation NGTMediaPlayerView

#pragma mark - Init & Layout
- (instancetype)initWithFrame:(CGRect)frame{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    [self setupSubviews];
    
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [self my_layoutSubviews];
}
- (void)my_layoutSubviews{
    if(_videoDrawView){
        _videoDrawView.frame =  self.bounds;
    }
    if (_actionView){
        _actionView.frame = (CGRect){
            0,
            self.frame.size.height-30,
            self.frame.size.width,
            30};
    }
    if (_centerPlayPauseButton){
        CGSize buttonSize = _centerPlayPauseButton.frame.size;
        _centerPlayPauseButton.frame = (CGRect){
            (self.bounds.size.width-buttonSize.width)/2.0,
            (self.bounds.size.height-buttonSize.height)/2.0,
            buttonSize};
    }
}

- (void)setupSubviews{
    
    NGTMediaPlayerActionView *actionView = [[NGTMediaPlayerActionView alloc] initWithFrame:self.bounds];
    actionView.hiddenOfPlayPause = YES;   
    _actionView = actionView;
    
    UIButton *centerPlayPauseButton = [UIButton makeOfVideoPlayer];
    _centerPlayPauseButton = centerPlayPauseButton;
    
    
    [self addSubview:actionView];
    [self addSubview:centerPlayPauseButton];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTapsRequired = 1;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self addGestureRecognizer:doubleTap];
    [self addGestureRecognizer:singleTap];
    
}

#pragma mark - tap actions
- (void)singleTap:(UITapGestureRecognizer *)tap{
    if (self.singleTapBlock){
        self.singleTapBlock();
    }
}
- (void)doubleTap:(UITapGestureRecognizer *)tap{
    if (self.doubleTapBlock){
        self.doubleTapBlock();
    }
}

#pragma mark - bind draw view
- (void)setVideoDrawView:(UIView *)videoDrawView{
    if ([_videoDrawView isEqual:videoDrawView]) {
        return;
    }
    
    [_videoDrawView removeFromSuperview];
    _videoDrawView = nil;
    _videoDrawView = videoDrawView;
    
    if (videoDrawView){
        [self insertSubview:videoDrawView atIndex:0];
        [self my_layoutSubviews];
    }
}
#pragma mark - dealloc
- (void)deallocVideoView{
    [self.videoDrawView removeFromSuperview];
    self.videoDrawView = nil;
}

- (void)dealloc{
    [self deallocVideoView];
}

@end

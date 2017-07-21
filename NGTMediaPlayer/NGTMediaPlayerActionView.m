//
//  NGTMediaPlayerActionView.m
//  Youdoneed
//
//  Created by JoeXu on 2017/7/10.
//  Copyright © 2017年 李凌辉. All rights reserved.
//

#import "NGTMediaPlayerActionView.h"

#import "UIImage+NGTMedia.h"


@interface NGTMediaPlayerActionView()

@property (nonatomic,strong) UIButton *playPauseButton;

@property (nonatomic,strong) NGTMediaPlayerSliderView *sliderView;

@property (nonatomic,strong) UIButton *screenButton;


@property (nonatomic,copy) void(^screenTapBlock)(UIButton *);
@property (nonatomic,copy) void(^playPauseTapBlock)(UIButton *);


@end
@implementation NGTMediaPlayerActionView

- (instancetype)initWithFrame:(CGRect)frame{
    if (!(self = [super initWithFrame:frame])) return nil;
    
    [self setupSubviews];
    
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.screenButton == nil){return;}
    
    self.playPauseButton.frame = (CGRect){
        15,
        0,
        self.playPauseButton.frame.size.width,
        self.frame.size.height};
    
    self.screenButton.frame = (CGRect){
        self.frame.size.width - self.screenButton.frame.size.width - 15,
        0,
        self.screenButton.frame.size.width,
        self.frame.size.height};
    
    CGRect sliderFrame = (CGRect){
        CGRectGetMaxX(self.playPauseButton.frame),
        0,
        CGRectGetMidX(self.screenButton.frame) - CGRectGetMaxX(self.playPauseButton.frame),
        self.frame.size.height};
    
    if (self.isHiddenOfPlayPause) {
        sliderFrame.size.width += self.playPauseButton.frame.size.width;
        sliderFrame.origin.x -= self.playPauseButton.frame.size.width;
    }
    
    self.sliderView.frame = sliderFrame;
}
- (void)setupSubviews{
    UIButton *playPauseButton = [[UIButton alloc] init];
    UIImage *playIcon = [UIImage ngtMediaPlayerImageName:@"ic_play"];
    UIImage *pauseIcon = [UIImage ngtMediaPlayerImageName:@"ic_pause"];
    [playPauseButton setImage:playIcon forState:UIControlStateNormal];
    [playPauseButton setImage:pauseIcon forState:UIControlStateSelected];
    [playPauseButton sizeToFit];
    _playPauseButton = playPauseButton;
    
    NGTMediaPlayerSliderView *sliderView = [[NGTMediaPlayerSliderView alloc] init];
    sliderView.textFontSize = 8;
    sliderView.lineHeight = 3;
    _sliderView = sliderView;
    
    UIButton *screenButton = [[UIButton alloc] init];
    UIImage *screenNorIcon = [UIImage ngtMediaPlayerImageName:@"ic_fullscreen"];
    UIImage *screenSelIcon = [UIImage ngtMediaPlayerImageName:@"ic_fullscreen"];
    [screenButton setImage:screenNorIcon forState:UIControlStateNormal];
    [screenButton setImage:screenSelIcon forState:UIControlStateSelected];
    [screenButton sizeToFit];
    _screenButton = screenButton;
    
    [self addSubview:playPauseButton];
    [self addSubview:sliderView];
    [self addSubview:screenButton];
    
    
    [screenButton addTarget:self action:@selector(screenButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [playPauseButton addTarget:self action:@selector(playPauseButtonTap:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)setSelectedOfPlayPause:(BOOL)selectedOfPlayPause{
    _selectedOfPlayPause = selectedOfPlayPause;
    _playPauseButton.selected = selectedOfPlayPause;
}
- (void)setHiddenOfPlayPause:(BOOL)hiddenOfPlayPause{
    _hiddenOfPlayPause = hiddenOfPlayPause;
    
    _playPauseButton.hidden = hiddenOfPlayPause;
    
    [self layoutSubviews];
}

- (void)setupCurrentTimeStr:(NSString *)string{
    self.sliderView.timeText = [string copy];
}
- (void)setupDurationTimeStr:(NSString *)string{
    self.sliderView.durationText = [string copy];
}
- (void)setupProgress:(float)progress{//0.0~1.0;
    self.sliderView.progress = progress;
}
- (void)setupProgressOfBuffered:(float)progressOfBuffered{//0.0~1.0
    self.sliderView.progressOfBuffered = progressOfBuffered;
}
- (void)setupSliderBlock:(void(^)(float progress))block{
    [self.sliderView setSliderBlock:^(float value){
        if (block){
            block(value);
        }
    }];
}
- (void)screenButtonTap:(UIButton *)sender{
    if (self.screenTapBlock){self.screenTapBlock(sender);}
}
- (void)setupScreenTapBlock:(void(^)(UIButton *sender))block{
    self.screenTapBlock = [block copy];
}

- (void)playPauseButtonTap:(UIButton *)sender{
    if (self.playPauseTapBlock){self.playPauseTapBlock(sender);}
}
- (void)setupPlayPauseTapBlock:(void(^)(UIButton *sender))block{
    self.playPauseTapBlock = [block copy];
}


@end


@implementation UIButton (NGTMediaPlayer)
+ (instancetype)makeOfVideoPlayer{
    UIButton *button = [[UIButton alloc] init];
    UIImage *pauseIcon = [UIImage ngtMediaPlayerImageName:@"暂停"];
    UIImage *playIcon = [UIImage ngtMediaPlayerImageName:@"播放"];
    [button setImage:playIcon forState:UIControlStateNormal];
    [button setImage:pauseIcon forState:UIControlStateSelected];
    [button sizeToFit];
    return button;
}
@end





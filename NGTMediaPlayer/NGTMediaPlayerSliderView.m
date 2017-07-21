//
//  NGTMediaPlayerSliderView.m
//  AVF_PlayerDemo
//
//  Created by JoeXu on 2017/6/19.
//  Copyright © 2017年 JoeXu. All rights reserved.
//

#import "NGTMediaPlayerSliderView.h"
#import "NGTMediaPlayerProgressView.h"

static inline UIImage *__ngt_sliderMakeImage(UIColor *color,CGSize size,CGFloat cornerRadius){
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width*2.0, size.height*2.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    

    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius*2.0];
    CGContextAddPath(context, path.CGPath);
    CGContextClip(context);
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = [UIImage imageWithCGImage:image.CGImage scale:2.0 orientation:UIImageOrientationUp];
    return image;
}
@interface NGTMediaPlayerSliderView()
@property (nonatomic,assign,readwrite,getter=isSliding) BOOL sliding;

@property (nonatomic,strong) UILabel *currentTimeLabel;
@property (nonatomic,strong) UILabel *durationLabel;

@property (nonatomic,strong) UISlider *slider;
@property (nonatomic,strong) NGTMediaPlayerProgressView *progressView;
@end
@implementation NGTMediaPlayerSliderView

- (instancetype)initWithFrame:(CGRect)frame{
    if (!(self = [super initWithFrame:frame])) return nil;
    _textFontSize = 10;
    [self setupSubviews];
    
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    _currentTimeLabel.center = (CGPoint){_currentTimeLabel.frame.size.width/2.0,self.frame.size.height/2.0};
    _durationLabel.center = (CGPoint){self.frame.size.width-_durationLabel.frame.size.width/2.0,self.frame.size.height/2.0};
    
    CGFloat progressWidth = self.frame.size.width-_currentTimeLabel.frame.size.width-_durationLabel.frame.size.width-10;
    
    _progressView.frame = CGRectMake(_currentTimeLabel.frame.size.width+5,
                                     0,
                                     progressWidth,
                                     self.frame.size.height);
    _slider.frame = _progressView.frame;
}
- (void)setupSubviews{
    UILabel *currentTimeLabel = [[UILabel alloc] init];
    currentTimeLabel.textColor = [UIColor whiteColor];
    currentTimeLabel.font = [UIFont systemFontOfSize:_textFontSize];
    currentTimeLabel.text = @"00:00:00";
    currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    [currentTimeLabel sizeToFit];
    _currentTimeLabel = currentTimeLabel;
    UILabel *durationLabel = [[UILabel alloc] init];
    durationLabel.textAlignment = NSTextAlignmentCenter;
    durationLabel.textColor = [UIColor whiteColor];
    durationLabel.font = [UIFont systemFontOfSize:_textFontSize];
    durationLabel.text = @"00:00:00";
    [durationLabel sizeToFit];
    _durationLabel = durationLabel;
    NGTMediaPlayerProgressView *progressView = [[NGTMediaPlayerProgressView alloc] init];
    _progressView = progressView;
    
    UISlider *slider = [[UISlider alloc] init];
    
    slider.backgroundColor = [UIColor clearColor];
    slider.minimumTrackTintColor = [UIColor clearColor];
    slider.maximumTrackTintColor = [UIColor clearColor];
    UIImage *sliderImg = __ngt_sliderMakeImage([UIColor whiteColor],CGSizeMake(15, 15),7.5);
    [slider setThumbImage:sliderImg forState:UIControlStateNormal];
    _slider = slider;
    
    
    [self addSubview:durationLabel];
    [self addSubview:currentTimeLabel];
    [self addSubview:progressView];
    [self addSubview:slider];

    [slider addTarget:self action:@selector(slidingAction) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderTap:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)slidingAction{
    if (!_sliding){
        _sliding = YES;
    }
}
- (void)sliderTap:(UISlider *)slider{
    _sliding = NO;
    if (self.sliderBlock){
        self.sliderBlock(slider.value);
    }
    _progressView.progressOfBuffered = slider.value;
}
#pragma mark - Getter & Setter
- (void)setTimeText:(NSString *)timeText{
    _timeText = timeText;
    _currentTimeLabel.text = timeText;
}
- (void)setDurationText:(NSString *)durationText{
    _durationText = durationText;
    _durationLabel.text = durationText;
}
- (float)progress{
    return _progressView.progress;
}
- (void)setProgress:(float)progress{
    _progressView.progress = progress;
    _slider.value =  _progressView.progress;
}

- (float)progressOfBuffered{
    return _progressView.progressOfBuffered;
}
- (void)setProgressOfBuffered:(float)progressOfBuffered{
    _progressView.progressOfBuffered = progressOfBuffered;
}


- (void)setTextFontSize:(CGFloat)textFontSize{
    
    _textFontSize = textFontSize;
    
    _currentTimeLabel.font = [UIFont systemFontOfSize:textFontSize];
    _durationLabel.font = [UIFont systemFontOfSize:textFontSize];
    
    [self layoutSubviews];
}
- (void)setLineHeight:(CGFloat)lineHeight{
    _progressView.lineHeight = lineHeight;
}
- (CGFloat)lineHeight{
    return _progressView.lineHeight;
}
@end

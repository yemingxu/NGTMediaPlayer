//
//  NGTMediaPlayerSliderView.m
//  AVF_PlayerDemo
//
//  Created by JoeXu on 2017/6/19.
//  Copyright © 2017年 JoeXu. All rights reserved.
//

#import "NGTMediaPlayerProgressView.h"
@interface NGTMediaPlayerProgressView()
@property (nonatomic,strong) UIView *underPaintingView;
@property (nonatomic,strong) UIView *timeView;
@property (nonatomic,strong) UIView *timeOfBufferedView;

@end
@implementation NGTMediaPlayerProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    if (!(self = [super initWithFrame:frame])) return nil;
    _lineHeight = 2;
    
    _underpaintingColor = [UIColor colorWithRed:77/255.0 green:78/255.0 blue:79/255.0 alpha:1.0];
    _timeColor = [UIColor whiteColor];
    _timeOfBufferedColor = [UIColor colorWithRed:137/255.0 green:138/255.0 blue:139/255.0 alpha:1.0];;
    [self setupSubviews];
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self my_layoutSubviews];
}
- (void)my_layoutSubviews{
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
    @try {
        _underPaintingView.frame = (CGRect){0,(height-_lineHeight)/2.0,width,_lineHeight};
        _timeView.frame = (CGRect){0,(height-_lineHeight)/2.0,width*_progress,_lineHeight};
        _timeOfBufferedView.frame = (CGRect){0,(height-_lineHeight)/2.0,width*_progressOfBuffered,_lineHeight};
    } @catch (NSException *exception) {
        NSLog(@"exception: %@",exception);
    } @finally {
        
    }
}
- (void)setupSubviews{
    UIView *underPaintingView = [[UIView alloc] initWithFrame:self.bounds];
    underPaintingView.backgroundColor = _underpaintingColor;
    _underPaintingView = underPaintingView;
    
    UIView *timeView = [[UIView alloc] initWithFrame:self.bounds];
    timeView.backgroundColor = _timeColor;
    _timeView = timeView;
    
    UIView *timeOfBufferedView = [[UIView alloc] initWithFrame:self.bounds];
    timeOfBufferedView.backgroundColor = _timeOfBufferedColor;
    _timeOfBufferedView = timeOfBufferedView;
    
    [self addSubview:underPaintingView];
    [self addSubview:timeOfBufferedView];
    [self addSubview:timeView];
}
- (void)setUnderpaintingColor:(UIColor *)underpaintingColor{
    _underpaintingColor = underpaintingColor;
    _underPaintingView.backgroundColor = underpaintingColor;
}
- (void)setTimeColor:(UIColor *)timeColor{
    _timeColor = timeColor;
    _timeView.backgroundColor = timeColor;
}
- (void)setTimeOfBufferedColor:(UIColor *)timeOfBufferedColor{
    _timeOfBufferedColor = timeOfBufferedColor;
    _timeOfBufferedView.backgroundColor = timeOfBufferedColor;
}
- (void)setProgress:(float)progress{
    if(progress<0.0){_progress = 0.0;}
    else if(progress > 1.0){_progress = 1.0;}
    else{_progress = progress;}
    
    [self my_layoutSubviews];
}
- (void)setProgressOfBuffered:(float)progressOfBuffered{
    if(progressOfBuffered<0.0){_progressOfBuffered = 0.0;}
    else if(progressOfBuffered > 1.0){_progressOfBuffered = 1.0;}
    else{_progressOfBuffered = progressOfBuffered;}
    
    [self my_layoutSubviews];
}

- (void)setLineHeight:(CGFloat)lineHeight{
    _lineHeight = lineHeight;
    
    [self my_layoutSubviews];
}
@end

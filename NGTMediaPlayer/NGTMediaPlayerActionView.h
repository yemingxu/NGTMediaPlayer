//
//  NGTMediaPlayerActionView.h
//  Youdoneed
//
//  Created by JoeXu on 2017/7/10.
//  Copyright © 2017年 李凌辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGTMediaPlayerSliderView.h"

@interface NGTMediaPlayerActionView : UIView

@property (nonatomic,assign,getter=isHiddenOfPlayPause) BOOL hiddenOfPlayPause;
@property (nonatomic,assign,getter=isSelectedOfPlayPause) BOOL selectedOfPlayPause;

- (void)setupCurrentTimeStr:(NSString *)string;
- (void)setupDurationTimeStr:(NSString *)string;

- (void)setupProgress:(float)progress;//0.0~1.0;
- (void)setupProgressOfBuffered:(float)progressOfBuffered;//0.0~1.0;

- (void)setupSliderBlock:(void(^)(float progress))block;

- (void)setupScreenTapBlock:(void(^)(UIButton *sender))block;

- (void)setupPlayPauseTapBlock:(void(^)(UIButton *sender))block;

@end

@interface UIButton (NGTMediaPlayer)
+ (instancetype)makeOfVideoPlayer;
@end

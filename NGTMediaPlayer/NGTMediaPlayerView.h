//
//  NGTMediaPlayerView.h
//  Youdoneed
//
//  Created by JoeXu on 2017/7/11.
//  Copyright © 2017年 李凌辉. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NGTMediaPlayerActionView.h"


@interface NGTMediaPlayerView : UIView
@property (nonatomic,weak) UIView *videoDrawView;

@property (nonatomic,strong) NGTMediaPlayerActionView *actionView;

@property (nonatomic,strong) UIButton *centerPlayPauseButton;

@property (nonatomic,copy) void(^singleTapBlock)(void);
@property (nonatomic,copy) void(^doubleTapBlock)(void);

- (void)deallocVideoView;
@end

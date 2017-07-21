//
//  YNNSVideoPlayerManagerViewBinder.h
//  Youdoneed
//
//  Created by JoeXu on 2017/7/11.
//  Copyright © 2017年 李凌辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class NGTMediaPlayerManager;
@class NGTMediaPlayerActionView;

@interface NGTMediaPlayerManagerViewBinder : NSObject

- (void)bindManager:(NGTMediaPlayerManager *)manager
      forActionView:(NGTMediaPlayerActionView *)actionView
otherPlayPauseButton:(UIButton *)playPauseButton;

- (void)unbind;
@end

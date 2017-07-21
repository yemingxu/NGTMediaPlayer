//
//  NGTMediaPlayerSliderView.h
//  AVF_PlayerDemo
//
//  Created by JoeXu on 2017/6/19.
//  Copyright © 2017年 JoeXu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NGTMediaPlayerSliderView : UIView
@property (nonatomic,assign) CGFloat textFontSize;
@property (nonatomic,assign) CGFloat lineHeight;


@property (nonatomic,copy) NSString *timeText;
@property (nonatomic,copy) NSString *durationText;

@property (nonatomic,assign) float progress;
@property (nonatomic,assign) float progressOfBuffered;
@property (nonatomic,copy) void(^sliderBlock)(float progress);


@property (nonatomic,assign, readonly,getter=isSliding) BOOL sliding;
@end

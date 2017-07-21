//
//  NGTMediaPlayerSliderView.h
//  AVF_PlayerDemo
//
//  Created by JoeXu on 2017/6/19.
//  Copyright © 2017年 JoeXu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NGTMediaPlayerProgressView : UIView
@property (nonatomic,strong) UIColor *underpaintingColor;

@property (nonatomic,strong) UIColor *timeColor;

@property (nonatomic,strong) UIColor *timeOfBufferedColor;

@property (nonatomic,assign) float progress;//0.0~1.0;
@property (nonatomic,assign) float progressOfBuffered;//0.0~1.0;


@property (nonatomic,assign) CGFloat lineHeight;

@end

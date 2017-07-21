//
//  ViewController.m
//  NGTMediaPlayerDemo
//
//  Created by JoeXu on 2017/7/21.
//  Copyright © 2017年 NightXu. All rights reserved.
//

#import "ViewController.h"

#import "NGTMediaPlayerManager.h"
#import "NGTMediaPlayerView.h"
#import "NGTMediaPlayerManagerViewBinder.h"

@interface ViewController ()


@property (nonatomic,strong) NGTMediaPlayerManagerViewBinder *binder;
@property (nonatomic,strong) NGTMediaPlayerManager *manager;
@property (nonatomic,strong) NGTMediaPlayerView *playView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlStr = @"http://mvideo.spriteapp.cn/video/2017/0613/0322abc4-5022-11e7-ab6a-1866daeb0df1_wpcco.mp4";
    NSURL *url = [NSURL URLWithString:urlStr];
    
    _binder = [[NGTMediaPlayerManagerViewBinder alloc] init];
    _manager = [[NGTMediaPlayerManager alloc] init];
    _playView = [[NGTMediaPlayerView alloc] initWithFrame:self.view.bounds];
    _playView.videoDrawView = _manager.drawView;
    [self.view addSubview:_playView];
    
    [_binder bindManager:_manager forActionView:_playView.actionView otherPlayPauseButton:_playView.centerPlayPauseButton];
    
    
    [_manager loadURL:url];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

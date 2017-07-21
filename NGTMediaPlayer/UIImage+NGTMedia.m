//
//  UIImage+NGTMedia.m
//
//  Created by JoeXu on 2017/6/19.
//  Copyright © 2017年 JoeXu. All rights reserved.
//

#import "UIImage+NGTMedia.h"

@implementation UIImage (NGTMedia)

+ (UIImage *)ngtMediaPlayerImageName:(NSString *)name{
    
    if(!name || name.length == 0){return nil;}
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"NGTMedia" ofType:@"bundle"];
    
    NSBundle *bundle = [[NSBundle alloc] initWithPath:path];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    NSString *reallyName = name.copy;
    
    if(scale == 3){
        reallyName = [NSString stringWithFormat:@"%@@3x",reallyName];
    }else{
        reallyName = [NSString stringWithFormat:@"%@@2x",reallyName];
    }
    NSString *imgPath = [bundle pathForResource:reallyName ofType:@"png"];
    return [UIImage imageNamed:imgPath];
}

@end


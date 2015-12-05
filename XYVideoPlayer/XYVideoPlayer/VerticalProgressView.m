//
//  VerticalProgressView.m
//  XYPlayer
//
//  Created by Echo on 15/11/25.
//  Copyright © 2015年 Liu Xuanyi. All rights reserved.
//

#import "VerticalProgressView.h"

// device verson float value
#define CURRENT_SYS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

// image STRETCH
#define LXY_STRETCH_IMAGE(image, edgeInsets) (CURRENT_SYS_VERSION < 6.0 ? [image stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top] : [image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch])

@implementation VerticalProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // 背景图像
        _trackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _trackView.backgroundColor = [UIColor colorWithRed:0.9999 green:1.0 blue:0.9998 alpha:0.5];
        _trackView.layer.masksToBounds = YES;
        _trackView.layer.cornerRadius = 1.5;
        [self addSubview:_trackView];
        // 填充图像
        _progressView = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, frame.size.height)];
        [_progressView setImage:LXY_STRETCH_IMAGE([UIImage imageNamed:@"progress_vertical_full"], UIEdgeInsetsMake(4, 1, 4, 1))];
        [_trackView addSubview:_progressView];
        
        _currentProgress = 0.0;
        
    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    if (0 == progress) {
        self.currentProgress = 0;
        [self changeProgressViewFrame];
        return;
    }
    
    _targetProgress = progress;
    [self moveProgress];
}

//////////////////////////////////////////////////////
//修改进度
- (void) moveProgress
{
    self.currentProgress = MIN(self.currentProgress + 0.1*_targetProgress, _targetProgress);
    if (_targetProgress >=10) {
        [_delegate changeTextProgress:[NSString stringWithFormat:@"%d %%",(int)self.currentProgress]];
    }else{
        [_delegate changeTextProgress:[NSString stringWithFormat:@"%.1f %%",self.currentProgress]];
    }
    
    //改变界面内容
    [self changeProgressViewFrame];
}
//修改显示内容
- (void)changeProgressViewFrame{
    //只要改变frame的x的坐标就能看到进度一样的效果
    _progressView.frame = CGRectMake(0, self.frame.size.height - (self.frame.size.height * _currentProgress), self.frame.size.width, self.frame.size.height * _currentProgress);
}

@end

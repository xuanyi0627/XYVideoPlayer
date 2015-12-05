//
//  VerticalProgressView.h
//  XYPlayer
//
//  Created by Echo on 15/11/25.
//  Copyright © 2015年 Liu Xuanyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  VerticalProgressViewDelegate<NSObject>
//修改进度标签内容
- (void)changeTextProgress:(NSString*)string;
//进度条结束时
- (void)endTime;
@end

@interface VerticalProgressView : UIView

// 背景图像
@property (retain, nonatomic) UIView *trackView;
// 填充图像
@property (retain, nonatomic) UIImageView *progressView;

@property (nonatomic) CGFloat targetProgress; //进度
@property (nonatomic) CGFloat currentProgress; //当前进度

@property (nonatomic, strong)id<VerticalProgressViewDelegate> delegate;

- (void)setProgress:(CGFloat)progress;//设置进度

@end

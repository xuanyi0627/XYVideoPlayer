//
//  XYVideoViewControlView.h
//  XYPlayer
//
//  Created by Echo on 15/11/23.
//  Copyright © 2015年 Liu Xuanyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerticalProgressView.h"

@protocol XYVideoViewControlViewDelegate <NSObject>

-(void)PalyOrPause;
-(void)GoBackUp:(CGFloat)second;
-(void)GoForward:(CGFloat)second;
-(void)GoChangeTimeBegin;
-(void)GoChangeTimeEnd:(CGFloat)second;

@end

@interface XYVideoViewControlView : UIView

@property (nonatomic, weak) id<XYVideoViewControlViewDelegate> delegate;

@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, strong, readonly) UIVisualEffectView *topBar;
@property (nonatomic, strong, readonly) UIVisualEffectView *bottomBar;

@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) UIButton *pauseButton;

@property (nonatomic, strong, readonly) UIButton *fullScreenButton;
@property (nonatomic, strong, readonly) UIButton *shrinkScreenButton;
@property (nonatomic, strong, readonly) UISlider *progressSlider;
@property (nonatomic, strong, readonly) UIButton *closeButton;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UILabel *fullTimeLabel;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong, readonly) UIImageView *playImageView;
@property (nonatomic, strong, readonly) UIImageView *PauseImageView;
@property (nonatomic, strong, readonly) UIImageView *goforwardView;
@property (nonatomic, strong, readonly) UIImageView *gobackView;
@property (nonatomic, strong, readonly) UILabel *gobackORgoforwardLabel;

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *detailLabel;
@property (nonatomic, strong, readonly) UIButton *likeButton;
@property (nonatomic, strong, readonly) UIButton *shareButton;

@property (nonatomic, strong, readonly) UIImageView *voiceImageView;
@property (nonatomic, strong, readonly) UIImageView *luminanceImageView;
@property (nonatomic, strong, readonly) VerticalProgressView *voiceProgress;
@property (nonatomic, strong, readonly) VerticalProgressView *luminanceProgress;

- (void)animateHide;
- (void)animateShow;
- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;

@end

//
//  XYVideoViewControlView.m
//  XYPlayer
//
//  Created by Echo on 15/11/23.
//  Copyright © 2015年 Liu Xuanyi. All rights reserved.
//

#import "XYVideoViewControlView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

static const CGFloat kVideoControlTopBarHeight = 49.0;
static const CGFloat kVideoControlBottomBarHeight = 54.0;
static const CGFloat kVideoControlBottomBarHeight_Little = 40.0;
static const CGFloat kVideoControlAnimationTimeinterval = 0.3;
static const CGFloat kVideoControlTimeLabelFontSize = 14.0;
static const CGFloat kVideoControlTimeLabelFontSize_Little = 10.0;
static const CGFloat kVideoControlTitleLabelFontSize = 14.0;
static const CGFloat kVideoControlDetailLabelFontSize = 10.0;
static const CGFloat kVideoControlBarAutoFadeOutTimeinterval = 5.0;

static const CGFloat kBottomPlayButtonLeft = 20.0;
static const CGFloat kBottomPlayButtonSize = 25.0;

static const CGFloat kBottomPlayButtonLeft_Little = 16.0;
static const CGFloat kBottomPlayButtonSize_Little = 23.0;

static const CGFloat kBottomFullScreenButtonRight = 20.0;
static const CGFloat kBottomFullScreenButtonRight_Little = 16.0;
static const CGFloat kBottomFullScreenButtonSize = 22.0;
static const CGFloat kBottomFullScreenButtonSize_Little = 20.0;

static const CGFloat kTopCloseBottonLeft = 20.0;
static const CGFloat kTopCloseBottonSizeWidth = 11.0;
static const CGFloat kTopCloseBottonSizeHeight = 18.0;

static const CGFloat kTopTitleLabelY = 8.5;
static const CGFloat kTopTitleLabelHight = 15.0;

static const CGFloat kTopDetailLabelY = 29;
static const CGFloat kTopDetailLabelHight = 12;

static const CGFloat kTopLabelX = 49;

static const CGFloat kTopLikeButtonRight = 77.5;
static const CGFloat kTopLikeButtonSize = 18;

static const CGFloat kTopShareButtonRight = 35;
static const CGFloat kTopShareButtonWidth = 15;
static const CGFloat kTopShareButtonHeight = 18;

static const CGFloat kPlayORPauseImageViewWidth = 46;
static const CGFloat kPlayORPauseImageViewHeight = 50.5;

static const CGFloat kGoBackImageViewWidth = 55;
static const CGFloat kGoBackImageViewHeight = 42;

static const CGFloat kGobackORGoforwardLabelFontSize = 14;
static const CGFloat kGobackORGoforwardLabelWidth = 100;
static const CGFloat kGobackORGoforwardLabelHeight = 16;
static const CGFloat kGobackORGoforwardLabelToImage = 15;

static const CGFloat kLuminanceOrVoiceViewWidth = 3;
static const CGFloat kLuminanceOrVoiceViewHeight = 122;

static const CGFloat kLuminanceViewRight = 29;
static const CGFloat kVoiceViewLeft = 29;

static const CGFloat kVoiceViewToImageSpanHeight = 8;

static const CGFloat kLuminanceImageRight = 21;
static const CGFloat kLuminanceImageSize = 19;

static const CGFloat kVoiceImageLeft = 20;
static const CGFloat kVoiceImageWidth = 21;
static const CGFloat kVoiceImageHeight = 19;

static const CGFloat kProgressToLabelSpanWidth = 18;
static const CGFloat kProgressToLabelSpanWidth_Little = 8;

static const CGFloat kTimeLabelWidth = 44.0;
static const CGFloat kTimeLabelHeigth = 16.0;

static const CGFloat kTimeLabelWidth_Little = 33.0;
static const CGFloat kTimeLabelHeigth_Little = 11.0;

static const CGFloat kOFFSET = 0.2; // 快进和快退的时间跨度

@interface XYVideoViewControlView () {
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    CGFloat brightness; // 屏幕亮度
    CGFloat sysVolume; // 系统声音
    CGFloat playerProgress; // 播放进度
    
    // 手势初始X和Y坐标
    CGFloat beginTouchX;
    CGFloat beginTouchY;
    // 手势相对于初始X和Y坐标的偏移量
    CGFloat offsetX;
    CGFloat offsetY;
}

@property (nonatomic, strong) UIVisualEffectView *topBar;
@property (nonatomic, strong) UIVisualEffectView *bottomBar;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *shrinkScreenButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *fullTimeLabel;
@property (nonatomic, assign) BOOL isBarShowing;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UIImageView *PauseImageView;
@property (nonatomic, strong) UIImageView *goforwardView;
@property (nonatomic, strong) UIImageView *gobackView;
@property (nonatomic, strong) UILabel *gobackORgoforwardLabel;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *shareButton;

@property (nonatomic, strong) UIImageView *voiceImageView;
@property (nonatomic, strong) UIImageView *luminanceImageView;
@property (nonatomic, strong) VerticalProgressView *voiceProgress;
@property (nonatomic, strong) VerticalProgressView *luminanceProgress;

@end

@implementation XYVideoViewControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.topBar];
        [self.topBar addSubview:self.closeButton];
        [self.topBar addSubview:self.likeButton];
        [self.topBar addSubview:self.shareButton];
        [self.topBar addSubview:self.titleLabel];
        [self.topBar addSubview:self.detailLabel];
        [self addSubview:self.bottomBar];
        [self.bottomBar addSubview:self.playButton];
        [self.bottomBar addSubview:self.pauseButton];
        self.pauseButton.hidden = YES;
        [self.bottomBar addSubview:self.fullScreenButton];
        [self.bottomBar addSubview:self.shrinkScreenButton];
        self.shrinkScreenButton.hidden = YES;
        [self.bottomBar addSubview:self.progressSlider];
        [self.bottomBar addSubview:self.timeLabel];
        [self.bottomBar addSubview:self.fullTimeLabel];
        [self addSubview:self.playImageView];
        [self addSubview:self.PauseImageView];
        [self addSubview:self.gobackView];
        [self addSubview:self.goforwardView];
        [self addSubview:self.gobackORgoforwardLabel];
        [self addSubview:self.indicatorView];
        [self addSubview:self.luminanceProgress];
        [self addSubview:self.voiceProgress];
        [self addSubview:self.luminanceImageView];
        [self addSubview:self.voiceImageView];
        
        self.luminanceImageView.hidden = YES;
        self.luminanceProgress.hidden = YES;
        self.voiceImageView.hidden = YES;
        self.voiceProgress.hidden = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired  = 1;
        [self addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *playGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playORPause:)];
        playGesture.numberOfTapsRequired = 2;
        playGesture.numberOfTouchesRequired  = 1;
        [self addGestureRecognizer:playGesture];
        
        [tapGesture requireGestureRecognizerToFail:playGesture];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    screenWidth = CGRectGetWidth(self.bounds);
    screenHeight = CGRectGetHeight(self.bounds);
    
    if (_isFullScreen == YES) {
        self.topBar.hidden = NO;
        self.closeButton.hidden = NO;
        self.shareButton.hidden = NO;
        self.likeButton.hidden = NO;
        self.titleLabel.hidden = NO;
        self.detailLabel.hidden = NO;
        
        self.topBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), kVideoControlTopBarHeight);
        
        self.closeButton.frame = CGRectMake(kTopCloseBottonLeft, (kVideoControlTopBarHeight-kTopCloseBottonSizeHeight)/2, CGRectGetWidth(self.closeButton.bounds), CGRectGetHeight(self.closeButton.bounds));
        
        self.titleLabel.frame = CGRectMake(kTopLabelX, kTopTitleLabelY, CGRectGetWidth(self.topBar.bounds) - kTopLabelX - kTopShareButtonRight - 10, kTopTitleLabelHight);
        
        self.detailLabel.frame = CGRectMake(kTopLabelX, kTopDetailLabelY, CGRectGetWidth(self.topBar.bounds) - kTopLabelX - kTopShareButtonRight - 10, kTopDetailLabelHight);
        
        self.likeButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - kTopLikeButtonRight, CGRectGetHeight(self.topBar.bounds)/2 - CGRectGetHeight(self.likeButton.bounds)/2, CGRectGetWidth(self.likeButton.bounds), CGRectGetHeight(self.likeButton.bounds));
        
        self.shareButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - kTopShareButtonRight, CGRectGetHeight(self.topBar.bounds)/2 - CGRectGetHeight(self.shareButton.bounds)/2, CGRectGetWidth(self.shareButton.bounds), CGRectGetHeight(self.shareButton.bounds));
    }
    else {
        self.topBar.hidden = YES;
        self.closeButton.hidden = YES;
        self.shareButton.hidden = YES;
        self.likeButton.hidden = YES;
        self.titleLabel.hidden = YES;
        self.detailLabel.hidden = YES;
    }
    
    if (_isFullScreen == YES) {
        self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - kVideoControlBottomBarHeight, CGRectGetWidth(self.bounds), kVideoControlBottomBarHeight);
    } else {
        self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - kVideoControlBottomBarHeight_Little, CGRectGetWidth(self.bounds), kVideoControlBottomBarHeight_Little);
    }
    
    NSString *playButtonImageName = @"";
    NSString *pauseButtonImageName = @"";
    CGFloat playButtonX = 0;
    CGFloat playButtonY = 0;
    CGFloat playButtonSize = 0;
    if (_isFullScreen == YES) {
        playButtonImageName = @"kr-video-player-play";
        pauseButtonImageName = @"kr-video-player-pause";
        playButtonX = CGRectGetMinX(self.bottomBar.bounds)+kBottomPlayButtonLeft;
        playButtonY = CGRectGetHeight(self.bottomBar.bounds)/2 - kBottomPlayButtonSize/2;
        playButtonSize = kBottomPlayButtonSize;
        
    } else {
        playButtonImageName = @"kr-video-player-play-little";
        pauseButtonImageName = @"kr-video-player-pause-little";
        playButtonX = CGRectGetMinX(self.bottomBar.bounds)+kBottomPlayButtonLeft_Little;
        playButtonY = CGRectGetHeight(self.bottomBar.bounds)/2 - kBottomPlayButtonSize_Little/2;
        playButtonSize = kBottomPlayButtonSize_Little;
    }
    self.playButton.frame = CGRectMake(playButtonX, playButtonY, playButtonSize, playButtonSize);
    self.pauseButton.frame = self.playButton.frame;
    [self.playButton setImage:[UIImage imageNamed:playButtonImageName] forState:UIControlStateNormal];
    [self.pauseButton setImage:[UIImage imageNamed:pauseButtonImageName] forState:UIControlStateNormal];
    
    CGFloat fullScreenButtonRight = 0;
    CGFloat fullScreenButtonSize = 0;
    if (_isFullScreen == YES) {
        fullScreenButtonRight = kBottomFullScreenButtonRight;
        fullScreenButtonSize = kBottomFullScreenButtonSize;
    } else {
        fullScreenButtonRight = kBottomFullScreenButtonRight_Little;
        fullScreenButtonSize = kBottomFullScreenButtonSize_Little;
    }
    
    self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - fullScreenButtonSize - fullScreenButtonRight, CGRectGetHeight(self.bottomBar.bounds)/2 - fullScreenButtonSize/2, fullScreenButtonSize, fullScreenButtonSize);
    self.shrinkScreenButton.frame = self.fullScreenButton.frame;
    
    CGFloat progressSliderWidth = 0;
    CGFloat progressSliderX = 0;
    CGFloat timeFontSize = 0;
    CGFloat timeWidth = 0;
    CGFloat timeHeigth = 0;
    CGFloat span = 0;
    if (_isFullScreen == YES) {
        progressSliderWidth = CGRectGetWidth(self.bounds)*768/1334;
        progressSliderX = (CGRectGetWidth(self.bottomBar.frame)-progressSliderWidth)/2;
        timeFontSize = kVideoControlTimeLabelFontSize;
        timeWidth = kTimeLabelWidth;
        timeHeigth = kTimeLabelHeigth;
        span = kProgressToLabelSpanWidth;
        
    } else {
        progressSliderWidth = CGRectGetWidth(self.bounds)*413/750;
        progressSliderX = (CGRectGetWidth(self.bottomBar.frame)-progressSliderWidth)/2;
        timeFontSize = kVideoControlTimeLabelFontSize_Little;
        timeWidth = kTimeLabelWidth_Little;
        timeHeigth = kTimeLabelHeigth_Little;
        span = kProgressToLabelSpanWidth_Little;
    }
    
    self.progressSlider.frame = CGRectMake(progressSliderX,
                                           CGRectGetHeight(self.bottomBar.bounds)/2 - timeHeigth/2,
                                           progressSliderWidth,
                                           timeHeigth);
    
    self.fullTimeLabel.frame = CGRectMake(progressSliderX+progressSliderWidth+span,
                                          (CGRectGetHeight(self.bottomBar.bounds) - timeHeigth)/2,
                                          timeWidth,
                                          timeHeigth);
    self.fullTimeLabel.font = [UIFont systemFontOfSize:timeFontSize];
    
    self.timeLabel.frame = CGRectMake(progressSliderX - span - timeWidth,
                                      (CGRectGetHeight(self.bottomBar.bounds) - timeHeigth)/2,
                                      timeWidth,
                                      timeHeigth);
    self.timeLabel.font = [UIFont systemFontOfSize:timeFontSize];
    
    self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.playImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.PauseImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.gobackView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.goforwardView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    self.gobackORgoforwardLabel.frame = CGRectMake((screenWidth-CGRectGetWidth(self.gobackORgoforwardLabel.bounds))/2+5,
                                                   CGRectGetMidY(self.bounds) - kGoBackImageViewHeight/2 - kGobackORGoforwardLabelToImage - kGobackORGoforwardLabelHeight,
                                                   CGRectGetWidth(self.gobackORgoforwardLabel.bounds),
                                                   CGRectGetHeight(self.gobackORgoforwardLabel.bounds));
    
    self.luminanceProgress.frame = CGRectMake(CGRectGetWidth(self.bounds) - kLuminanceOrVoiceViewWidth - kLuminanceViewRight,
                                              (CGRectGetHeight(self.bounds) - (CGRectGetHeight(self.luminanceProgress.bounds)+kVoiceViewToImageSpanHeight+kLuminanceImageSize))/2,
                                              CGRectGetWidth(self.luminanceProgress.bounds),
                                              CGRectGetHeight(self.luminanceProgress.bounds));
    
    self.voiceProgress.frame = CGRectMake(kVoiceViewLeft,
                                          (CGRectGetHeight(self.bounds) - (CGRectGetHeight(self.voiceProgress.bounds)+kVoiceViewToImageSpanHeight+kVoiceImageHeight))/2,
                                          CGRectGetWidth(self.voiceProgress.bounds),
                                          CGRectGetHeight(self.voiceProgress.bounds));
    
    self.voiceImageView.frame = CGRectMake(kVoiceImageLeft,
                                           (CGRectGetHeight(self.bounds) - (CGRectGetHeight(self.voiceProgress.bounds)+kVoiceViewToImageSpanHeight+kVoiceImageHeight))/2 + CGRectGetHeight(self.voiceProgress.bounds) + kVoiceViewToImageSpanHeight,
                                           CGRectGetWidth(self.voiceImageView.bounds),
                                           CGRectGetHeight(self.voiceImageView.bounds));
    
    self.luminanceImageView.frame = CGRectMake(CGRectGetWidth(self.bounds) - kLuminanceImageSize - kLuminanceImageRight,
                                               (CGRectGetHeight(self.bounds) - (CGRectGetHeight(self.luminanceProgress.bounds)+kVoiceViewToImageSpanHeight+kLuminanceImageSize))/2 + CGRectGetHeight(self.luminanceProgress.bounds) + kVoiceViewToImageSpanHeight,
                                               CGRectGetWidth(self.luminanceImageView.bounds),
                                               CGRectGetHeight(self.luminanceImageView.bounds));
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.isBarShowing = YES;
}


- (void)animateHide
{
    if (!self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = NO;
    }];
}

- (void)animateShow
{
    if (self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 1.0;
        self.bottomBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

- (void)autoFadeOutControlBar
{
    if (!self.isBarShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:kVideoControlBarAutoFadeOutTimeinterval];
}

- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}

- (void)onTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        // 初始的X和Y坐标
        CGFloat y = [gesture locationInView:gesture.view].y;
        if (y > kVideoControlTopBarHeight && y < (CGRectGetHeight(self.bounds) - kVideoControlBottomBarHeight)) {
            if (self.isBarShowing) {
                [self animateHide];
            } else {
                [self animateShow];
            }
        }
    }
}

- (void)playORPause:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGFloat y = [gesture locationInView:gesture.view].y;
        if (y > kVideoControlTopBarHeight && y < (CGRectGetHeight(self.bounds) - kVideoControlBottomBarHeight)) {
            if ([self.delegate respondsToSelector:@selector(PalyOrPause)]) {
                [self.delegate PalyOrPause];
            }
        }
    }
}

#pragma mark - touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *oneTouch = [touches anyObject];
    
    if (_isFullScreen == YES) {
        // 初始的X和Y坐标
        beginTouchX = [oneTouch locationInView:oneTouch.view].x;
        beginTouchY = [oneTouch locationInView:oneTouch.view].y;
        
        // 初始的亮度
        brightness = [UIScreen mainScreen].brightness;
        
        // 初始的音量
        sysVolume = [[AVAudioSession sharedInstance] outputVolume];
        
        if ([self.delegate respondsToSelector:@selector(GoChangeTimeBegin)]) {
            [self.delegate GoChangeTimeBegin];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *oneTouch = [touches anyObject];
    
    if (_isFullScreen == YES) {
        if (beginTouchY > kVideoControlTopBarHeight && beginTouchY < (CGRectGetHeight(self.bounds) - kVideoControlBottomBarHeight)) {
            // 手势相对于初始坐标的偏移量
            offsetX = [oneTouch locationInView:oneTouch.view].x - beginTouchX;
            offsetY = [oneTouch locationInView:oneTouch.view].y - beginTouchY;
            
            // 要改变的音量或亮度
            CGFloat delta = -offsetY / screenHeight;
            
            CGFloat touchX = [oneTouch locationInView:oneTouch.view].x;
            
            // offsetY != 0 说明有上下位移，对亮度和声音就应该有改变
            if (touchX < (1.0/3 * screenWidth) && offsetY != 0) {
                // 上下滑动改变音量
                self.voiceImageView.hidden = NO;
                self.voiceProgress.hidden = NO;
                self.gobackView.hidden = YES;
                self.goforwardView.hidden = YES;
                self.gobackORgoforwardLabel.hidden = YES;
                if (sysVolume + delta > 0.0 && sysVolume + delta < 1.0) {
                    //            [volumeSlider setValue:sysVolume + delta]; // 设置音量
                    NSLog(@"sysVolume = %f",sysVolume + delta);
                    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
                    volumeView.frame = CGRectMake(-1000, -1000, 100, 100);
                    volumeView.showsRouteButton = NO;
                    volumeView.userInteractionEnabled = NO;
                    UISlider* volumeViewSlider = nil;
                    for (UIView *view in [volumeView subviews]){
                        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                            volumeViewSlider = (UISlider*)view;
                            break;
                        }
                    }
                    [self addSubview:volumeView];
                    [volumeViewSlider setValue:(sysVolume + delta) animated:NO];
                    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
                    [self.voiceProgress setProgress:(sysVolume + delta)];
                }
                
            }
            else if (touchX > (2.0/3 * screenWidth) && offsetY != 0 ) {
                
                // 上下滑动改变亮度
                self.luminanceImageView.hidden = NO;
                self.luminanceProgress.hidden = NO;
                self.gobackView.hidden = YES;
                self.goforwardView.hidden = YES;
                self.gobackORgoforwardLabel.hidden = YES;
                if (brightness + delta > 0.0 && brightness + delta < 1.0) {
                    [[UIScreen mainScreen] setBrightness:brightness + delta]; // 设置屏幕亮度
                    [self.luminanceProgress setProgress:(brightness + delta)];
                }
            }
            else if (touchX > (1.0/3 * screenWidth) && touchX < (2.0/3 * screenWidth) && offsetX != 0) {
            // 中屏幕中间左右滑动改变进度
                if (offsetX > 0) {
                    self.gobackView.hidden = YES;
                    self.goforwardView.hidden = NO;
                    self.gobackORgoforwardLabel.hidden = NO;
                    playerProgress = offsetX*kOFFSET;
                    if ([self.delegate respondsToSelector:@selector(GoForward:)]) {
                        [self.delegate GoForward:(offsetX*kOFFSET)];
                    }
                }
                else {
                    self.gobackView.hidden = NO;
                    self.goforwardView.hidden = YES;
                    self.gobackORgoforwardLabel.hidden = NO;
                    playerProgress = -offsetX*kOFFSET;
                    if ([self.delegate respondsToSelector:@selector(GoBackUp:)]) {
                        [self.delegate GoBackUp:(-offsetX*kOFFSET)];
                    }
                }
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
//    UITouch *oneTouch = [touches anyObject];
    if (_isFullScreen == YES) {
//        CGFloat touchX = [oneTouch locationInView:oneTouch.view].x;
//        if (touchX > (1.0/3 * screenWidth) && touchX < (2.0/3 * screenWidth) && offsetX != 0) {
//            if ([self.delegate respondsToSelector:@selector(GoChangeTimeEnd:)]) {
//                [self.delegate GoChangeTimeEnd:playerProgress];
//            }
//        }
        [self delayHideProgressOrImageView];
    }
}

- (void)delayHideProgressOrImageView {
    self.gobackView.hidden = YES;
    self.goforwardView.hidden = YES;
    self.gobackORgoforwardLabel.hidden = YES;
    [self performSelector:@selector(HideProgressOrImageView) withObject:nil afterDelay:2.0f];
}

- (void)HideProgressOrImageView {
    self.luminanceImageView.hidden = YES;
    self.luminanceProgress.hidden = YES;
    self.voiceImageView.hidden = YES;
    self.voiceProgress.hidden = YES;
}

#pragma mark - Property

- (UIView *)topBar
{
    if (!_topBar) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _topBar = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _topBar.frame = _topBar.bounds;
        _topBar.contentView.backgroundColor = [UIColor colorWithRed:0.0795 green:0.1062 blue:0.1301 alpha:0.4];
        _topBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _topBar;
}

- (UIView *)bottomBar
{
    if (!_bottomBar) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _bottomBar = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _bottomBar.frame = _bottomBar.bounds;
        _bottomBar.contentView.backgroundColor = [UIColor colorWithRed:0.0795 green:0.1062 blue:0.1301 alpha:0.4];
        _bottomBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _bottomBar;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"kr-video-player-play"] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(kBottomPlayButtonLeft, (kVideoControlBottomBarHeight-kBottomPlayButtonSize)/2, kBottomPlayButtonSize, kBottomPlayButtonSize);
    }
    return _playButton;
}

- (UIButton *)pauseButton
{
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setImage:[UIImage imageNamed:@"kr-video-player-pause"] forState:UIControlStateNormal];
        _pauseButton.bounds = CGRectMake(kBottomPlayButtonLeft, (kVideoControlBottomBarHeight-kBottomPlayButtonSize)/2, kBottomPlayButtonSize, kBottomPlayButtonSize);
    }
    return _pauseButton;
}

- (UIImageView *)playImageView
{
    if (!_playImageView) {
        _playImageView = [[UIImageView alloc] init];
        _playImageView.contentMode = UIViewContentModeScaleAspectFit;
        _playImageView.image = [UIImage imageNamed:@"kr-video-player-play-image"];
        _playImageView.bounds = CGRectMake(0, 0, kPlayORPauseImageViewWidth, kPlayORPauseImageViewHeight);
    }
    return _playImageView;
}

- (UIImageView *)PauseImageView
{
    if (!_PauseImageView) {
        _PauseImageView = [[UIImageView alloc] init];
        _PauseImageView.contentMode = UIViewContentModeScaleAspectFit;
        _PauseImageView.image = [UIImage imageNamed:@"kr-video-player-pause-image"];
        _PauseImageView.bounds = CGRectMake(0, 0, kPlayORPauseImageViewWidth, kPlayORPauseImageViewHeight);
    }
    return _PauseImageView;
}

- (UIImageView *)goforwardView
{
    if (!_goforwardView) {
        _goforwardView = [[UIImageView alloc] init];
        _goforwardView.contentMode = UIViewContentModeScaleAspectFit;
        _goforwardView.image = [UIImage imageNamed:@"kr-video-player-fast-forward"];
        _goforwardView.bounds = CGRectMake(0, 0, kGoBackImageViewWidth, kGoBackImageViewHeight);
    }
    return _goforwardView;
}

- (UIImageView *)gobackView
{
    if (!_gobackView) {
        _gobackView = [[UIImageView alloc] init];
        _gobackView.contentMode = UIViewContentModeScaleAspectFit;
        _gobackView.image = [UIImage imageNamed:@"kr-video-player-fast-backup"];
        _gobackView.bounds = CGRectMake(0, 0, kGoBackImageViewWidth, kGoBackImageViewHeight);
    }
    return _gobackView;
}

- (UILabel *)gobackORgoforwardLabel
{
    if (!_gobackORgoforwardLabel) {
        _gobackORgoforwardLabel = [UILabel new];
        _gobackORgoforwardLabel.backgroundColor = [UIColor clearColor];
        _gobackORgoforwardLabel.font = [UIFont systemFontOfSize:kGobackORGoforwardLabelFontSize];
        _gobackORgoforwardLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
        _gobackORgoforwardLabel.textAlignment = NSTextAlignmentLeft;
        _gobackORgoforwardLabel.bounds = CGRectMake(0, 0, kGobackORGoforwardLabelWidth, kGobackORGoforwardLabelHeight);
    }
    return _gobackORgoforwardLabel;
}

- (UIButton *)shrinkScreenButton
{
    if (!_shrinkScreenButton) {
        _shrinkScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shrinkScreenButton setImage:[UIImage imageNamed:@"kr-video-player-shrinkscreen"] forState:UIControlStateNormal];
        _shrinkScreenButton.bounds = CGRectMake(0, (kVideoControlBottomBarHeight-kBottomFullScreenButtonSize)/2, kBottomFullScreenButtonSize, kBottomFullScreenButtonSize);
    }
    return _shrinkScreenButton;
}

- (UIButton *)fullScreenButton
{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:@"kr-video-player-fullscreen"] forState:UIControlStateNormal];
        _fullScreenButton.bounds = CGRectMake(0, (kVideoControlBottomBarHeight-kBottomFullScreenButtonSize)/2, kBottomFullScreenButtonSize, kBottomFullScreenButtonSize);
    }
    return _fullScreenButton;
}

- (UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        _progressSlider.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds)*768/1334, 20);
        [_progressSlider setThumbImage:[UIImage imageNamed:@"kr-video-player-point"] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:[UIColor colorWithRed:0.9725 green:0.6745 blue:0.0353 alpha:0.9]];
        [_progressSlider setMaximumTrackTintColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3]];
        _progressSlider.value = 0.f;
        _progressSlider.continuous = YES;
    }
    return _progressSlider;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"bar-icon-back"] forState:UIControlStateNormal];
        _closeButton.bounds = CGRectMake(kTopCloseBottonLeft, 0, kTopCloseBottonSizeWidth, kTopCloseBottonSizeHeight);
    }
    return _closeButton;
}

- (UIButton *)shareButton
{
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:[UIImage imageNamed:@"tv-detail-share"] forState:UIControlStateNormal];
        _shareButton.bounds = CGRectMake(0, 0, kTopShareButtonWidth, kTopShareButtonHeight);
    }
    return _shareButton;
}

- (UIButton *)likeButton
{
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likeButton setImage:[UIImage imageNamed:@"tv-detail-like"] forState:UIControlStateNormal];
        _likeButton.bounds = CGRectMake(0, 0, kTopLikeButtonSize, kTopLikeButtonSize);
    }
    return _likeButton;
}

- (UILabel *)fullTimeLabel
{
    if (!_fullTimeLabel) {
        _fullTimeLabel = [UILabel new];
        _fullTimeLabel.backgroundColor = [UIColor clearColor];
        _fullTimeLabel.font = [UIFont systemFontOfSize:kVideoControlTimeLabelFontSize];
        _fullTimeLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
        _fullTimeLabel.textAlignment = NSTextAlignmentLeft;
        _fullTimeLabel.bounds = CGRectMake(0, 0, kTimeLabelWidth, kTimeLabelHeigth);
    }
    return _fullTimeLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:kVideoControlTimeLabelFontSize];
        _timeLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.bounds = CGRectMake(0, 0, kTimeLabelWidth, kTimeLabelHeigth);
    }
    return _timeLabel;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:kVideoControlTitleLabelFontSize];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.bounds = CGRectMake(0, 0, kTopTitleLabelHight, kTopTitleLabelHight);
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel = [UILabel new];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = [UIFont systemFontOfSize:kVideoControlDetailLabelFontSize];
        _detailLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.bounds = CGRectMake(0, 0, kTopDetailLabelHight, kTopDetailLabelHight);
    }
    return _detailLabel;
}

- (VerticalProgressView *)luminanceProgress
{
    if (!_luminanceProgress) {
        _luminanceProgress = [[VerticalProgressView alloc] initWithFrame:CGRectMake(0, 0, kLuminanceOrVoiceViewWidth, kLuminanceOrVoiceViewHeight)];
        _luminanceProgress.backgroundColor = [UIColor colorWithRed:0.8674 green:0.0 blue:0.0 alpha:0.0];
        _luminanceProgress.currentProgress = 0.5;
//        _luminanceProgress.bounds = CGRectMake(0, 0, kLuminanceOrVoiceViewWidth, kLuminanceOrVoiceViewHeight);
    }
    return _luminanceProgress;
}

- (VerticalProgressView *)voiceProgress
{
    if (!_voiceProgress) {
        _voiceProgress = [[VerticalProgressView alloc] initWithFrame:CGRectMake(0, 0, kLuminanceOrVoiceViewWidth, kLuminanceOrVoiceViewHeight)];
        _voiceProgress.backgroundColor = [UIColor colorWithRed:0.8674 green:0.0 blue:0.0 alpha:0.0];
        _voiceProgress.currentProgress = 0;
//        _voiceProgress.bounds = CGRectMake(0, 0, kLuminanceOrVoiceViewWidth, kLuminanceOrVoiceViewHeight);
    }
    return _voiceProgress;
}

- (UIImageView *)voiceImageView
{
    if (!_voiceImageView) {
        _voiceImageView = [[UIImageView alloc] init];
        _voiceImageView.contentMode = UIViewContentModeScaleAspectFit;
        _voiceImageView.image = [UIImage imageNamed:@"player-volume"];
        _voiceImageView.bounds = CGRectMake(0, 0, kVoiceImageWidth, kVoiceImageHeight);
    }
    return _voiceImageView;
}

- (UIImageView *)luminanceImageView
{
    if (!_luminanceImageView) {
        _luminanceImageView = [[UIImageView alloc] init];
        _luminanceImageView.contentMode = UIViewContentModeScaleAspectFit;
        _luminanceImageView.image = [UIImage imageNamed:@"player-bright"];
        _luminanceImageView.bounds = CGRectMake(0, 0, kLuminanceImageSize, kLuminanceImageSize);
    }
    return _luminanceImageView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_indicatorView stopAnimating];
    }
    return _indicatorView;
}
  

@end

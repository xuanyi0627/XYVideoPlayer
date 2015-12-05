//
//  XYPlayerController.m
//  XYPlayer
//
//  Created by Echo on 15/11/23.
//  Copyright © 2015年 Liu Xuanyi. All rights reserved.
//

#import "XYPlayerController.h"
#import "XYVideoViewControlView.h"

static const CGFloat kVideoPlayerControllerAnimationTimeinterval = 0.3f;

@interface XYPlayerController () <XYVideoViewControlViewDelegate> {
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    CGFloat playerProgress; // 播放进度
    
    // 手势初始X和Y坐标
    CGFloat beginTouchX;
    CGFloat beginTouchY;
    // 手势相对于初始X和Y坐标的偏移量
    CGFloat offsetX;
    CGFloat offsetY;
}

@property (nonatomic, strong) XYVideoViewControlView *videoControl;
@property (nonatomic, strong) UIView *movieBackgroundView;
@property (nonatomic, assign) BOOL isFullscreenMode;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation XYPlayerController

-(void)settingTVId:(NSString *)tvid Title:(NSString *)title Detail:(NSString *)detail isLike:(BOOL)islike access_token:(NSString *)access_token sharelink:(NSString *)sharelink coverImage:(UIImage *)cover_image {
    self.TVId = tvid? tvid : @"";
    self.Title = title? title : @"";
    self.Detail = detail? detail : @"";
    self.islike = islike? islike : NO;
    self.Access_Token = access_token? access_token : @"";
    self.ShareLink = sharelink? sharelink : @"";
    self.Cover_Image = cover_image? cover_image : [UIImage imageNamed:@"placeholder"];
    
    self.videoControl.titleLabel.text = self.Title;
    self.videoControl.detailLabel.text = self.Detail;
}

- (void)dealloc
{
    [self cancelObserver];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.videoControl.isFullScreen = NO;
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor blackColor];
        self.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview:self.videoControl];
        self.videoControl.frame = self.view.bounds;
        self.videoControl.playImageView.hidden = YES;
        self.videoControl.PauseImageView.hidden = YES;
        self.videoControl.gobackView.hidden = YES;
        self.videoControl.gobackORgoforwardLabel.hidden = YES;
        self.videoControl.goforwardView.hidden = YES;
        [self configObserver];
        [self configControlAction];
        
    }
    return self;
}

#pragma mark - Override Method

- (void)setContentURL:(NSURL *)contentURL
{
    [self stop];
    [super setContentURL:contentURL];
    [self play];
    self.isPlaying = YES;
}

#pragma mark - Publick Method

- (void)showInWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [keyWindow addSubview:self.view];
    self.view.alpha = 0.0;
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)dismiss
{
    [self stopDurationTimer];
    [self stop];
    self.isPlaying = NO;
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (self.dimissCompleteBlock) {
            self.dimissCompleteBlock();
        }
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Private Method

- (void)configObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
}

- (void)cancelObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configControlAction
{
    
    [self.videoControl.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [self setProgressSliderMaxMinValues];
    [self monitorVideoPlayback];
}

- (void)onMPMoviePlayerPlaybackStateDidChangeNotification
{
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        self.videoControl.pauseButton.hidden = NO;
        self.videoControl.playButton.hidden = YES;
        self.videoControl.playImageView.hidden = YES;
        self.videoControl.PauseImageView.hidden = YES;
        self.videoControl.gobackView.hidden = YES;
        self.videoControl.goforwardView.hidden = YES;
        self.videoControl.gobackORgoforwardLabel.hidden = YES;
        [self startDurationTimer];
        [self.videoControl.indicatorView stopAnimating];
        [self.videoControl autoFadeOutControlBar];
    } else {
        self.videoControl.pauseButton.hidden = YES;
        self.videoControl.playButton.hidden = NO;
        self.videoControl.playImageView.hidden = YES;
        self.videoControl.PauseImageView.hidden = YES;
        self.videoControl.gobackView.hidden = YES;
        self.videoControl.goforwardView.hidden = YES;
        self.videoControl.gobackORgoforwardLabel.hidden = YES;
        [self stopDurationTimer];
        if (self.playbackState == MPMoviePlaybackStateStopped) {
            [self.videoControl animateShow];
        }
    }
}

- (void)onMPMoviePlayerLoadStateDidChangeNotification
{
    if (self.loadState & MPMovieLoadStateStalled) {
        [self.videoControl.indicatorView startAnimating];
    }
}

- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification
{
    
}

- (void)onMPMovieDurationAvailableNotification
{
    [self setProgressSliderMaxMinValues];
}

- (void)playButtonClick
{
    [self play];
    self.isPlaying = YES;
    self.videoControl.playButton.hidden = YES;
    self.videoControl.pauseButton.hidden = NO;
    self.videoControl.playImageView.hidden = FALSE;
    
    self.videoControl.playImageView.alpha = 0.1;
    
    CGAffineTransform transformScale = CGAffineTransformMakeScale(0, 0);
    CGAffineTransform transformTranslate = CGAffineTransformMakeTranslation(5, 5);
    
    self.videoControl.playImageView.transform = CGAffineTransformConcat(transformScale, transformTranslate);
    [UIView animateWithDuration:0.65
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.videoControl.playImageView.alpha = 1;
                         self.videoControl.playImageView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         self.videoControl.playImageView.hidden = TRUE;
                     }];
}

- (void)pauseButtonClick
{
    [self pause];
    self.isPlaying = NO;
    self.videoControl.playButton.hidden = NO;
    self.videoControl.pauseButton.hidden = YES;
    self.videoControl.PauseImageView.hidden = FALSE;
    self.videoControl.gobackView.hidden = YES;
    self.videoControl.goforwardView.hidden = YES;
    self.videoControl.gobackORgoforwardLabel.hidden = YES;
    self.videoControl.PauseImageView.alpha = 0.1;
    
    CGAffineTransform transformScale = CGAffineTransformMakeScale(0, 0);
    CGAffineTransform transformTranslate = CGAffineTransformMakeTranslation(5, 5);
    
    self.videoControl.PauseImageView.transform = CGAffineTransformConcat(transformScale, transformTranslate);
    [UIView animateWithDuration:0.65
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.videoControl.PauseImageView.alpha = 1;
                         self.videoControl.PauseImageView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         self.videoControl.PauseImageView.hidden = TRUE;
                     }];
}

- (void)closeButtonClick
{
    [self shrinkScreenButtonClick];
}

- (void)fullScreenButtonClick
{
    if (self.isFullscreenMode) {
        return;
    }
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    [UIView animateWithDuration:0.3f animations:^{
        self.videoControl.isFullScreen = YES;
        self.frame = frame;
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.videoControl.fullScreenButton.hidden = YES;
        self.videoControl.shrinkScreenButton.hidden = NO;
    }];
}

- (void)shrinkScreenButtonClick
{
    if (!self.isFullscreenMode) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.videoControl.isFullScreen = NO;
        [self.view setTransform:CGAffineTransformIdentity];
        self.frame = self.originFrame;
    } completion:^(BOOL finished) {
        self.isFullscreenMode = NO;
        self.videoControl.fullScreenButton.hidden = NO;
        self.videoControl.shrinkScreenButton.hidden = YES;
    }];
}

- (void)setProgressSliderMaxMinValues {
    CGFloat duration = self.duration;
    self.videoControl.progressSlider.minimumValue = 0.0f;
    self.videoControl.progressSlider.maximumValue = duration;
}

- (void)progressSliderTouchBegan:(UISlider *)slider {
    [self pause];
    self.isPlaying = NO;
    [self.videoControl cancelAutoFadeOutControlBar];
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
    [self setCurrentPlaybackTime:floor(slider.value)];
    [self play];
    self.isPlaying = YES;
    [self.videoControl autoFadeOutControlBar];
}

- (void)progressSliderValueChanged:(UISlider *)slider {
    double currentTime = ceil(slider.value);
    double totalTime = ceil(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

- (void)monitorVideoPlayback
{
    double currentTime = ceil(self.currentPlaybackTime);
    double totalTime = ceil(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    self.videoControl.progressSlider.value = ceil(currentTime);
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = ceil(fmod(currentTime, 60.0));
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);
    double secondsRemaining = ceil(fmod(totalTime, 60.0));
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    
    self.videoControl.timeLabel.text = timeElapsedString;
    self.videoControl.fullTimeLabel.text = timeRmainingString;
    self.videoControl.gobackORgoforwardLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
}

- (void)startDurationTimer
{
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopDurationTimer
{
    [self.durationTimer invalidate];
}

- (void)fadeDismissControl
{
    [self.videoControl animateHide];
}

#pragma mark - Property

- (XYVideoViewControlView *)videoControl
{
    if (!_videoControl) {
        _videoControl = [[XYVideoViewControlView alloc] init];
        _videoControl.delegate = self;
    }
    return _videoControl;
}

- (UIView *)movieBackgroundView
{
    if (!_movieBackgroundView) {
        _movieBackgroundView = [UIView new];
        _movieBackgroundView.alpha = 0.0;
        _movieBackgroundView.backgroundColor = [UIColor blackColor];
    }
    return _movieBackgroundView;
}

- (void)setFrame:(CGRect)frame
{
    [self.view setFrame:frame];
    [self.videoControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.videoControl setNeedsLayout];
    [self.videoControl layoutIfNeeded];
}

-(void)PalyOrPause {
    if (self.isPlaying == YES) {
        [self pauseButtonClick];
    }
    else {
        [self playButtonClick];
    }
}

-(void)GoChangeTimeBegin {
    [self progressSliderTouchBegan:self.videoControl.progressSlider];
}

-(void)GoBackUp:(CGFloat)second {
    if (self.isPlaying == YES) {
        self.videoControl.gobackView.hidden = NO;
        self.videoControl.gobackORgoforwardLabel.hidden = NO;
        CGFloat s = ceil(self.videoControl.progressSlider.value+second);
        if (s > ceil(self.duration)) {
            s = ceil(self.duration);
        }
        else if (s <= 0) {
            s = 0;
        }
        double currentTime = s;
        double totalTime = ceil(self.duration);
        [self setTimeLabelValues:currentTime totalTime:totalTime];
    }
}

-(void)GoForward:(CGFloat)second {
    if (self.isPlaying == YES) {
        self.videoControl.goforwardView.hidden = NO;
        self.videoControl.gobackORgoforwardLabel.hidden = NO;
        CGFloat s = ceil(self.videoControl.progressSlider.value+second);
        if (s > ceil(self.duration)) {
            s = ceil(self.duration);
        }
        else if (s <= 0) {
            s = 0;
        }
        double currentTime = s;
        double totalTime = ceil(self.duration);
        [self setTimeLabelValues:currentTime totalTime:totalTime];
    }
}

-(void)GoChangeTimeEnd:(CGFloat)second {
    CGFloat s = ceil(self.videoControl.progressSlider.value+second);
    if (s > ceil(self.duration)) {
        s = ceil(self.duration);
    }
    else if (s <= 0) {
        s = 0;
    }
    [self setCurrentPlaybackTime:s];
    [self play];
    self.isPlaying = YES;
    [self.videoControl autoFadeOutControlBar];
}

@end

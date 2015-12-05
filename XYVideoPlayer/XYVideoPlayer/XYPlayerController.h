//
//  XYPlayerController.h
//  XYPlayer
//
//  Created by Echo on 15/11/23.
//  Copyright © 2015年 Liu Xuanyi. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;

@interface XYPlayerController : MPMoviePlayerController

@property (strong, nonatomic) NSString *TVId;
@property (strong, nonatomic) NSString *Access_Token;
@property (strong, nonatomic) NSString *ShareLink;
@property (strong, nonatomic) UIImage *Cover_Image;
@property (strong, nonatomic) NSString *Title;
@property (strong, nonatomic) NSString *Detail;
@property (assign, nonatomic) BOOL islike;

-(void)settingTVId:(NSString *)tvid Title:(NSString *)title Detail:(NSString *)detail isLike:(BOOL)islike access_token:(NSString *)access_token sharelink:(NSString *)sharelink coverImage:(UIImage *)cover_image;

@property (nonatomic, copy)void(^dimissCompleteBlock)(void);
@property (nonatomic, assign) CGRect frame;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)showInWindow;
- (void)dismiss;

@end

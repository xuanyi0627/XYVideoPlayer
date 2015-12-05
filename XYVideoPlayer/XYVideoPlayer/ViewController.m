//
//  ViewController.m
//  XYPlayer
//
//  Created by Echo on 15/11/23.
//  Copyright © 2015年 Liu Xuanyi. All rights reserved.
//

#import "ViewController.h"
#import "XYPlayerController.h"

@interface ViewController ()

@property (nonatomic, strong) XYPlayerController *videoController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playLocalVideo:(id)sender
{
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"150511_JiveBike" withExtension:@"mov"];
    [self playVideoWithURL:videoURL];
}

- (void)playVideoWithURL:(NSURL *)url
{
    if (!self.videoController) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        self.videoController = [[XYPlayerController alloc] initWithFrame:CGRectMake(0, 0, width, width*(9.0/16.0))];
        __weak typeof(self)weakSelf = self;
        [self.videoController settingTVId:@"1" Title:@"异能电台第二十一期#Motion Design 动态设计有机与无机#" Detail:@"白塘工作室" isLike:YES access_token:@"123" sharelink:@"XY.com" coverImage:[UIImage imageNamed:@"placeholder"]];
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
        }];
        [self.videoController showInWindow];
    }
    self.videoController.contentURL = url;
}

@end

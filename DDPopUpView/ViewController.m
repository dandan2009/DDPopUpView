//
//  ViewController.m
//  DDPopUpView
//
//  Created by shan on 2018/8/24.
//  Copyright © 2018年 shan. All rights reserved.
//

#import "ViewController.h"
#import "DDPopUpView.h"
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    //使用示例
    //1. 纯文本弹窗
    UIButton *textBtn = [[UIButton alloc] initWithFrame:CGRectMake(90, 90, 150,30)];
    textBtn.backgroundColor = [UIColor redColor];
    [textBtn setTitle:@"文本弹窗" forState:UIControlStateNormal];
    [textBtn addTarget:self action:@selector(textAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:textBtn];
    
    //2. 纯图片弹窗
    UIButton *imagetBtn = [[UIButton alloc] initWithFrame:CGRectMake(90, 190, 150,30)];
    imagetBtn.backgroundColor = [UIColor redColor];
    [imagetBtn setTitle:@"图片弹窗" forState:UIControlStateNormal];
    [imagetBtn addTarget:self action:@selector(imageAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imagetBtn];
    
    //3. 上文下图弹窗
    UIButton *textImagetBtn = [[UIButton alloc] initWithFrame:CGRectMake(90, 290, 150,30)];
    textImagetBtn.backgroundColor = [UIColor redColor];
    [textImagetBtn setTitle:@"图文弹窗" forState:UIControlStateNormal];
    [textImagetBtn addTarget:self action:@selector(textImageAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:textImagetBtn];
    
    
    //4. 自定义弹窗内容
    UIButton *customBtn = [[UIButton alloc] initWithFrame:CGRectMake(90, 390, 150,30)];
    customBtn.backgroundColor = [UIColor redColor];
    [customBtn setTitle:@"自定义视图弹窗" forState:UIControlStateNormal];
    [customBtn addTarget:self action:@selector(customAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:customBtn];
}

//1. 纯文本弹窗
- (void)textAction{
    DDPopUpView *alertView = [[DDPopUpView alloc] init];
    [alertView setmainBtnText:@"主按钮" mainBtnAction:^(DDPopUpView *alertView) {
        NSLog(@"点击了主按钮");
        [alertView close];
    } subBtnText:@"次按钮" subBtnAction:^(DDPopUpView *alertView) {
        NSLog(@"点击了次按钮");
        [alertView close];
    }];
    [alertView setText:@"感谢您的使用，使用期间如有什么问题，请联系我们！" textSize:20 textColor:[UIColor redColor] containerViewWidth:kScreenWidth - 50];
    [alertView show];
}

//2. 纯图片弹窗
- (void)imageAction{
    DDPopUpView *alertView = [[DDPopUpView alloc] init];
    [alertView setmainBtnText:@"主按钮" mainBtnAction:^(DDPopUpView *alertView) {
        NSLog(@"点击了主按钮");
        [alertView close];
    } subBtnText:@"次按钮" subBtnAction:^(DDPopUpView *alertView) {
        NSLog(@"点击了次按钮");
        [alertView close];
    }];
    [alertView setImage:[UIImage imageNamed:@"0.jpeg"] containerViewSize:CGSizeMake(kScreenWidth - 50, kScreenWidth)];
    [alertView show];
}


// 3. 上文下图弹窗
- (void)textImageAction{
    DDPopUpView *alertView = [[DDPopUpView alloc] init];
    [alertView setmainBtnText:@"主按钮" mainBtnAction:^(DDPopUpView *alertView) {
        NSLog(@"点击了主按钮");
        [alertView close];
    } subBtnText:@"次按钮" subBtnAction:^(DDPopUpView *alertView) {
        NSLog(@"点击了次按钮");
        [alertView close];
    }];
    [alertView setUpText:@"恭喜您成为QQ超级会员" downImage:[UIImage imageNamed:@"0.jpeg"] textSize:16 textColor:[UIColor blueColor] containerViewSize:CGSizeMake(kScreenWidth, kScreenWidth) textImageSpace:10];
    [alertView show];
}

// 4. 自定义弹窗内容
- (void)customAction{
    DDPopUpView *alertView = [[DDPopUpView alloc] init];
    [alertView setmainBtnText:@"主按钮" mainBtnAction:^(DDPopUpView *alertView) {
        NSLog(@"点击了主按钮");
        [alertView close];
    } subBtnText:@"次按钮" subBtnAction:^(DDPopUpView *alertView) {
        NSLog(@"点击了次按钮");
        [alertView close];
    }];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-60, kScreenWidth)];
    imageView.image = [UIImage imageNamed:@"0.jpeg"];
    
    UILabel *textLab = [[UILabel alloc] initWithFrame:CGRectMake(0, (imageView.frame.size.height - 40)/2, imageView.frame.size.width, 40)];
    textLab.textAlignment = NSTextAlignmentCenter;
    textLab.font = [UIFont boldSystemFontOfSize:25];
    textLab.text = @"恭喜您成为QQ会员";
    textLab.backgroundColor = [UIColor greenColor];
    textLab.textColor = [UIColor blueColor];
    
    [imageView addSubview:textLab];
    [alertView setContainerView:imageView];
    [alertView show];
}


@end

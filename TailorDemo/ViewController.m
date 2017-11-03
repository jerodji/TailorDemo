//
//  ViewController.m
//  TailorDemo
//
//  Created by JerodJi on 2017/9/10.
//  Copyright © 2017年 Jerod. All rights reserved.
//

#import "ViewController.h"
#import "JJTailorImgVC.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;
@property (nonatomic, strong) UIButton *button3;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    _button1.frame = CGRectMake(20, 20, 200, 200);
    _button1.backgroundColor = [UIColor lightGrayColor];
    [_button1 addTarget:self action:@selector(btnAction1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button1];
    
    _button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    _button2.frame = CGRectMake(20, 20+200+10, 200, 156);
    _button2.backgroundColor = [UIColor lightGrayColor];
    [_button2 addTarget:self action:@selector(btnAction2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button2];
    
    _button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    _button3.frame = CGRectMake(20, 20+200+10+156+10, 100, 100);
    _button3.layer.cornerRadius = 50;
    _button3.backgroundColor = [UIColor lightGrayColor];
    [_button3 addTarget:self action:@selector(btnAction3:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button3];
}

- (void)btnAction1:(UIButton*)button
{
//    方形裁剪
    JJTailorImgVC * tailorVC = [[JJTailorImgVC alloc] init];
    [tailorVC tailorImage:[UIImage imageNamed:@"ss.png"] form:Square finishCB:^(UIImage *finishImage) {
        [_button1 setImage:finishImage forState:UIControlStateNormal];
    }];
    
    [self presentViewController:tailorVC animated:YES completion:nil];
}

- (void)btnAction2:(UIButton*)button
{
//    长方形裁剪
    JJTailorImgVC * tailorVC = [[JJTailorImgVC alloc] init];
    [tailorVC tailorImage:[UIImage imageNamed:@"ss.png"] form:Rectangle finishCB:^(UIImage *finishImage) {
        [_button2 setImage:finishImage forState:UIControlStateNormal];
    }];
    
    [self presentViewController:tailorVC animated:YES completion:nil];
}

- (void)btnAction3:(UIButton*)button
{
//    圆形裁剪
    JJTailorImgVC * tailorVC = [[JJTailorImgVC alloc] init];
    [tailorVC tailorImage:[UIImage imageNamed:@"ss.png"] form:Coterie finishCB:^(UIImage *finishImage) {
        [_button3 setImage:finishImage forState:UIControlStateNormal];
    }];
    
    [self presentViewController:tailorVC animated:YES completion:nil];
}


- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

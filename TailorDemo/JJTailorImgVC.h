//
//  JJTailorImgVC.h
//  TailorDemo
//
//  Created by JerodJi on 2017/9/10.
//  Copyright © 2017年 Jerod. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorRGB(r,g,b)    [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define UIColorRGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define max_multiple  2  //裁剪图片的放大倍数
//#define one_multiple  1  //1倍大小
//#define min_multiple  0.6  //裁剪图片的缩小倍数

typedef NS_ENUM(NSInteger, TAILOR_FORM)
{
    Coterie = 0,
    Square  ,
    Rectangle
};

typedef void (^FINISH_BLK)(UIImage *finishImage);

@interface JJTailorImgVC : UIViewController

@property (nonatomic,assign) NSInteger liveStyle;

/**
 裁剪图片
 @param image 要裁剪的图片
 @param form  裁剪形式
 @param finishBlk 裁剪完成后的回调->裁剪完成后的图片
 */
- (void)tailorImage:(UIImage*)image form:(TAILOR_FORM)form finishCB:(FINISH_BLK)finishBlk;

@end

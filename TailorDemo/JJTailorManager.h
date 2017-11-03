//
//  JJTailorManager.h
//  UnicornTV
//
//  Created by JerodJi on 2017/7/4.
//  Copyright © 2017年 Droi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JJTailorManager : NSObject

+ (JJTailorManager*)manager;

//全屏截图
- (UIImage*)captureFullScreenshots;
//objective c 截屏代码
- (UIImage*)captureView:(UIView*)view;


/**
 返回原图大小,裁剪区域外清空
 */
//获得屏幕图像
- (UIImage*)clipScreenshot:(UIView *)theView;
//获得某个范围内的屏幕图像
- (UIImage*)clipScreenshot:(UIView *)theView rect:(CGRect)rect;
//裁剪图片成圆形 inse边距
- (UIImage*)clipCircleImage:(UIImage*) image;
//返回裁剪区域图片,返回还是原图大小,除图片以外区域清空
- (UIImage*)clipWithImageRect:(CGRect)imageRect clipRect:(CGRect)clipRect clipImage:(UIImage *)clipImage;


/**
 返回裁剪区域大小的图片
 */
//裁剪矩形
- (UIImage*)tailorImage:(UIImage*)origImg rect:(CGRect)rect;
//
//裁剪圆形
- (UIImage*)tailorImage:(UIImage*)orimg circleRect:(CGRect)rect;

@end

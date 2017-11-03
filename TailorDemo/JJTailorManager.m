//
//  JJTailorManager.m
//  UnicornTV
//
//  Created by JerodJi on 2017/7/4.
//  Copyright © 2017年 Droi. All rights reserved.
//

#import "JJTailorManager.h"



@interface JJTailorManager ()

@end

@implementation JJTailorManager

static JJTailorManager* _tailorMgr = nil;
+ (JJTailorManager*)manager
{
    if (nil == _tailorMgr) {
        _tailorMgr = [[JJTailorManager alloc] init];
    }
    return _tailorMgr;
}

-(UIImage*)captureFullScreenshots
{
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIGraphicsBeginImageContext(screenWindow.frame.size);//全屏截图，包括window
    
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
//    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil); //保存到相册中
    
    return viewImage;
}

//objective c 截屏代码
-(UIImage*)captureView:(UIView*)view
{
    UIGraphicsBeginImageContext(view.bounds.size); //currentView 当前的view
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
//    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);  //保存到相册中
    
    return viewImage;
}


//======================================
#pragma mark-
//来实现抓图程序
//获得屏幕图像
- (UIImage *)clipScreenshot:(UIView *)theView
{
    UIGraphicsBeginImageContext(theView.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [theView.layer renderInContext:context];
    
    UIImage *theImage    = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;
}

//获得某个范围内的屏幕图像
- (UIImage *)clipScreenshot:(UIView *)theView rect:(CGRect)rect
{
    UIGraphicsBeginImageContext(theView.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIRectClip(rect);
    
    [theView.layer renderInContext:context];
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
//    UIImageWriteToSavedPhotosAlbum(theImage, nil, nil, nil);  //保存到相册中
    
    return  theImage;//[self getImageAreaFromImage:theImage atFrame:rect];
}

-(UIImage*)clipCircleImage:(UIImage*) image
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGRect rect = CGRectMake(0, 0, image.size.width , image.size.height );
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

//返回裁剪区域图片,返回还是原图大小,除图片以外区域清空
- (UIImage *)clipWithImageRect:(CGRect)imageRect clipRect:(CGRect)clipRect clipImage:(UIImage *)clipImage
{
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0);// 开启位图上下文
    
    // 设置裁剪区域
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:clipRect];
    [path addClip];
    
    [clipImage drawInRect:clipRect];// 绘制图片
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();// 获取当前图片
    
    UIGraphicsEndImageContext(); // 关闭上下文
    
    return image;
}


//======================================
#pragma mark-

- (UIImage*)tailorImage:(UIImage*)origImg rect:(CGRect)rect
{
    CGRect drawRect = CGRectMake(-rect.origin.x ,
                                 -rect.origin.y,
                                 origImg.size.width * origImg.scale,
                                 origImg.size.height * origImg.scale);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    [origImg drawInRect:drawRect];
        
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)tailorImage:(UIImage*)orimg circleRect:(CGRect)rect
{
    UIImage * retImage = [self tailorImage:orimg rect:rect];
    
    //获取裁剪图片范围的尺寸
    CGSize size = retImage.size;
    
    //开启位图上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
//    UIGraphicsBeginImageContext(size);
    
    //创建圆形路径 //设置为裁剪区域
    UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [path addClip];
    
    //绘制图片
    [retImage drawAtPoint:CGPointZero];
//    [_image drawInRect:CGRectMake(_rect.origin.x, _rect.origin.y, _rect.size.width, _rect.size.height)];
    
    //获取裁剪后的图片
    UIImage* finishImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭上下文
    UIGraphicsEndImageContext();
    
    return finishImage;
}

@end

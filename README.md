# TailorDemo
裁剪图片 
裁剪成 正方形，长方形，圆形 的 demo

JJTailorImgVC - 绘制裁剪UI

    //方形裁剪
    JJTailorImgVC * tailorVC = [[JJTailorImgVC alloc] init];
    
    [tailorVC tailorImage:[UIImage imageNamed:@"ss"] form:Square finishCB:^(UIImage *finishImage) {
        [_button1 setImage:finishImage forState:UIControlStateNormal];
    }];
    
    [self presentViewController:tailorVC animated:YES completion:nil];
    
    
JJTailorManager - 裁剪图片

    UIImage* outImg = [[JJTailorManager manager] tailorImage:image circleRect:rect]; 

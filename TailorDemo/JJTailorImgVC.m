//
//  JJTailorImgVC.m
//  TailorDemo
//
//  Created by JerodJi on 2017/9/10.
//  Copyright © 2017年 Jerod. All rights reserved.
//

#import "JJTailorImgVC.h"
#import "JJTailorManager.h"

#define MSW  [UIScreen mainScreen].bounds.size.width
#define MSH  [UIScreen mainScreen].bounds.size.height

@interface JJTailorImgVC ()<UINavigationControllerDelegate>
@property (nonatomic, assign) TAILOR_FORM  tailorForm;
@property (nonatomic, copy)   FINISH_BLK   finishBlk;
@property (nonatomic, strong) UIImage      * tailorImage;

@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, assign) BOOL isWidthBig; // 宽>高

@property (nonatomic, assign) CGFloat imgScale;

//imgView
@property (nonatomic, strong) UIImageView * imgView;
//裁剪位置的遮罩 view
@property (nonatomic, strong) UIView    * slView;
@property (nonatomic, assign) CGFloat   slX;
@property (nonatomic, assign) CGFloat   slY;
@property (nonatomic, assign) CGFloat   slW;
@property (nonatomic, assign) CGFloat   slH;
//裁剪位置
@property (nonatomic, assign) CGFloat   rectX;
@property (nonatomic, assign) CGFloat   rectY;
@property (nonatomic, assign) CGFloat   rectW;
@property (nonatomic, assign) CGFloat   rectH;
@end

@implementation JJTailorImgVC

- (void)tailorImage:(UIImage*)image form:(TAILOR_FORM)form finishCB:(FINISH_BLK)finishBlk
{
    _tailorImage = image;
    _tailorForm  = form;
    _finishBlk   = finishBlk;
    
    if (_imgView) {
        _imgView.image = _tailorImage; //viewDidLoad 在释放前不会再执行configImageView, 直接在次设置_imgView.image,避免一直显示第一张图片
    }
    
    if (form == Square)
    {
        _slX = 0;
        _slY = MSH/2 - MSW/2;
        _slW = MSW;
        _slH = MSW;
    }
    if (form == Rectangle)
    {
        CGFloat ra = 292.5f/375.0f; //高/宽比例
        _slW = MSW;
        _slH = _slW * ra;
        _slX = 0;
        _slY = MSH/2 - _slH/2;
    }
    if (form == Coterie)
    {
        _slX = 0;
        _slY = MSH/2 - MSW/2;
        _slW = MSW;
        _slH = MSW;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.delegate = self;
    
    [self configImageView]; //要裁剪的图片
    
    if (_tailorForm == Coterie) {
        [self configSolidCircle];
        [self configCircleAround:CGRectMake(_slX, _slY, _slW, _slH)];
    } else {
        [self configShadeView]; //上下的遮罩 view
        [self configSlecView];  //裁剪范围的遮罩 view
    }
    
    [self configBackButton];//返回按钮
    [self configButton];    //取消,确定按钮
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)configImageView
{
    CGFloat ww;
    CGFloat hh;
    
    if (_tailorImage.size.width <= _tailorImage.size.height)
    {
        _rate = _tailorImage.size.width / _slW;
        ww    = _tailorImage.size.width / _rate;
        hh    = _tailorImage.size.height / _rate;
        _isWidthBig = NO;
    }
    else
    {
        _rate = _tailorImage.size.height / _slH;
        hh    = _tailorImage.size.height / _rate;
        ww    = _tailorImage.size.width / _rate;
        _isWidthBig = YES;
    }
    
    
    _imgView = [[UIImageView alloc] initWithImage:_tailorImage];
    _imgView.userInteractionEnabled = YES;//一定要设置,否则手势无效
    _imgView.frame = CGRectMake(_slX, _slY, ww, hh);
    _imgView.layer.anchorPoint = CGPointMake(0.5, 0.5);//设置锚点
    ////_imgView.layer.position = CGPointMake(0, MSH/2 - MSW/2); //设置位置
    [self.view addSubview:_imgView];
    
    //创建平移手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [_imgView addGestureRecognizer:pan];
    //捏合手势
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchAction:)];
    [_imgView addGestureRecognizer:pinch];
}
//平移
- (void)panAction:(UIPanGestureRecognizer *)pan
{
    //selecView位置, 常量
    CGFloat sX = _slX; // 0;
    CGFloat sY = _slY; // MSH/2 - MSW/2;
    CGFloat sW = _slW; // MSW;
    CGFloat sH = _slH; // MSW;
    
    //获取手势的位置
    CGPoint pan_position = [pan translationInView:_imgView];
    
    //通过stransform 进行平移交换, transform变换不会改变 position.
    _imgView.transform = CGAffineTransformTranslate(_imgView.transform, pan_position.x, pan_position.y);
    
    CGFloat endX = _imgView.frame.origin.x;
    CGFloat endY = _imgView.frame.origin.y;
    CGFloat endW = _imgView.frame.size.width;
    CGFloat endH = _imgView.frame.size.height;
    NSLog(@"pan_X:%f  pan_Y:%f  pan_W:%f  pan_H:%f",endX,endY,endW,endH);
    
    //上边距限制
    if (endY > sY) {
        _imgView.frame = CGRectMake(endX, sY, endW, endH);
    }
    //左
    if (endX > 0)  {
        _imgView.frame = CGRectMake(0, endY, endW, endH);
    }
    //下
    if ((endY + endH) < (sY + sH)) {
        _imgView.frame = CGRectMake(endX, sY+sH-endH, endW, endH);
    }
    //右
    if ( (endX+endW) < (sX+sW) )  {
        _imgView.frame = CGRectMake(sX+sW-endW, endY, endW, endH);
    }
    
    //将增量置为零
    [pan setTranslation:CGPointZero inView:_imgView];
}

//缩放  /* pinch.scale > 1 放大 , pinch.scale < 1 缩小 */
-(void)pinchAction:(UIPinchGestureRecognizer *)pinch
{
    //selecView位置, 常量
    CGFloat sX = _slX; // 0;
    CGFloat sY = _slY; // MSH/2 - MSW/2;
    CGFloat sW = _slW; // MSW;
    CGFloat sH = _slH; // MSW;
    
    CGFloat endX = _imgView.frame.origin.x;
    CGFloat endY = _imgView.frame.origin.y;
    CGFloat endW = _imgView.frame.size.width;
    CGFloat endH = _imgView.frame.size.height;
    
    CGFloat ra = endH / endW;
    
    ///---------- 缩小限制 ----------
    if (_isWidthBig)
    {
        if ( (_imgView.frame.size.height <= _slH) && (pinch.scale < 1)) {
             pinch.scale = 1;
            [UIView animateWithDuration:0.3 animations:^{
               _imgView.frame = CGRectMake(endX, endY, sH / ra, sH); //缩得过小抖动的 bug
            }];
            return;
        }
    }
    else
    {
        if ((_imgView.frame.size.width <= _slW) && (pinch.scale < 1)) {
             pinch.scale = 1;
            [UIView animateWithDuration:0.3 animations:^{
                _imgView.frame = CGRectMake(endX, endY, sW, sW * ra);//缩得过小抖动的 bug
            }];
            return;
        }
    }
    
    //缩小
    if (pinch.scale < 1)
    {
        //缩小过程中边距的限制
        if (endY > sY) { //上边距限制
            _imgView.frame = CGRectMake(endX, sY, endW, endH);
            pinch.scale = 1;
            return;
        }
        if (endX > 0)  { //左
            _imgView.frame = CGRectMake(0, endY, endW, endH);
            pinch.scale = 1;
            return;
        }
        if ((endY + endH) < (sY + sH)) { //下
            _imgView.frame = CGRectMake(endX, sY+sH-endH, endW, endH);
            pinch.scale = 1;
            return;
        }
        if ((endX+endW) < (sX+sW)) { //右
            _imgView.frame = CGRectMake(sX+sW-endW, endY, endW, endH);
            pinch.scale = 1;
            return;
        }
        
        _imgScale = pinch.scale;
        _imgView.transform = CGAffineTransformScale(_imgView.transform, pinch.scale, pinch.scale);
        pinch.scale = 1;

    }
    
    
    ///---------- 放大限制  max_multiple 最大2倍 ----------
    if (_imgView.transform.a >= max_multiple || _imgView.transform.b >= max_multiple)
    {
        pinch.scale = 1;
        return;
    }
    
    //放大
    //通过 transform(改变) 进行视图的视图的捏合 , 缩放倍数
    _imgScale = pinch.scale;
    _imgView.transform = CGAffineTransformScale(_imgView.transform, pinch.scale, pinch.scale);
    pinch.scale = 1; //放大后 设置回初始值,即不放大状态的 scale

}

- (void)configShadeView
{
    UIView * upView = [[UIView alloc] init];
    upView.frame = CGRectMake(0, 0, _slW, _slY);
    upView.backgroundColor = UIColorRGBA(0, 0, 0, 0.8);
    upView.userInteractionEnabled = NO;
    [self.view addSubview:upView];
    
    UIView * downView = [[UIView alloc] init];
    downView.frame = CGRectMake(0, _slY + _slH, _slW, MSH - _slY - _slY);
    downView.backgroundColor = UIColorRGBA(0, 0, 0, 0.8);
    downView.userInteractionEnabled = NO;
    [self.view addSubview:downView];
}

// 画实线圆
- (void)configSolidCircle
{
    CAShapeLayer *   lineLayer =  [CAShapeLayer layer];
    CGMutablePathRef mutablePath =  CGPathCreateMutable();
    
    CGFloat w = 0.0;
    lineLayer.lineWidth = w ;
    
    lineLayer.strokeColor = [UIColor whiteColor].CGColor;
    lineLayer.fillColor   = [UIColor clearColor].CGColor;
    
    CGPathAddEllipseInRect(mutablePath, nil, CGRectMake(_slX, _slY, _slW, _slH));
    
    lineLayer.path = mutablePath;
    
    lineLayer.lineDashPhase = 1.0;
    
    CGPathRelease(mutablePath);
    
    [self.view.layer addSublayer:lineLayer];
}

// 填充圆周围
- (void)configCircleAround:(CGRect)rect
{
    CAShapeLayer *   lineLayer =  [CAShapeLayer layer];
    CGMutablePathRef mutablePath =  CGPathCreateMutable();
    
    CGFloat r = 1000.0;
    lineLayer.lineWidth = r ;
    
    lineLayer.strokeColor = UIColorRGBA(0, 0, 0, 0.8).CGColor;//[UIColor purpleColor].CGColor;
    lineLayer.fillColor   = [UIColor clearColor].CGColor;
    
    CGPathAddEllipseInRect(mutablePath, nil, CGRectMake(self.view.center.x-(_slW/2+r/2), self.view.center.y-(_slW/2+r/2), _slW+r, _slW+r));
    
    lineLayer.path = mutablePath;
    
    lineLayer.lineDashPhase = 1.0;
    
    CGPathRelease(mutablePath);
    
    [self.view.layer addSublayer:lineLayer];
    
}

- (void)configSlecView
{
    _slView = [[UIView alloc] init];
    _slView.backgroundColor = [UIColor clearColor];
    _slView.frame = CGRectMake(_slX, _slY, _slW, _slH);
    _slView.userInteractionEnabled = NO; //关闭这层的交互
    [self.view addSubview:_slView];
    
    //四周的白色边框 宽度2
    CGFloat bw = 2;
    UIView * upV    = [[UIView alloc] init];
    UIView * leftV  = [[UIView alloc] init];
    UIView * downV  = [[UIView alloc] init];
    UIView * rightV = [[UIView alloc] init];
    upV.userInteractionEnabled    = NO;
    leftV.userInteractionEnabled  = NO;
    downV.userInteractionEnabled  = NO;
    rightV.userInteractionEnabled = NO;
    upV.backgroundColor    = [UIColor whiteColor];
    leftV.backgroundColor  = [UIColor whiteColor];
    downV.backgroundColor  = [UIColor whiteColor];
    rightV.backgroundColor = [UIColor whiteColor];
    upV.frame    = CGRectMake(0, 0, _slView.bounds.size.width, bw);
    leftV.frame  = CGRectMake(0, 0, bw, _slView.bounds.size.height);
    downV.frame  = CGRectMake(0, _slView.bounds.size.height-bw, _slView.bounds.size.width, bw);
    rightV.frame = CGRectMake(_slView.bounds.size.width-2, 0, bw, _slView.bounds.size.height);
    [_slView addSubview:upV];
    [_slView addSubview:leftV];
    [_slView addSubview:downV];
    [_slView addSubview:rightV];
    
    //边角
    UIView * leftUprV = [[UIView alloc] init];
    UIView * leftLowV = [[UIView alloc] init];
    UIView * righUprV = [[UIView alloc] init];
    UIView * righLowV = [[UIView alloc] init];
    leftUprV.userInteractionEnabled = NO;
    leftLowV.userInteractionEnabled = NO;
    righUprV.userInteractionEnabled = NO;
    righLowV.userInteractionEnabled = NO;
    leftUprV.backgroundColor = [UIColor whiteColor];
    leftLowV.backgroundColor = [UIColor whiteColor];
    righUprV.backgroundColor = [UIColor whiteColor];
    righLowV.backgroundColor = [UIColor whiteColor];
    leftUprV.frame = CGRectMake(0, -2, 28, 2);
    leftLowV.frame = CGRectMake(0, _slView.bounds.origin.y + _slView.bounds.size.height, 28, 2);
    righUprV.frame = CGRectMake(_slW-28, -2, 28, 2);
    righLowV.frame = CGRectMake(_slW-28, _slView.bounds.origin.y + _slView.bounds.size.height, 28, 2);
    [_slView addSubview:leftUprV];
    [_slView addSubview:leftLowV];
    [_slView addSubview:righUprV];
    [_slView addSubview:righLowV];
    
    //九宫格分割线
    if (_tailorForm == Square) {
        CGFloat distc = _slW/3;
        CGFloat lineW = 0.5;
        UIView * viewA = [[UIView alloc] init];
        UIView * viewB = [[UIView alloc] init];
        UIView * viewC = [[UIView alloc] init];
        UIView * viewD = [[UIView alloc] init];
        viewA.userInteractionEnabled = NO;
        viewB.userInteractionEnabled = NO;
        viewC.userInteractionEnabled = NO;
        viewD.userInteractionEnabled = NO;
        viewA.backgroundColor = UIColorRGB(143, 141, 141);
        viewB.backgroundColor = UIColorRGB(143, 141, 141);
        viewC.backgroundColor = UIColorRGB(143, 141, 141);
        viewD.backgroundColor = UIColorRGB(143, 141, 141);
        viewA.frame = CGRectMake(bw, distc,   _slView.bounds.size.width - bw*2, lineW);
        viewB.frame = CGRectMake(bw, distc*2, _slView.bounds.size.width - bw*2, lineW);
        viewC.frame = CGRectMake(distc,   bw, lineW, _slView.bounds.size.height - bw*2);
        viewD.frame = CGRectMake(distc*2, bw, lineW, _slView.bounds.size.height - bw*2);
        [_slView addSubview:viewA];
        [_slView addSubview:viewB];
        [_slView addSubview:viewC];
        [_slView addSubview:viewD];
    }
}

- (void)configBackButton
{
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 21.5, 50, 19.5);
    [backBtn setImage:[UIImage imageNamed:@"iconReturnBack"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(MSW/2-100/2, 24.5, 100, 14);
    label.backgroundColor = [UIColor clearColor];
    label.text = @"编辑裁剪";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}
- (void)backBtnAction
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)configButton
{
    UIButton  * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, MSH-48, MSW/2, 48);
    cancelBtn.backgroundColor = UIColorRGBA(254, 84, 17, 1);
    [cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.view addSubview:cancelBtn];
    
    UIButton  * sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = CGRectMake(MSW/2, MSH-48, MSW/2, 48);
    sureBtn.backgroundColor = [UIColor redColor];
    [sureBtn addTarget:self action:@selector(sureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.view addSubview:sureBtn];
}
- (void)cancelBtnAction:(UIButton*)button
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)sureBtnAction:(UIButton*)button
{
    CGFloat a = _imgView.transform.a;
    
    _rectX = (_slX - _imgView.frame.origin.x) * (max_multiple / a);
    _rectY = (_slY - _imgView.frame.origin.y) * (max_multiple / a);
    _rectW = _slW * _rate / a;
    _rectH = _slH * _rate / a;
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (_tailorForm == Coterie)
    {
        UIImage* ouImg = [[JJTailorManager manager] tailorImage:_imgView.image circleRect:CGRectMake(_rectX, _rectY, _rectW, _rectH)];
        
        _finishBlk(ouImg);
    }
    if(_tailorForm == Square)
    {
         UIImage* ouImg = [[JJTailorManager manager] tailorImage:_imgView.image rect:CGRectMake(_rectX, _rectY, _rectW, _rectH)];
        
        _finishBlk(ouImg);
    }
    if (_tailorForm == Rectangle)
    {
        UIImage* ouImg = [[JJTailorManager manager] tailorImage:_imgView.image rect:CGRectMake(_rectX, _rectY, _rectW, _rectH)];
        
        _finishBlk(ouImg);
    }
    
}

#pragma mark- UINavigationControllerDelegate
/* 控制自己的导航栏 显示 隐藏 */
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  DDPopUpView.m
//  DDPopUpView
//
//  Created by shan on 2018/8/24.
//  Copyright © 2018年 shan. All rights reserved.
//

#import "DDPopUpView.h"
#import <QuartzCore/QuartzCore.h>

const static CGFloat   kDefaultContainerViewButtonSpace = 24;
const static NSInteger KMainBtnTag                      = 1000;
const static NSInteger KSubBtnTag                       = 1001;

@interface DDPopUpView ()

@property (nonatomic, strong) UIView *parentView;///< 自定义弹窗父View，暂时不开放
@property (nonatomic, strong) UIView *dialogView;///< 弹窗视图
@property (nonatomic, strong) UIView *containerView;///< 弹窗内容视图
@property (nonatomic, assign) BOOL closeOnTouchUpOutside;///< 点击空白区域是否关闭弹窗  默认YES  属性暂不开放
@property (copy) void (^mainBtnAction)(DDPopUpView *alertView);///< 主按钮点击事件
@property (copy) void (^subBtnAction)(DDPopUpView *alertView);///< 次按钮点击事件
@property (nonatomic, copy) NSString * mainBtnText;///< 主按钮文案
@property (nonatomic, copy) NSString * subBtnText;///<  次按钮文案

@end

@implementation DDPopUpView

CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;
UIEdgeInsets contentInsets;

- (id)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        _closeOnTouchUpOutside = YES;
        contentInsets = UIEdgeInsetsMake(15, 15, 15, 15);
        _btnHeight = 36;
        _btnTextSize = 16;
        _subBtnTextColor = TCUIColorFromRGB(0x666666);
        _mainBtnTextColor = TCUIColorFromRGB(0xFFFFFF);
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

// 创建、展示对话框，所有属性设置好之后，调用此方法
- (void)show{
    _dialogView = [self createContainerView];
    
    _dialogView.layer.shouldRasterize = YES;
    _dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self addSubview:_dialogView];
    
    if (_parentView != NULL) {
        [_parentView addSubview:self];
    }
    else {
        CGSize screenSize = [self countScreenSize];
        CGSize dialogSize = [self countDialogSize];
        CGSize keyboardSize = CGSizeMake(0, 0);
        
        _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    }
    
    _dialogView.layer.opacity = 0.5f;
    _dialogView.layer.transform = CATransform3DMakeScale(0.3f, 0.3f, 1.0);
    
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
        self.dialogView.layer.opacity = 1.0f;
        self.dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
    } completion:^(BOOL finished) {
    }];
}

// 按钮点击事件
- (void)buttonTouchUpInside:(UIButton *)sender{
    if (sender.tag == KMainBtnTag) {
        if (_mainBtnAction) {
            _mainBtnAction(self);
        }
    }
    else if(sender.tag == KSubBtnTag){
        if (_subBtnAction) {
            _subBtnAction(self);
        }
    }
}


// 关闭对话框
- (void)close{
    CATransform3D currentTransform = _dialogView.layer.transform;
    _dialogView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.dialogView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }];
}

- (void)setContainerView: (UIView *)containerView{
    CGRect frame = containerView.frame;
    if (frame.size.width > [UIScreen mainScreen].bounds.size.width - 40) {//不能超出屏幕
        frame.size.width = [UIScreen mainScreen].bounds.size.width - 40;
    }
    if (frame.size.height > [UIScreen mainScreen].bounds.size.height - 60 - _btnHeight - kDefaultContainerViewButtonSpace) {
        frame.size.height = [UIScreen mainScreen].bounds.size.height - 60 - _btnHeight - kDefaultContainerViewButtonSpace;
    }
    _containerView = containerView;
    _containerView.frame = frame;
}

//创建对话框
- (UIView *)createContainerView{
    if (_containerView == NULL) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    }
    
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)];
    dialogContainer.backgroundColor = [UIColor whiteColor];
    
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(contentInsets.left, contentInsets.top, _containerView.frame.size.width, _containerView.frame.size.height)];
    //    contentView.backgroundColor = [UIColor greenColor];
    
    dialogContainer.layer.cornerRadius = 12;
    
    [contentView addSubview:_containerView];
    [dialogContainer addSubview:contentView];
    
    [self addButtonsToView:dialogContainer];
    return dialogContainer;
}

// 添加主次按钮
- (void)addButtonsToView: (UIView *)container{
    if ([self.mainBtnText length] == 0 ) {
        return;
    }
    if ([self.subBtnText length] > 0) {
        CGFloat buttonWidth = (_containerView.bounds.size.width - 4) / 2;
        
        //次按钮
        CGRect subBtnFrame =  CGRectMake( contentInsets.left, container.bounds.size.height - buttonHeight -contentInsets.bottom, buttonWidth, buttonHeight);
        UIButton *subButton = [self getBtnWithTag:KSubBtnTag withFrame:subBtnFrame];
        subButton.layer.cornerRadius = 2;
        subButton.layer.masksToBounds = YES;
        
        CAShapeLayer *shapeLayer0 = [CAShapeLayer layer];
        shapeLayer0.path = [UIBezierPath bezierPathWithRoundedRect:subButton.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(9, 9)].CGPath;
        subButton.layer.mask = shapeLayer0;
        [container addSubview:subButton];
        
        
        //主按钮
        CGRect mainBtnFrame =  CGRectMake( buttonWidth + 4 + contentInsets.left, container.bounds.size.height - buttonHeight - contentInsets.bottom, buttonWidth, buttonHeight);
        UIButton *mainButton = [self getBtnWithTag:KMainBtnTag withFrame:mainBtnFrame];
        mainButton.layer.cornerRadius = 2;
        mainButton.layer.masksToBounds = YES;
        
        CAShapeLayer *shapeLayer1 = [CAShapeLayer layer];
        shapeLayer1.path = [UIBezierPath bezierPathWithRoundedRect:mainButton.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(9, 9)].CGPath;
        mainButton.layer.mask = shapeLayer1;
        [container addSubview:mainButton];
    }
    else {
        CGFloat buttonWidth = _containerView.bounds.size.width;
        CGRect mainBtnFrame =  CGRectMake( contentInsets.left, container.bounds.size.height - buttonHeight -contentInsets.bottom , buttonWidth, buttonHeight);
        UIButton *mainButton = [self getBtnWithTag:KMainBtnTag withFrame:mainBtnFrame];
        
        CAShapeLayer *shapeLayer1 = [CAShapeLayer layer];
        shapeLayer1.path = [UIBezierPath bezierPathWithRoundedRect:mainButton.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(9, 9)].CGPath;
        mainButton.layer.mask = shapeLayer1;
        [container addSubview:mainButton];
        
    }
}


- (UIButton *)getBtnWithTag:(NSInteger)index  withFrame:(CGRect)frame{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button setTag:index];
    button.frame = frame;
    [button.titleLabel setFont:[UIFont systemFontOfSize:self.btnTextSize]];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    if (index == KMainBtnTag) {
        [button setBackgroundImage:[self getImageWithFrame:button.bounds frameColor:TCUIColorFromRGB(0xFF4F00) toColor:TCUIColorFromRGB(0xF2a500)] forState:UIControlStateNormal];
        [button setBackgroundImage:[self getImageWithFrame:button.bounds frameColor:TCUIColorFromRGB(0xFF8F00) toColor:TCUIColorFromRGB(0xFaa300)] forState:UIControlStateHighlighted];
        
        [button setTitleColor:self.mainBtnTextColor forState:UIControlStateNormal];
        [button setTitleColor:self.mainBtnTextColor forState:UIControlStateHighlighted];
        [button setTitle:self.mainBtnText forState:UIControlStateNormal];
    }
    else{
        [button setBackgroundImage:[self getImageWithFrame:button.bounds frameColor:TCUIColorFromRGB(0xF5F5F5) toColor:TCUIColorFromRGB(0x45F5F5)] forState:UIControlStateNormal];
        [button setBackgroundImage:[self getImageWithFrame:button.bounds frameColor:TCUIColorFromRGB(0xF4F4F4) toColor:TCUIColorFromRGB(0x84F4F4)] forState:UIControlStateHighlighted];
        
        [button setTitleColor:self.subBtnTextColor forState:UIControlStateNormal];
        [button setTitleColor:self.subBtnTextColor forState:UIControlStateHighlighted];
        [button setTitle:self.subBtnText forState:UIControlStateNormal];
    }
    return button;
}

- (void)setmainBtnText:(NSString *)mainBtnText mainBtnAction:(void (^)(DDPopUpView *alertView))mainButtonTouchUpInside{
    self.mainBtnText = mainBtnText;
    self.mainBtnAction = mainButtonTouchUpInside;
}

- (void)setmainBtnText:(NSString *)mainBtnText mainBtnAction:(void (^)(DDPopUpView *alertView))mainButtonTouchUpInside subBtnText:(NSString *)subBtnText subBtnAction:(void (^)(DDPopUpView *alertView))subButtonTouchUpInside{
    self.mainBtnText = mainBtnText;
    self.mainBtnAction = mainButtonTouchUpInside;
    self.subBtnText = subBtnText;
    self.subBtnAction = subButtonTouchUpInside;
}

// 获取对话框的大小
- (CGSize)countDialogSize{
    CGFloat dialogWidth = _containerView.frame.size.width + contentInsets.left + contentInsets.right;
    CGFloat dialogHeight = _containerView.frame.size.height + buttonHeight + buttonSpacerHeight + contentInsets.bottom + contentInsets.top;
    return CGSizeMake(dialogWidth, dialogHeight);
}

// 获取屏幕屏幕大小
- (CGSize)countScreenSize{
    if (self.mainBtnText.length > 0) {
        buttonHeight       = _btnHeight;
        buttonSpacerHeight = kDefaultContainerViewButtonSpace;
    } else {
        buttonHeight = 0;
        buttonSpacerHeight = 0;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    return CGSizeMake(screenWidth, screenHeight);
}
/**
 纯图片弹窗
 
 @param image 图片
 @param imageViewSize containerViewWidth的大小
 */
- (void)setImage:(UIImage *)image containerViewSize:(CGSize)imageViewSize{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageViewSize.width, imageViewSize.height)];
    imageView.image = image;
    [self setContainerView:imageView];
}


/**
 纯文本弹窗，会根据containerViewWidth自动计算containerView的高度
 
 @param text 弹窗内容
 @param textSize 弹窗文字的大小
 @param textColor 弹窗文字的颜色
 @param containerViewWidth 弹窗的宽度
 */
- (void)setText:(NSString *)text  textSize:(CGFloat)textSize  textColor:(UIColor *)textColor containerViewWidth:(CGFloat)containerViewWidth{
    CGRect frame = CGRectMake(0, 0, containerViewWidth, 0);
    UILabel *textLab = [[UILabel alloc] initWithFrame:frame];
    textLab.textAlignment = NSTextAlignmentCenter;
    textLab.font = [UIFont systemFontOfSize:textSize];
    textLab.text = text;
    textLab.numberOfLines = 0;
    textLab.textColor = textColor;
    [textLab sizeToFit];
    
    CGFloat labelHeight = [textLab sizeThatFits:CGSizeMake(textLab.frame.size.width, MAXFLOAT)].height;
    frame.size.height = labelHeight;
    textLab.frame = frame;
    NSInteger count = (labelHeight) / textLab.font.lineHeight;
    textLab.numberOfLines = count;
    [self setContainerView:textLab];
}

/**
 上文下图弹窗，文本的宽度等于图片的宽度，高度自动计算
 
 @param text 弹窗文字
 @param image 弹窗图片
 @param textSize 弹窗文字的大小
 @param textColor 弹窗文字的颜色
 @param imageViewSize  containerView的大小
 @param sapce 图文间距
 */
- (void)setUpText:(NSString *)text  downImage:(UIImage *)image textSize:(CGFloat)textSize  textColor:(UIColor *)textColor containerViewSize:(CGSize)imageViewSize textImageSpace:(CGFloat)sapce{
    
    CGRect frame = CGRectMake(0, 0, imageViewSize.width, 0);
    UILabel *textLab = [[UILabel alloc] initWithFrame:frame];
    textLab.textAlignment = NSTextAlignmentCenter;
    textLab.font = [UIFont systemFontOfSize:textSize];
    textLab.text = text;
    textLab.numberOfLines = 0;
    textLab.textColor = textColor;
    [textLab sizeToFit];
    
    CGFloat labelHeight = [textLab sizeThatFits:CGSizeMake(textLab.frame.size.width, MAXFLOAT)].height;
    frame.size.height = labelHeight;
    textLab.frame = frame;
    NSInteger count = (labelHeight) / textLab.font.lineHeight;
    textLab.numberOfLines = count;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, labelHeight + sapce, imageViewSize.width, imageViewSize.height)];
    imageView.image = image;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageViewSize.width, imageView.frame.origin.y + imageViewSize.height)];
    [contentView addSubview:textLab];
    [contentView addSubview:imageView];
    contentView.clipsToBounds = YES;
    [self setContainerView:contentView];
}


// 设备旋转之后调整视图
- (void)changeOrientation: (NSNotification *)notification {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGSize dialogSize = [self countDialogSize];
                         CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                         self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
                         self.dialogView.frame = CGRectMake((screenWidth - dialogSize.width) / 2, (screenHeight - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil];
}

//旋转设备的通知
- (void)deviceOrientationDidChange: (NSNotification *)notification{
    if (_parentView != NULL) {
        return;
    }
    
    [self changeOrientation:notification];
}

// 键盘隐藏/弹出的通知
- (void)keyboardWillShow: (NSNotification *)notification{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil];
}

- (void)keyboardWillHide: (NSNotification *)notification{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_closeOnTouchUpOutside) {
        return;
    }
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass:[DDPopUpView class]]) {
        [self close];
    }
}

-(UIImage *)getImageWithFrame:(CGRect)frame frameColor:(UIColor *)frameColor toColor:(UIColor *)toColor{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.locations = @[@0.0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1.0, 0);
    gradientLayer.frame = view.bounds;
    gradientLayer.colors = @[(__bridge id)frameColor.CGColor, (__bridge id)toColor.CGColor];
    [view.layer insertSublayer:gradientLayer atIndex:0];
    return [self convertViewToImage:view];
}

-(UIImage*)convertViewToImage:(UIView*)view{
    CGSize size = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end

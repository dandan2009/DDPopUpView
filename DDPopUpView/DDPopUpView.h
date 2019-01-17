//
//  DDPopUpView.h
//  DDPopUpView
//
//  Created by shan on 2018/8/24.
//  Copyright © 2018年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TCUIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((float)(((rgbValue) &0xFF00) >>8))/255.0 blue:((float)((rgbValue) &0xFF))/255.0 alpha:1.0]

@interface DDPopUpView : UIView

@property (nonatomic, assign) CGFloat btnHeight;///< 按钮的高度 默认值是36
@property (nonatomic, assign) CGFloat btnTextSize; ///< 按钮文字大小 默认值是16
@property (nonatomic, strong) UIColor *mainBtnTextColor; ///< 按钮文字颜色 默认值是0xFFFFFF对应的UIColor
@property (nonatomic, strong) UIColor *subBtnTextColor; ///< 按钮文字颜色  默认值是0x666666对应的UIColor

/**
 设置设置主按钮的文案和点击时间回调
 
 @param mainBtnText 主按钮文本
 @param mainButtonTouchUpInside 主按钮点击回调
 */
- (void)setmainBtnText:(NSString *)mainBtnText mainBtnAction:(void (^)(DDPopUpView *alertView))mainButtonTouchUpInside;

/**
 设置主、次按钮的文案和点击时间回调
 
 @param mainBtnText 主按钮文本
 @param mainButtonTouchUpInside 主按钮点击回调
 @param subBtnText 次按钮文本
 @param subButtonTouchUpInside 次按钮点击回调
 */
- (void)setmainBtnText:(NSString *)mainBtnText mainBtnAction:(void (^)(DDPopUpView *alertView))mainButtonTouchUpInside subBtnText:(NSString *)subBtnText subBtnAction:(void (^)(DDPopUpView *alertView))subButtonTouchUpInside;


/**
 弹窗
 */
- (void)show;

/**
 关闭弹窗
 */
- (void)close;

#pragma mark - 四种使用方法
/**
 自定义弹窗view，会根据view的大小自动调整外框的大小
 
 @param view 自定义的弹窗view
 */
- (void)setContainerView:(UIView *)view;

/**
 纯图片弹窗
 
 @param image 图片
 @param imageViewSize containerView的大小
 */
- (void)setImage:(UIImage *)image containerViewSize:(CGSize)imageViewSize;


/**
 纯文本弹窗，会根据containerViewWidth自动计算containerView的高度
 
 @param text 弹窗内容
 @param textSize 弹窗文字的大小
 @param textColor 弹窗文字的颜色
 @param containerViewWidth 弹窗的宽度
 */
- (void)setText:(NSString *)text  textSize:(CGFloat)textSize  textColor:(UIColor *)textColor containerViewWidth:(CGFloat)containerViewWidth;



/**
 上文下图弹窗，文本的宽度等于图片的宽度，高度自动计算
 
 @param text 弹窗文字
 @param image 弹窗图片
 @param textSize 弹窗文字的大小
 @param textColor 弹窗文字的颜色
 @param imageViewSize  containerView的大小
 @param sapce 图文间距
 */
- (void)setUpText:(NSString *)text  downImage:(UIImage *)image textSize:(CGFloat)textSize  textColor:(UIColor *)textColor containerViewSize:(CGSize)imageViewSize textImageSpace:(CGFloat)sapce;

@end


//
//  OPFloatWindow.h
//  OnePiece
//
//  Created by Duanww on 2018/8/9.
//  Copyright © 2018年 Duanww. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 浮动窗口视图，可滑改变动窗口位置
 */
@interface OPFloatWindow : UIWindow

/**
 根据内容视图创建浮动窗口
 
 @param frame 窗口区域
 @param contentView 内容视图
 @return 浮动窗口
 */
- (instancetype)initWithFrame:(CGRect)frame contentView:(UIView *)contentView;

/**
 窗口显示
 */
- (void)show;

/**
 窗口隐藏
 */
- (void)hide;

@end

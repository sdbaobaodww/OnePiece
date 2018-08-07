//
//  OPPlotViewBase.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/21.
//  Copyright © 2016年 DZH. All rights reserved.
//

/**
 * 定义了绘制视图和绘制视图模型基类，视图和视图模型为一一对应关系
 */

#import "OPPlotSpacesBase.h"

@class OPPlotViewBase;

typedef struct
{
    BOOL        fix;//是否是固定值，如果是YES固定值，则value表示真实的坐标数据；如果是NO非固定值，则value是一个[0~1]的值，表示值在父坐标体系中一个比例值，需要动态进行计算
    CGFloat     value;//固定值或者比例值，根据fix进行判断
}OPFrameValue;

static inline OPFrameValue OPFrameValueMake(BOOL fix, CGFloat value)
{
    OPFrameValue frame;
    frame.fix               = fix;
    frame.value             = value;
    return frame;
}

/**
 * frame模型，用于动态位置的时候进行计算
 */
@interface OPFrameModel : NSObject

@property (nonatomic) OPFrameValue x;
@property (nonatomic) OPFrameValue y;
@property (nonatomic) OPFrameValue width;
@property (nonatomic) OPFrameValue height;

/**
 * 初始化方法，根据x、y、width、height创建frame模型。
 */
- (instancetype)initWithX:(OPFrameValue)x y:(OPFrameValue)y width:(OPFrameValue)width height:(OPFrameValue)height;

/**
 * 便捷初始化方法，适应父视图大小
 */
+ (instancetype)full;

/**
 * 根据父视图大小计算最终的的frame
 */
- (CGRect)frameWithParentBounds:(CGRect)bounds;

@end

/**
 * 图表原型类增加自适应大小功能
 */
@interface OPPlotSpacesBase (Autoresize)

//frame模型
@property (nonatomic, strong) OPFrameModel *frameModel;

@end

/**
 * 绘制基类的视图模型类
 */
@interface OPPlotViewModelBase : NSObject

//绘制视图
@property (nonatomic, weak) OPPlotViewBase *view;

//绘制对象集合
@property (nonatomic, strong, readonly) NSArray *plotSpaceses;

/**
 * 进行图形绘制
 */
- (void)drawPlot;

/**
 * 增加绘制对象
 * @param plotSpaces 绘制对象集合
 */
- (void)addPlotSpacesArray:(NSArray *)plotSpaces;

/**
 * 增加绘制对象
 * @param plotSpaces 绘制对象
 */
- (void)addPlotSpaces:(OPPlotSpacesBase *)plotSpaces;

/**
 * 移除绘制对象
 * @param plotSpaces 绘制对象
 */
- (void)removePlotSpaces:(OPPlotSpacesBase *)plotSpaces;

/**
 * 替换绘制对象
 * @param plotSpaces 旧的绘制对象
 * @param otherPlotSpaces 新的绘制对象
 */
- (void)replacePlotSpaces:(OPPlotSpacesBase *)plotSpaces withPlotSpaces:(OPPlotSpacesBase *)otherPlotSpaces;

#pragma mark - 绘制视图相关的回调

/**
 * 绘制视图区域改变时的调用方法
 * @param bounds 绘制视图的bounds
 */
- (void)resizeViewBounds:(CGRect)bounds;

/**
 * 视图模型添加到绘制视图时调用的方法
 * @param view 绘制视图
 */
- (void)addToView:(UIView *)view;

/**
 * 视图模型从绘制视图移除时调用的方法
 * @param view 绘制视图
 */
- (void)removeFromView:(UIView *)view;

@end

/**
 * 继承UIView的绘制视图
 */
@interface OPPlotViewBase : UIView

@property (nonatomic, strong) OPPlotViewModelBase *viewModel;

- (instancetype)initWithFrame:(CGRect)frame plotViewModel:(OPPlotViewModelBase *)viewModel;

@end



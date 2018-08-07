//
//  OPPlotSpacesBase.h
//  OnePiece
//
//  图表绘制文件，一个图表通常由一个图表上下文、一个数据层、多个绘制层、多个绘制数据构成。
//  图表上下文管理着各绘制层绘制需要的一些基础环境，图表与图表上下文为多对一关系
//  数据层是业务数据的简单抽象；
//  绘制层是一个中间层，用于转化业务数据成绘制数据；
//  绘制数据是最终绘制所需要的数据
//
//  Created by Duanwwu on 2016/11/21.
//  Copyright © 2016年 DZH. All rights reserved.
//

//坐标轴绘制位置
typedef NS_ENUM(NSUInteger, OPAxisType)
{
    OPAxisTypeValue,//值坐标
    OPAxisTypePercentage,//百分比坐标
};

//X坐标轴绘制位置
typedef NS_ENUM(NSUInteger, OPPlotAxisXLocation)
{
    OPPlotAxisXTopOuter,//绘制在上侧外边
    OPPlotAxisXBottomOuter,//绘制在下侧外边
    OPPlotAxisXTopInner,//绘制在上侧内边
    OPPlotAxisXBottomInner,//绘制在下侧内边
};

//Y坐标轴绘制位置
typedef NS_ENUM(NSUInteger, OPPlotAxisYLocation)
{
    OPPlotAxisYLeftOuter,//绘制在左侧外边，文本靠右显示
    OPPlotAxisYRightOuter,//绘制在右侧外边，文本靠左显示
    OPPlotAxisYLeftInner,//绘制在左侧内边
    OPPlotAxisYRightInner,//绘制在右侧内边
    
    OPPlotAxisYRightOuterReverse,//绘制在右侧外边,文本靠右显示
};

/**
 * 图表上下文
 */
@interface OPPlotSpacesContext : NSObject

@property (nonatomic) CGFloat plotWidth;//绘制单元宽度
@property (nonatomic) CGFloat plotPadding;//绘制单元间距
@property (nonatomic, readonly) CGFloat plotArea;//绘制单元宽度 + 绘制单元间距

//开始索引、结束索引可以用作一个或多个图表共享属性，所以位于上下文而不是数据层中。
@property (nonatomic) NSUInteger fromIndex;//开始索引
@property (nonatomic) NSUInteger toIndex;//结束索引

@end

/**
 * 数据层
 */
@interface OPPlotDataLayer : NSObject

@property (nonatomic, strong) NSArray *datas;//原始数据
@property (nonatomic) long long max;//最大值
@property (nonatomic) long long min;//最小值

@end

/**
 * 绘制项基类
 */
@interface OPPlotBase : NSObject

@property (nonatomic) CGRect frame;//绘制区域

/**
 * 将业务数据进行转变，生成绘制数据，会在drawRect:方法内进行调用，此时的绘制区域为当前绘制最终区域
 * @returns 绘制数据
 */
- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context;

@end

#pragma mark -------坐标轴------------

//坐标轴绘制项
@interface OPPlotAxis : OPPlotBase

@property (nonatomic) OPAxisType axisType;//坐标类型
@property (nonatomic) int labelCount;//绘制的坐标值个数
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSArray *labels;//坐标文本对象[OPPlotLabel]

- (UIEdgeInsets)processAxisWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context plotSpacesFrame:(CGRect)frame;

@end

//X坐标轴绘制项
@interface OPPlotAxisX : OPPlotAxis

@property (nonatomic) CGFloat fixedHeight;//固定高度，如果不为0则使用固定高度，否则会根据坐标轴值动态计算
@property (nonatomic) OPPlotAxisXLocation axisLocation;//坐标绘制位置

@end

//Y坐标轴绘制项
@interface OPPlotAxisY : OPPlotAxis

@property (nonatomic) CGFloat fixedWidth;//固定宽度，如果不为0则使用固定宽度，否则会根据坐标轴值动态计算
@property (nonatomic) OPPlotAxisYLocation axisLocation;//坐标绘制位置

@end

//坐标轴线
@interface OPPlotAxisGrid : OPPlotBase

@property (nonatomic) UIEdgeInsets axisInsets;//坐标轴所占区域

@end

/**
 * 绘制层，在这一层业务数据转化为绘制数据
 */
@interface OPPlotLayer : OPPlotBase

/**
 * 计算最大值最小值
 */
- (void)processMaxMinValueWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context;

/**
 * 调整绘制区域时的处理，会在setFrame:前调用
 * @param frame 绘制区域
 * @param dataLayer 数据层
 * @param context 配置上下文
 */
- (void)layoutFrame:(CGRect)frame dataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context;

#pragma mark -------数据与坐标转换方法--------------

/**
 * 指定个数数据完全展示需要的宽度
 * @param count 数据个数
 * @param context 绘制相关的业务数据以及配置
 * @returns 需要的宽度
 */
- (CGFloat)widthForDataCount:(NSUInteger)count context:(OPPlotSpacesContext *)context;

/**
 * 计算指定数据索引对应的绘制项起始x坐标
 * @param index 数据索引
 * @param context 绘制相关的业务数据以及配置
 * @returns x坐标
 */
- (CGFloat)leftLocationForIndex:(NSUInteger)index context:(OPPlotSpacesContext *)context;

/**
 * 计算指定数据索引对应的绘制项中点x坐标
 * @param index 数据索引
 * @param context 绘制相关的业务数据以及配置
 * @returns x坐标
 */
- (CGFloat)centerLocationForIndex:(NSUInteger)index context:(OPPlotSpacesContext *)context;

/**
 * 计算指定数据索引对应的绘制项右边x坐标
 * @param index 数据索引
 * @param context 绘制相关的业务数据以及配置
 * @returns x坐标
 */
- (CGFloat)rightLocationForIndex:(NSUInteger)index context:(OPPlotSpacesContext *)context;

/**
 * 计算指定x位置最接近的绘制项索引
 * @param position x坐标
 * @param context 绘制相关的业务数据以及配置
 * @returns 绘制项索引
 */
- (NSUInteger)nearIndexForLocation:(CGFloat)position context:(OPPlotSpacesContext *)context;

/**
 * 将数据值映射到绘制区域，计算该值对应的y轴坐标
 * @param v 数据值
 * @param max 最大值
 * @param min 最小值
 * @param top 绘制区域y最大值
 * @param bottom 绘制区域y最小值
 * @returns 数据值对应的坐标
 */
- (CGFloat)locationYForValue:(long long)v withMax:(long long)max min:(long long)min top:(CGFloat)top bottom:(CGFloat)bottom;

@end

/**
 * 主体绘制层，一个图表，只有一个主体绘制项，用于确定业务数据处理的范围，即确定开始索引结束索引
 */
@interface OPPlotLayerPrimary : OPPlotLayer

/**
 * 计算开始结束索引
 */
- (void)processFromToIndexWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context;

@end

/**
 * 图表原型delegate
 */
@protocol OPPlotSpacesDelegate <NSObject>

//计算完最大值最小值后调用，在回调中可以更改最大值最小值
- (void)afterProcessMaxMin:(OPPlotDataLayer *)dataLayer;

@end

/**
 * 图表原型基类，比如说K线作为一个原型，它由多个蜡烛图、均线等绘制项组成。
 */
@interface OPPlotSpacesBase : NSObject

@property (nonatomic) id<OPPlotSpacesDelegate> delegate;
@property (nonatomic) CGRect frame;//图表区域
@property (nonatomic) UIEdgeInsets axisInsets;//坐标轴所占区域，左侧外边坐标轴设置left，右侧外边坐标轴设置right，上侧外边坐标轴设置top，下侧外边坐标轴设置bottom
@property (nonatomic) UIEdgeInsets padding;//主体绘制层距离坐标轴区域的间距，默认为(1., 1., 1., 1.)
@property (nonatomic, strong) NSArray *axesX;//X坐标轴集合@[OPPlotAxisX]
@property (nonatomic, strong) NSArray *axesY;//Y坐标轴集合@[OPPlotAxisY]
@property (nonatomic, strong) OPPlotAxisGrid *axisGrid;//坐标轴绘制

@property (nonatomic, strong) OPPlotDataLayer *dataLayer;//数据层
@property (nonatomic, strong) OPPlotSpacesContext *context;//绘制相关的业务数据以及配置
@property (nonatomic, strong) OPPlotLayerPrimary *primaryLayer;//主体绘制层，决定起始结束索引

- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)init;

//在指定区域进行绘制
- (void)drawRect:(CGRect)rect withContext:(CGContextRef)context;

#pragma mark --------------图表布局--------------

/**
 * 增加绘制层
 */
- (void)addPlotLayer:(OPPlotLayer *)plotLayer forKey:(NSString *)key;

/**
 * 删除绘制层
 */
- (void)removePlotLayerForKey:(NSString *)key;

/**
 * 重新对图表进行布局，以下几种情况会调用：1，frame更改时；2，axisInsets坐标区域进行更改时；3，padding主体绘制层距离坐标轴区域的间距更改时；4，各绘制层增加删除修改时
 */
- (void)layoutPlotSpaces;

#pragma mark --------------数据预处理过程--------------

/**
 * 对数据进行预处理，主要由以下几步构成：1，确定数据的开始结束索引；2，计算最大值最小值；3，确定坐标轴的绘制区域；
 */
- (void)processingData;

#pragma mark --------------数据转换过程--------------

/**
 * 生成绘制数据，收到数据、或者绘制区域更改时会调用
 */
- (void)buildPlotDatas;

@end

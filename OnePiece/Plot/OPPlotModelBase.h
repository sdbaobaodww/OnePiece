//
//  OPPlotModelBase.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

static const int OPZIndex_Axis_Line         = 10;//坐标轴网格线zindex值
static const int OPZIndex_Axis_Label        = 100;//坐标轴文本zindex值
static const int OPZIndex_Bar               = 1000;//柱状图zindex值
static const int OPZIndex_Curve             = 10000;//曲线zindex值

@interface OPPlotModelBase : NSObject

@property (nonatomic) int zIndex;//绘制顺序

- (void)drawWithContext:(CGContextRef)context;

@end

//坐标轴文本对象
@interface OPPlotLabelModel : OPPlotModelBase

@property (nonatomic) CGRect textRect;//文本绘制区域
@property (nonatomic, strong) UIFont *textFont;//文本字体
@property (nonatomic, strong) UIColor *textColor;//文本颜色
@property (nonatomic, copy) NSString *text;//文本
@property (nonatomic) NSTextAlignment textAlignment;

@end

//path绘制数据
@interface OPPlotPathModel : OPPlotModelBase

@property (nonatomic, readwrite, assign) CGPathRef path;//绘制路径
@property (nonatomic) CGPathDrawingMode drawingMode;//绘制方式
@property (nonatomic, strong) UIColor *fillColor;//填充颜色
@property (nonatomic, strong) UIColor *strokeColor;//描绘颜色
@property (nonatomic) CGLineCap lineCap;//线端点类型
@property (nonatomic) CGLineJoin lineJoin;//线连接类型
@property (nonatomic) CGFloat lineWidth;//线宽
@property (nonatomic, strong) NSArray *dashPattern;//线型模板

@end

//渐变绘制数据
@interface OPPlotGradientModel : OPPlotModelBase

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic, readwrite, assign) CGPathRef gradientPath;//渐变绘制路径
@property (nonatomic, strong) NSArray *gradientColors;//渐变颜色数组

@end

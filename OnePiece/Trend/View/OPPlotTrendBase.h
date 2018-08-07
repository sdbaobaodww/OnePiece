//
//  OPPlotTrendBase.h
//  OnePiece
//
//  Created by Duanwwu on 2017/1/18.
//  Copyright © 2017年 DZH. All rights reserved.
//

#import "OPPlotViewBase.h"

@class OPTrendUpdaterManager;
@class OPMarketSecurityModel;

/**
 * 在OPPlotViewModelBase的基础上增加数据层的管理
 */
@interface OPPlotViewModelTrend : OPPlotViewModelBase

@property (nonatomic, strong) OPTrendUpdaterManager *updaterManager;//数据刷新管理对象

@property (nonatomic, strong) OPPlotSpacesContext *context;//图表绘制上下文

@property (nonatomic, strong) OPMarketSecurityModel *securityModel;//证券数据模型

- (instancetype)initWithPlotSpacesContext:(OPPlotSpacesContext *)context
                           updaterManager:(OPTrendUpdaterManager *)updaterManager
                            securityModel:(OPMarketSecurityModel *)securityModel;

@end

@interface OPPlotDataLayerTrend : OPPlotDataLayer

@property (nonatomic) int baseValue;//基准值，对数坐标时使用
@property (nonatomic) short decimal;//小数位数

@end

@interface OPPlotAxisYTrend : OPPlotAxisY

/**
 * 计算坐标文本的最大宽度
 */
- (CGSize)axisTextSizeWithMax:(long long)max min:(long long)min baseValue:(long long)baseValue decimal:(short)decimal axisFont:(UIFont *)axisFont axisType:(OPAxisType)axisType;

/**
 * 生成坐标文本
 */
- (NSString *)textWithValue:(long long)value baseValue:(long long)baseValue decimal:(short)decimal axisType:(OPAxisType)axisType;

@end

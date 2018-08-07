//
//  OPPlotViewMinute.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/22.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPPlotTrendBase.h"

/**
 * 分时视图模型观察接口，用于监听分时数据重置和接收
 */
@protocol OPPlotViewModelMinuteObserver <NSObject>

//分时数据进行重置，如A股每天9点10分左右服务端会进行数据重置
- (void)resetMinuteData;

//接收到分时数据
- (void)receiveMinuteData:(NSArray *)minutes;

@end

//分时视图模型
@interface OPPlotViewModelMinute : OPPlotViewModelTrend

- (void)addMinuteObserver:(id<OPPlotViewModelMinuteObserver>)dataObserver;

- (void)removeMinuteObserver:(id<OPPlotViewModelMinuteObserver>)dataObserver;

@end

//分时视图
@interface OPPlotViewMinute : OPPlotViewBase

@end

//分时成交量视图模型
@interface OPPlotViewModelMinuteVolume : OPPlotViewModelTrend<OPPlotViewModelMinuteObserver>

- (void)setLastClose:(int)lastClose;

@end

//分时成交量视图
@interface OPPlotViewMinuteVolume : OPPlotViewBase

@end

//分时、分时成交量混合视图模型
@interface OPPlotViewModelCombine : OPPlotViewModelTrend

- (void)setLastClose:(int)lastClose decimal:(int)decimal;

- (void)setMax:(int)max min:(int)min;

@end

//分时、分时成交量混合视图
@interface OPPlotViewMinuteVolumeCombine : OPPlotViewBase

@end

//分时level2指标视图模型
@interface OPPlotViewModelMinuteLevel2 : OPPlotViewModelTrend<OPPlotViewModelMinuteObserver>

- (void)switchLevel2;

@end

//分时level2指标视图
@interface OPPlotViewMinuteLevel2 : OPPlotViewBase

@end

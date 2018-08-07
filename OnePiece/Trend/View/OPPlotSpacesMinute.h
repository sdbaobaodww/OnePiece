//
//  OPPlotSpacesMinute.h
//  OnePiece
//
//  Created by Duanwwu on 2016/11/22.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPPlotTrendBase.h"

#pragma mark -------分时绘制--------------

@interface OPPlotDataLayerMinute : OPPlotDataLayerTrend

@property (nonatomic) int totalNum;//当天分钟数据总个数

@end

@interface OPPlotAxisYMinute : OPPlotAxisYTrend

@end

@interface OPPlotLayerMinute : OPPlotLayerPrimary

@end

@interface OPPlotAxisGridMinute : OPPlotAxisGrid

@end

@interface OPPlotSpacesMinute : OPPlotSpacesBase

- (void)setTotalNum:(int)totalNum;//设置当天分钟数据总个数，用于计算每个分时点之间的间距

@end

#pragma mark -------分时成交量绘制--------------

@interface OPPlotAxisYMinuteVolume : OPPlotAxisYTrend

@end

@interface OPPlotLayerMinuteVolume : OPPlotLayerPrimary

@end

@interface OPPlotAxisGridMinuteVolume : OPPlotAxisGrid

@end

@interface OPPlotSpacesMinuteVolume : OPPlotSpacesBase

@end

#pragma mark -------分时DDX绘制--------------

@interface OPPlotLayerMinuteDDX : OPPlotLayerPrimary

@end

@interface OPPlotAxisGridMinuteDDX : OPPlotAxisGrid

@end

@interface OPPlotSpacesMinuteDDX : OPPlotSpacesBase

@end

#pragma mark -------分时成交单数差--------------

@interface OPPlotLayerOrderDiffer : OPPlotLayerPrimary

@end

@interface OPPlotSpacesOrderDiffer : OPPlotSpacesBase

@end

#pragma mark -------分时总买卖量绘制--------------

@interface OPPlotLayerTotalAskBid : OPPlotLayerPrimary

@end

@interface OPPlotSpacesTotalAskBid : OPPlotSpacesBase

@end

//
//  OPTrendDataUpdater.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/16.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPTrendUpdaterManager.h"
#import "OPMarketPackageImpl.h"

@class OPIncrementRequestHelper;

/**
 * 静态数据更新类，通常只需请求一次
 */
@interface OPDataUpdaterStatic : OPDataUpdaterBase

@property (nonatomic, strong) OPResponsePackage2939 *staticData;

@end

/**
 * 动态数据更新类，需实时更新数据
 */
@interface OPDataUpdaterDynamic : OPDataUpdaterBase

@property (nonatomic, strong) OPResponsePackage2940 *dynamicData;

@end

/**
 * 分时数据更新类
 */
@interface OPDataUpdaterMinute : OPDataUpdaterBase

@property (nonatomic) unsigned short totalNum;//一天总的分时数目

@property (nonatomic, strong, readonly) NSArray *minutes;

@property (nonatomic) BOOL isReset;//数据是否进行重置

@end

/**
 * 分时level2数据更新基类
 */
@interface OPDataUpdaterMinuteLevel2 : OPDataUpdaterBase
{
 @protected
    OPIncrementRequestHelper                *_requestHelper;
}

@property (nonatomic, strong) NSArray *minutes;

@property (nonatomic, strong, readonly) NSArray *level2Data;

/**
 * 分时数据重置时的处理
 */
- (void)onResetMinuteData;

/**
 * 创建请求包，子类需重载
 * @param code 证券代码
 * @param beginPos 起始位置
 * @returns 数据请求包
 */
- (OPMarketRequestPackage *)level2RequestWithCode:(NSString *)code beginPos:(int)beginPos;

/**
 * 更新新数据，比如DDX，需对新数据进行ddx计算
 * @param recentLevel2 最新level2数据
 * @param model 原有level2数据最后一个数据
 */
- (void)updateRecentLevel2Data:(NSArray *)recentLevel2 lastModel:(id)model;

/**
 * 对原有的level2数据进行更新，即使用新的数据项替换掉原有level2数据集合中的数据
 * @param level2 原有level2数据
 * @param index 原有level2数据进行替换的起始索引
 * @param recentLevel2 最新level2数据
 * @param limitCount 替换个数
 */
- (void)replaceLevel2Data:(NSMutableArray *)level2 startIndex:(NSInteger)index recentLevel2:(NSArray *)recentLevel2 limitCount:(NSInteger)limitCount;

@end

/**
 * 分时DDX数据更新类
 */
@interface OPDataUpdaterMinuteDDX : OPDataUpdaterMinuteLevel2

@end

/**
 * 分时单差数据更新类
 */
@interface OPDataUpdaterOrderDiffer : OPDataUpdaterMinuteLevel2

@end

/**
 * 分时总买卖量数据更新类
 */
@interface OPDataUpdaterTotalAskBid : OPDataUpdaterMinuteLevel2

@end


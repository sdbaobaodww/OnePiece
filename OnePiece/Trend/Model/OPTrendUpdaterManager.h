//
//  OPTrendUpdaterManager.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/15.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPMarketDataUpdaterManager.h"

@class OPMarketRequestPackageGroup;

@interface OPTrendUpdaterManagerContext : OPUpdaterManagerContext

@property (nonatomic, strong, readonly) OPMarketRequestPackageGroup *groupPackage;

@end

@interface OPTrendUpdaterManager : OPDataUpdaterManager

@property (nonatomic) NSTimeInterval timerInterval;

/**
 * 唤醒分时k线数据管理对象
 */
- (void)resumeDataManager;

/**
 * 暂停分时k线数据管理对象
 */
- (void)suspendDataManager;

/**
 * 重置并刷新数据
 */
- (void)resetAndUpdate;

@end

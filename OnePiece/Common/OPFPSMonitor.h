//
//  OPFPSMonitor.h
//  OnePiece
//
//  Created by Duanww on 2018/8/9.
//  Copyright © 2018年 Duanww. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 监听FPS变化
 */
@interface OPFPSMonitor : NSObject

/**
 开启监控
 
 @param block FPS数据回调block
 */
- (void)startFPSMonitorWithBlock:(void(^)(NSInteger fps))block;

/**
 开启后，需要手动停止监控
 */
- (void)stopFPSMonitor;

@end

//
//  OPTrendConstant.h
//  OnePiece
//
//  Created by Duanwwu on 2016/12/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

//分时k线绘制坐标轴字体大小
static CGFloat OPTrend_AxisY_Font               = 11.;

/**
 * 根据价格相对于基准价格的变动返回指定的颜色
 * @param basePrice 基准价格，通常为昨收价
 * @param price 进行比较的价格
 * @returns 颜色对象
 */
UIColor * ColorWithPriceChange(long long basePrice, long long price);

@interface OPTrendConstant : NSObject

@end

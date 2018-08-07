//
//  OPTrendConstant.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPTrendConstant.h"
#import "UIColor+Hex.h"

UIColor * ColorWithPriceChange(long long basePrice, long long price)
{
    return price > basePrice ? [UIColor hex_colorFromRGB:0xef3939] : (price < basePrice ? [UIColor hex_colorFromRGB:0x4ca92a] : [UIColor hex_colorFromRGB:0x9aa4ad]);
}

@implementation OPTrendConstant

@end

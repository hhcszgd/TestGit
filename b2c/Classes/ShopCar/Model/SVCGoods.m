//
//  SVCGoods.m
//  TTmall
//
//  Created by wangyuanfei on 3/13/16.
//  Copyright © 2016 Footway tech. All rights reserved.
//

#import "SVCGoods.h"

@implementation SVCGoods
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self=[super init]) {
        [self setValuesForKeysWithDictionary:dict];
        ////////////////////////////////////////////
//        self.productSizeOrColor = @"这是颜色和尺寸";
//        self.productSizeOrColor=@"套餐类型:官方标配 ; 颜色分类:豹纹花 ; 尺寸 : XXL  ";
//        self.goodsSelect=NO;
//        self.showTicket=YES;
//
//        self.colors =@[@"红色",@"蓝色",@"白色",@"红白色",@"红绿色",@"红蓝色",@"白蓝色",@"卡布奇诺色",@"黑色",@"咖啡色",@"红色",@"蓝色",@"白色",@"红白色",@"红绿色",@"红蓝色",@"白蓝色",@"卡布奇诺色",@"黑色",@"咖啡色",@"红色",@"蓝色",@"白色",@"红白色",@"红绿色",@"红蓝色",@"白蓝色",@"卡布奇诺色",@"黑色",@"咖啡色",@"红色",@"蓝色",@"白色",@"红白色",@"红绿色",@"红蓝色",@"白蓝色",@"卡布奇诺色",@"黑色",@"咖啡色",@"红色",@"蓝色",@"白色",@"红白色",@"红绿色",@"红蓝色",@"白蓝色",@"卡布奇诺色",@"黑色",@"咖啡色",@"红色",@"蓝色",@"白色",@"红白色",@"红绿色",@"红蓝色",@"白蓝色",@"卡布奇诺色",@"黑色",@"咖啡色",@"红色",@"蓝色",@"白色",@"红白色",@"红绿色",@"红蓝色",@"白蓝色",@"卡布奇诺色",@"黑色",@"咖啡色"];
//        self.chooseColor=nil;
//        self.sizes = @[@36,@36.5,@37,@37.5,@38,@39,@40,@41,@42,@43,@44,];
//        self.chooseSize=0;
//
//        self.storeCount = 1000;
//        
//        self.productProperties=@[
//                                 //////////////////////////////////////////////////////////////////////////////
//                                 @[
//                                     @{
//                                         @"type":@"套餐类型"
//                                         },
//                                     @{
//                                         @"types":@[
//                                                 @"中低配",@"低配",@"高低配",@"低标配",@"标配",@"高标配",@"低高配",@"高配",@"超高配"
//                                                 ]
//                                         }
//                                     
//                                     ],
//                                 //////////////////////////////////////////////////////////////////////////////
//                                 
//                                 @[
//                                     @{
//                                         @"type":@"版本类型"
//                                         },
//                                     @{
//                                         @"types":@[
//                                                 @"大陆版",@"日版",@"欧美版",@"韩版",@"俄罗斯版",@"印度尼西亚版",@"孟加拉版",@"肯尼亚版"]
//                                         }
//                                     
//                                     ],
//                //////////////////////////////////////////////////////////////////////////////
//                                 @[
//                                     @{
//                                         @"type":@"颜色分类"
//                                         },
//                                     @{
//                                         @"types":@[
//                                                 @"红色",@"蓝色",@"白色",@"红白色",@"红绿色",@"红蓝色",@"白蓝色",@"卡布奇诺色",@"黑色",@"咖啡色",@"红色",@"蓝色",@"白色",@"红白色",@"红绿色",@"红蓝色",@"白蓝色",@"卡布奇诺色",@"黑色",@"咖啡色",@"红色",@"蓝色",@"白色",@"红白色",@"红绿色",@"红蓝色",@"白蓝色",@"卡布奇诺色",@"黑色"
//                                                 
//                                                 ]
//                                         }
//                                     
//                                     ]
//                                 //////////////////////////////////////////////////////////////////////////////
//                                 ];
        //////////////`/////////////////////////
    }
    return self;
    
}
-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"id"]) {//id作用暂时不用
        self.ID = value;
        return;
    }
    if ([key isEqualToString:@"shop_price"]) {//
        self.shop_price = [value integerValue];
        self.showPrice = [NSString stringWithFormat:@"%0.2f",self.shop_price/100.0];
        return;
    }
    if ([key isEqualToString:@"price"]) {//返回的价格单位是分 , 一定是整数
        self.price  = [value integerValue];
        self.showPrice = [NSString stringWithFormat:@"%0.2f",self.price/100.0];
        LOG(@"_%@_%d__zzzzzzzzzzz转之前 单位是分%ld",[self class] , __LINE__,self.price);
        LOG(@"_%@_%d_zzzzzzzzzzz转之后 单位是元%@",[self class] , __LINE__,self.showPrice);
        return;
    }
    [super setValue:value forKey:key];
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{}
-(id)copyWithZone:(NSZone *)zone{
    SVCGoods * good = [[SVCGoods alloc]init];
    good.goods_id= self.goods_id;
    good.shop_id = self.shop_id;
    good.ID = self.ID;
    
    return good;
}



@end

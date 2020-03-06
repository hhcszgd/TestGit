//
//  SizeAndColorLayout.m
//  TTmall
//
//  Created by wangyuanfei on 16/1/11.
//  Copyright © 2016年 Footway tech. All rights reserved.
//

#import "SearchFlowLayout.h"
//#import "CellModel.h"
@interface SearchFlowLayout()
//@property(nonatomic,strong)CellModel * cellModel ;
@property(nonatomic,strong)NSArray * arr ;//用来返回的
@property(nonatomic,strong)NSArray * datas ;//用来接收外界数据的
@property(nonatomic,assign)CGFloat  contentSizeHeight ;
@end

@implementation SearchFlowLayout
-(instancetype)initWithDatas:(NSArray*)datas{

    if (self=[super init]) {
        self.datas = datas;
    }
    return self;
}

//-(NSArray  * )arr{
//    if(_arr==nil){
//        _arr = [[NSArray alloc]init];
//    }
//    return _arr;
//}

-(void)prepareLayout{
    NSMutableArray * arrM = [NSMutableArray array];
    CGFloat headerH = 44*SCALE;
    CGFloat margin = 6;
    CGFloat leftPadding = 20.0;
    CGFloat rightPadding = leftPadding ;
    CGFloat totalW = 0;
    CGFloat totalH = 0;
    CGFloat leftW= 0;
    NSArray * bigArr =self.datas;
    LOG(@"_%@_%d_%@",[self class] , __LINE__,bigArr);
    for (int s=0; s<bigArr.count; s++) {
//        NSArray * midArr = bigArr[s];
        NSArray * litArr = bigArr[s];;
        
        //创建头部视图的布局属性
        UICollectionViewLayoutAttributes *headerAtt = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:s]];
        headerAtt.frame = CGRectMake(0, totalH, screenW, headerH);
        [arrM addObject:headerAtt];
        
        totalW=leftPadding;
        totalH+=headerH;
        LOG(@"_%@_%d_%@",[self class] , __LINE__,litArr);
        for (int q=0; q<litArr.count; q++) {
            NSString * tempTitleStr = litArr[q];
            if ([tempTitleStr containsString:@"\r"]) {
                tempTitleStr= [tempTitleStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            }
            if ([tempTitleStr containsString:@"\n"]) {
                tempTitleStr= [tempTitleStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            }
            if ([tempTitleStr containsString:@"\t"]) {
                tempTitleStr=  [tempTitleStr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            }
            CGSize textSize = [tempTitleStr sizeWithFont:[UIFont systemFontOfSize:14*SCALE] MaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
            CGSize size = CGSizeMake(textSize.width + 20.0, textSize.height + 10.0) ;//label 的size
            CGFloat x = 0;
            CGFloat y = 0;
            CGFloat w = 0;
            CGFloat h = 0;
            leftW = screenW-totalW-rightPadding;//加一个右边距(剩下的宽度)
            h=size.height;
            if (leftW<size.width && totalW == leftPadding) {
//                totalW=leftPadding;
                w=leftW;
                y=totalH;
                x=leftPadding;
                totalW=leftPadding;
                totalH +=(size.height+margin);//如果一行不满 本组就结束了,就少加了一个行高

            }else  if (leftW<size.width) {
                totalW=leftPadding; //2 totalW 会在这里重置
                leftW = screenW-totalW-rightPadding;
                totalH +=(size.height+margin);//如果一行不满 本组就结束了,就少加了一个行高
                w = size.width > leftW ? leftW : size.width ;

                y=totalH;
                x=totalW;
                totalW+=(size.width+margin);//1如果下个item换行
            }else{
                w=size.width;
                y=totalH;
                x=totalW;//3 如果下一个item不换行 , totalW在这里生效
                totalW+=(size.width+margin);
            }
            UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:q inSection:s]];
            attr.frame = CGRectMake(x,y,w,h);
            [arrM addObject:attr];
 
        }
        
        totalH+=headerH;// 所以每一组结束的时候再加一个行高或者组头高
    }

    self.arr = arrM;
    NSString * temp = @"测试";
    CGSize size =[temp sizeWithFont:[UIFont systemFontOfSize:20*SCALE] MaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    self.contentSizeHeight=totalH+size.height;
}

-(CGSize)collectionViewContentSize{
    return CGSizeMake(screenW-20, _contentSizeHeight);

}
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    return self.arr;
}
@end

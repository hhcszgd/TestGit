//
//  FlowLayout.m
//  TTmall
//
//  Created by 0 on 16/1/28.
//  Copyright © 2016年 Footway tech. All rights reserved.
//

#import "FlowLayout.h"
#import "HSepcSubModel.h"
#import "HSepcSubTypeDetailModel.h"
@interface FlowLayout()
@property(nonatomic,strong)NSArray * arr ;
@property(nonatomic,assign)CGFloat  contentSizeHeight ;
/**布局属性*/
@property (nonatomic, strong) NSMutableArray *LayoutAttributes;
@end
@implementation FlowLayout



- (NSMutableArray *)LayoutAttributes{
    if (_LayoutAttributes == nil) {
        _LayoutAttributes = [[NSMutableArray alloc] init];
    }
    return _LayoutAttributes;
}


//准备布局
- (void)prepareLayout{
    
    
    /**组头的高度*/
    CGFloat headerH = 40;
    /**组委的高度*/
    CGFloat footerH = 1;
    /**每个item之间的间隔*/
    CGFloat margin = 20;//各个item之间的间隔
    /**行间距*/
    CGFloat lineMargin = 15;
    /**距离左边屏幕的距离*/
    CGFloat leftPadding = 10;
    /**布局的总宽度*/
    CGFloat totalW = 0;
    /**布局的总高度*/
    CGFloat totalH = 0;
    /**剩余的宽度*/
    CGFloat leaveW = 0;
   
    for (NSInteger i = 0; i < self.arr.count ; i++) {
        //首先设置组头
        HSepcSubModel *specSub = self.arr[i];
        /**每个组里面的具体的item*/
        
        
        NSArray *array = specSub.typeDetail;
        
        
        UICollectionViewLayoutAttributes *headerAtt = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
        headerAtt.frame = CGRectMake(0, totalH, screenW, headerH);
        //将组头的布局属性放在布局数组中
        [self.LayoutAttributes addObject:headerAtt];
        //contentsize 的高度相应的增加
        totalH += headerH + lineMargin;
        
        
        //布局组中每个item的属性。设置item距离左边屏幕的距离
        totalW = leftPadding;
        for (NSInteger j = 0; j < array.count; j++) {
            CGFloat x = 0;
            CGFloat y = 0;
            CGFloat w = 0;
            CGFloat h = 0;
            leaveW = screenW - 2 * leftPadding - totalW;
            HSepcSubTypeDetailModel *titleModel = array[j];
            NSString *itemTitle = titleModel.quality;
            //根据字体大小计算字体的大小
            CGSize size = [itemTitle sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12 * zkqScale],NSFontAttributeName, nil]];
            //适当的增加item的高度和宽度
            
            w = size.width +22;
            h = size.height + 16;
            //判断item的宽度是否大于剩余宽度。如果大于则是放不下那么就排到下一行。
            if (w > leaveW) {
                totalW = leftPadding;
                totalH += h + lineMargin;
            }
            x = totalW;
            y = totalH;
            //设置每个item的高度。
            UICollectionViewLayoutAttributes *itemAtt = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:j inSection:i]];
            
            itemAtt.frame = CGRectMake(x, y, w, h);
            
            //将布局属性放到数组中
            [self.LayoutAttributes addObject:itemAtt];
            //总宽度
            totalW = w + totalW + margin;
        }
        //添加最后一行的高度，以一个字的宽度为标准并且添加相同的高度
        CGSize size = [@"我" sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12*zkqScale ],NSFontAttributeName, nil]];
        totalH += size.height + 14;
        
        totalH += lineMargin;
        //添加组尾的布局属性
        
        
        
        if ((self.arr.count - 1)== i) {
            UICollectionViewLayoutAttributes *footeratt = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
            footeratt.frame = CGRectMake(0, totalH, screenW, 80);
            
            [self.LayoutAttributes addObject:footeratt];
            totalH += 80;
        }else{
            UICollectionViewLayoutAttributes *footerAtt = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
            footerAtt.frame = CGRectMake(10, totalH, screenW - 20, footerH);
            
            [self.LayoutAttributes addObject:footerAtt];
            totalH += footerH;
        }
        
        //添加组尾后将高度加组尾的高度
        
    
    }
    
    
    
    
    
    
    
    self.contentSizeHeight = totalH;
    
    
    
    
}



- (void)setDataArr:(NSArray *)dataArr{
    self.arr = dataArr;
    
    [self.LayoutAttributes removeAllObjects];
}

-(CGSize)collectionViewContentSize{
    return CGSizeMake(screenW, self.contentSizeHeight);
    
}
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    return self.LayoutAttributes;
}
@end
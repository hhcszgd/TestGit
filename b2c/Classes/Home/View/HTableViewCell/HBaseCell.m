//
//  HBaseCell.m
//  b2c
//
//  Created by wangyuanfei on 4/11/16.
//  Copyright © 2016 www.16lao.com. All rights reserved.
//

#import "HBaseCell.h"
#import "HCellBaseComposeView.h"
@implementation HBaseCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    return self;
}
-(void)composeClick:(HCellBaseComposeView*)sender
{
    if (sender.composeModel) {
        NSLog(@"%@, %d ,%@",[self class],__LINE__,sender.composeModel.link);
        if (sender.composeModel.value.length > 0) {
            sender.composeModel.keyParamete = @{@"paramete": sender.composeModel.value};
        }
        NSDictionary * pragma = @{
                                  @"HCellComposeViewModel":sender.composeModel
                                  };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HCellComposeViewClick" object:nil userInfo:pragma];
    }
    //    LOG(@"_%@_%d_%@",[self class] , __LINE__,self.composeModel.actionKey)
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

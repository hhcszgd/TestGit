//
//  ThreePointMenuVC.m
//  b2c
//
//  Created by wangyuanfei on 6/28/16.
//  Copyright © 2016 www.16lao.com. All rights reserved.
//

#import "ThreePointMenuVC.h"
#import "HGMoreView.h"
#import "b2c-Swift.h"

@interface ThreePointMenuVC ()<HGMoreViewDelegate>
@property(nonatomic,strong)NSArray * menuArr  ;
@end

@implementation ThreePointMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HGMoreView * threePointMenu = [[HGMoreView alloc]initWithFrame:CGRectMake(0, 0, 44, 44) withDataArr:self.menuArr fatherVC:self cellHeihgt:40];
    threePointMenu.delegate = self ;
    self.navigationBarRightActionViews= @[threePointMenu];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    LOG(@"_%@_%d_%@",[self class] , __LINE__,@"fuck , 内存警告");
    // Dispose of any resources that can be recreated.
}
-(void)HGMoreViewActionToTatargWithIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
//        [[KeyVC shareKeyVC] skipToTabbarItemWithIndex:0];
        [[GDKeyVC share] selectChildViewControllerIndexWithIndex:0];

        [self.navigationController popToRootViewControllerAnimated:NO ];
    }else if (indexPath.row ==1 ){
        BaseModel * model = [[BaseModel alloc]init];
        model.actionKey = @"HSearchVC";
        [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
    }else if (indexPath.row ==2 ){
        BaseModel * model = [[BaseModel alloc]init];
        model.actionKey = @"FriendListVC";
        [[SkipManager shareSkipManager] skipByVC:self withActionModel:model];
    }else if (indexPath.row ==3 ){
        
    }else{}

}
-(NSArray * )menuArr{
    if(_menuArr==nil){
        _menuArr = @[@"首页",@"搜索",@"消息"];
    }
    return _menuArr;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

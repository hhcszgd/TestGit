//
//  UserInfoViewModel.m
//  TTmall
//
//  Created by wangyuanfei on 3/2/16.
//  Copyright © 2016 Footway tech. All rights reserved.
/**
    记得增加判断返回的data字段为空或者类型不匹配的情况
 
 */

#import "UserInfoViewModel.h"
#import "UserInfo.h"
#import "ShopCoupon.h"
//#import "HomeHttpTool.h"
#import "GDXmppStreamManager.h"
#import "AMCellModel.h"//收货地址模型

#import "SpecModel.h"

typedef enum : NSUInteger {
    POST,
    GET,
    PUT
} ActionType;

@interface UserInfoViewModel ()
@property(nonatomic,strong)  AFHTTPSessionManager*mar ;
@property(nonatomic,copy)NSString * midPath ;
@property(nonatomic,copy)NSString * endPath ;

@property(nonatomic,strong)UIActivityIndicatorView * activetyIndicator ;

/** 定时器 */

//@property(nonatomic,strong)NSTimer * timer ;
/** 第一次不提示网络 变化 */
@property(nonatomic,assign)NSInteger  time ;
/** 网络是否处于请求状态 */
@property(nonatomic ,assign)BOOL isRequesting ;

@end
@implementation UserInfoViewModel

static UserInfoViewModel * _viewModel;

//////////////////////////////////////////////////////////////////////////



-(void)performActivetyIndicatorStopAnimating
{
    self.isRequesting = NO ;
    if (self.activetyIndicator.isAnimating)   [self.activetyIndicator stopAnimating];
    LOG(@"_%@_%d_%@",[self class] , __LINE__,@"结束了啊");

}

-(void)prepareActivetyIndicatorStartAnimating{
    self.isRequesting = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
//        LOG(@"_%@_%d_%@",[self class] , __LINE__,[NSThread currentThread]);
        dispatch_async(dispatch_get_main_queue(), ^{
//            LOG(@"_%@_%d_%@",[self class] , __LINE__,[NSThread currentThread]);
            if (self.isRequesting && !self.activetyIndicator.isAnimating) {
                [self.activetyIndicator startAnimating];
                LOG(@"_%@_%d_%@",[self class] , __LINE__,@"执行了没啊");
            }else{
                LOG(@"_%@_%d_%@%d%d",[self class] , __LINE__,@"怎么不执行呢",self.isRequesting,self.activetyIndicator.isAnimating);
            }
            
        });
        
    });
}

-(UIActivityIndicatorView * )activetyIndicator{
    if(_activetyIndicator==nil){
        _activetyIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [[UIApplication sharedApplication].keyWindow addSubview:_activetyIndicator];
        _activetyIndicator.center = [UIApplication sharedApplication].keyWindow.center;
        /**      [self.activetyIndicator startAnimating];
         [self.activetyIndicator stopAnimating];
         */
    }
    return _activetyIndicator;
}

-(NSString * )midPath{
    if(_midPath==nil){
//        _midPath = @"index.php?m=Api&c=V2/";
        _midPath = @"V2/";
    }
    return _midPath;
}
-(NSString * )endPath{
    if(_endPath==nil){
//        _endPath = @"&a=rest";
        _endPath = @"/rest";
    }
    return _endPath;
}
+(instancetype)shareViewModel{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _viewModel = [[UserInfoViewModel alloc]init];
    });
    return _viewModel;
}

-(instancetype)init{
    if (self=[super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeNetworkChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return self;
}
-(void)noticeNetworkChanged:(NSNotification*)note
{
    self.time ++ ;
    if (self.time==1) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"第一次不提示");
        return;
    }
    LOG(@"_%@_%d_%ld",[self class] , __LINE__,NetWorkingStatus);
    LOG(@"_%@_%d_%@\n\n%@",[self class] , __LINE__,@"网络状态改变了",note);
    NSDictionary * userInfo = note.userInfo;
    AFNetworkReachabilityStatus  currentNetwordStates = [userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
    /**     AFNetworkReachabilityStatusUnknown          = -1,
     AFNetworkReachabilityStatusNotReachable     = 0,
     AFNetworkReachabilityStatusReachableViaWWAN = 1,
     AFNetworkReachabilityStatusReachableViaWiFi = 2,
     */
    NSString * mark = @"isNeedLoginoutAfterReconnectToNetworking" ;
    BOOL isNeed = [[NSUserDefaults standardUserDefaults] boolForKey:mark];
    if (currentNetwordStates==AFNetworkReachabilityStatusUnknown) {
        AlertInSubview(@"网络连接失败\n请检查网络")
        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"网络未知");
    }else if (currentNetwordStates==AFNetworkReachabilityStatusNotReachable) {
        AlertInSubview(@"网络连接失败\n请检查网络")
        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"网络连接失败");
    }else if (currentNetwordStates==AFNetworkReachabilityStatusReachableViaWWAN) {
        AlertInSubview(@"当前网络环境为移动蜂窝网络")
        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"网络是移动蜂窝网络");
        if (isNeed) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:mark];
            //z执行退出操作
            NSString * url = @"LoginOut";
            NSDictionary * parame = @{@"did" : UUID };
            [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST    success:^(ResponseObject *response) {
                LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
                [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:MESSAGECOUNTCHANGED];
                [[NSNotificationCenter defaultCenter]  postNotificationName:MESSAGECOUNTCHANGED object:nil];
            } failure:^(NSError *error) {
            }];
        }
        
    }else if (currentNetwordStates==AFNetworkReachabilityStatusReachableViaWiFi) {
        AlertInSubview(@"当前网络环境为wifi")
        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"网络是wifi");
        if (isNeed) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:mark];
            //z执行退出操作
            NSString * url = @"LoginOut";
            NSDictionary * parame = @{@"did" : UUID };
            [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST    success:^(ResponseObject *response) {
                LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
                [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:MESSAGECOUNTCHANGED];
                [[NSNotificationCenter defaultCenter]  postNotificationName:MESSAGECOUNTCHANGED object:nil];
            } failure:^(NSError *error) {
            }];
        }
    }
}
/*
 if (NetWorkingStatus == AFNetworkReachabilityStatusUnknown || NetWorkingStatus == AFNetworkReachabilityStatusNotReachable) {
 //标记
 NSString * mark = @"isNeedLoginoutAfterReconnectToNetworking" ;
 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:mark];
 //再在网络恢复的地方调用退出接口
 }
 */
-(AFHTTPSessionManager * )mar{
    if(_mar==nil){
        NSURL * baseUrl = [NSURL URLWithString:BASEURL];
        _mar = [[AFHTTPSessionManager alloc]initWithBaseURL:baseUrl];
        [_mar.requestSerializer setValue:@"2" forHTTPHeaderField:@"APPID"];
        [_mar.requestSerializer setValue:@"1" forHTTPHeaderField:@"VERSIONID"];
        [_mar.requestSerializer setValue:@"20160501" forHTTPHeaderField:@"VERSIONMINI"];
//#pragma mark udid先写死成自己手机的udid    @"3436F0B9-E8E4-4BA8-B8BD-7F04EE43CD7F"
        [_mar.requestSerializer setValue:UUID forHTTPHeaderField:@"DID"];
//        [_mar.requestSerializer setValue:@"3436F0B9-E8E4-4BA8-B8BD-7F04EE43CD7F" forHTTPHeaderField:@"DID"];

        LOG(@"_%@_%d_*********自己的uuid-->%@",[self class] , __LINE__,UUID);
        _mar.responseSerializer.acceptableContentTypes =[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    }
    return _mar;
}


-(void)initializationWithUser:(UserInfo *)user {
    [self initializationWithUser:user success:^(ResponseStatus response) {
        
    } failure:^(NSError *error) {
    }];
}
-(void)initializationWithUser:(UserInfo*)user  success:(void(^)(ResponseStatus response))success failure:(void(^)(NSError*error))failure{//单独封装,不依赖其他方法
#pragma 路径拼接
     LOG(@"_%@_%d_👉👉👉初始化方法开始%s",[self class] , __LINE__,__FUNCTION__);
    NSString * url  = [self.midPath stringByAppendingPathComponent:@"InitKey" ] ;
    url = [url stringByAppendingString:self.endPath];
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,self.mar.baseURL);
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,url);
    
    [self.mar GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         ResponseObject * test  = [[ResponseObject alloc]initWithDict:responseObject];
         NSLog(@"_%d_%@",__LINE__,test.data);
        NSLog(@"_%d_%@",__LINE__,test.msg);
        NSLog(@"_%d_%d",__LINE__,test.status);
         LOG(@"_%@_%d_👉👉👉初始化 方法结束%s",[self class] , __LINE__,__FUNCTION__);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            //                LOG(@"_%@_%d_%@",[self class] , __LINE__,responseObject)
            ResponseObject * response = [[ResponseObject alloc]initWithDict:responseObject];
            
            if (response.status > 0) {
                LOG(@"_%@_%d_%@ , 即将合成token",[self class] , __LINE__,response.msg)
#pragma mark 先写死为自己手机的udid
                NSString * result =   [UUID  stringByAppendingString:response.data];
//                NSString * result =   [@"3436F0B9-E8E4-4BA8-B8BD-7F04EE43CD7F"  stringByAppendingString:response.data];
                
                result = [result md5String];
                [[NSUserDefaults standardUserDefaults] setValue:result forKey:@"TOKEN"];
                user.token=result;
                
                if ((![GDXmppStreamManager ShareXMPPManager].XmppStream.isConnected && ![GDXmppStreamManager ShareXMPPManager].XmppStream.isConnecting) && user.isLogin) {
                    //LOG(@"_%@_%d_登录IM时用得token%@",[self class] , __LINE__,[UserInfo shareUserInfo].token);

                        [[GDXmppStreamManager ShareXMPPManager]loginWithJID:[XMPPJID jidWithUser:[UserInfo shareUserInfo].imName domain:JabberDomain resource:@"iOS"] passWord:[UserInfo shareUserInfo].token];
                }
                GDlog(@"%@",result)
                NSLog(@"%@",@"");
                LOG(@"_%@_%d_     生成token成功%@",[self class] , __LINE__,result)
            }else{
                LOG(@"_%@_%d_  初始化方法中 , 请求成功 , 但操作失败 , 操作失败信息%@",[self class] , __LINE__,responseObject)
            }
            
            success(response.status);
            
        }else if ([responseObject isKindOfClass:[NSArray class]]){
            LOG(@"_%@_%d_%@",[self class] , __LINE__,@"返回数据为arr ")
        }else{
            LOG(@"_%@_%d_%@",[self class] , __LINE__,@"返回数据非arr & Dic")
        }
        if ([self.delegate respondsToSelector:@selector(initializationSuccess)]) {
            [self.delegate initializationSuccess];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
         LOG(@"_%@_%d_👉👉👉初始化(失败)方法结束%s",[self class] , __LINE__,__FUNCTION__);
        LOG(@"_%@_%d_初始化失败------%@",[self class] , __LINE__,error)
        
    }];
    
    
}


#pragma 上传头像(常规版)
//-(void)uploadPictureWithUser:(UserInfo *)user picData:(NSData*)picData success:(void(^)(ResponseStatus response))success failure:(void(^)(NSError*error))failure{
//    NSDictionary * parameters = @{
//                                  @"member_id":user.member_id,//head_images
//                                  };
//#pragma 路径拼接
//    
//
//    NSString * urlStr = @"HeadImg";
//    urlStr = [urlStr stringByAppendingString:self.endPath];
//    urlStr = [self.midPath stringByAppendingPathComponent:urlStr];
//    [self.mar POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        UIImage *img = [UIImage imageNamed:@"meinv08"];
//        NSData * data =     UIImagePNGRepresentation(img);
//        [formData appendPartWithFileData:data name:@"images" fileName:@"head_images.png" mimeType:@"image/png"];
//        
//    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        LOG(@"_%@_%d_%lld,%lld",[self class] , __LINE__,uploadProgress.completedUnitCount,uploadProgress.totalUnitCount)
//        LOG(@"_%@_%d_%@",[self class] , __LINE__,uploadProgress)
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        LOG(@"_%@_%d_%@",[self class] , __LINE__,responseObject)
//        LOG(@"_%@_%d_%@",[self class] , __LINE__,task)
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        LOG(@"_%@_%d_%@",[self class] , __LINE__,error)
//    }];
//    
//}
#pragma 上传头像(base64)
-(void)uploadPictureWithUser:(UserInfo *)user picBase64:(NSString*)picBase64   targetType:(NSUInteger)type  success:(void(^)(id response))success failure:(void(^)(NSError*error))failure{
    NSDictionary * parameters = @{
                                  @"member_id":user.member_id,
                                  @"headImg":picBase64,
                                  @"type":@(type)
                                  };

    NSString * urlStr = @"HeadImg";
    [self remoteLoadDataWithUrl:urlStr Parameters:parameters actionType:POST success:^(ResponseObject *response) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response)

        success(response);
    } failure:^(NSError *error) {
        failure(error);
        LOG(@"_%@_%d_%@",[self class] , __LINE__,error)
    }];
}
-(void)remoteLoadDataWithUrl:(NSString*)url Parameters:(id)parameters actionType:(ActionType)type success:(void(^)(ResponseObject* response))success failure:(void(^)(NSError*error))failure{
#pragma 路径拼接
    
    url = [self.midPath stringByAppendingPathComponent:url];
    if (![url containsString:@"Autograph/auth"]) {
        url = [url stringByAppendingString:self.endPath];
        
    }
    NSMutableDictionary * para = [[NSMutableDictionary alloc]initWithDictionary:parameters];
    
    if ([UserInfo shareUserInfo].token) {
        
        [self fatherRemoteMethodWithURL:url Parameters:para actionType:type success:^(ResponseObject *response) {
            if (response.status>0) {
                //                success(response);
            }else{
                LOG(@"_%@_%d_请求成功 , 但操作失败  失败信息%@ , 对应的url: %@",[self class] , __LINE__,response.msg,url)
                LOG(@"_%@_%d_状态码   -----> %d",[self class] , __LINE__,response.status)
            }
            success(response); //无论操作成功与否, 数据还是要返回的
        } failure:^(NSError *error) {
            failure(error);
        }];
        
    }else{
        if (![UserInfo shareUserInfo].token) {
            LOG(@"_%@_%d_XXXXXXXXXXXXXXXXXX--->%@",[self class] , __LINE__,@"token为空 , 即将重新生成")
        }
        [self initializationWithUser:[UserInfo shareUserInfo] success:^(ResponseStatus response) {
            if (response>0) {
                
                [self fatherRemoteMethodWithURL:url Parameters:para actionType:type success:^(ResponseObject *response) {
                    if (response.status>0) {
                    }else{
                        LOG(@"_%@_%d_请求成功 , 但操作失败  失败信息%@ , 对应的url: %@",[self class] , __LINE__,response.msg,url)
                        LOG(@"_%@_%d_状态码   -----> %d",[self class] , __LINE__,response.status)
                    }
                    success(response);
                } failure:^(NSError *error) {
                    failure(error);
                }];
                
            }else{
                LOG(@"_%@_%d_请求成功 , 但操作失败  状态码%d , 对应的url: %@",[self class] , __LINE__,response,url)
                
            }
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    
}
-(void)fatherRemoteMethodWithURL:(NSString*)url Parameters:(id)parameters actionType:(ActionType)type success:(void(^)(ResponseObject* response))success failure:(void(^)(NSError*error))failure{
    
    [self prepareActivetyIndicatorStartAnimating];
//    if (!self.activetyIndicator.isAnimating)  [self.activetyIndicator startAnimating];

    NSMutableDictionary * para = [[NSMutableDictionary alloc]initWithDictionary:parameters];
    
    [para setValue:[UserInfo shareUserInfo].token forKey:@"token"];
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,para);
    if (type==POST) {
        LOG(@"_%@_%d_👉👉👉请求开始(post) url为->%@ ,",[self class] , __LINE__,url);
        [self.mar POST:url parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [self performActivetyIndicatorStopAnimating];
//            [self.activetyIndicator stopAnimating];
            
            LOG(@"_%@_%d_%@",[self class] , __LINE__,responseObject)
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                ResponseObject * response = [[ResponseObject alloc]initWithDict:responseObject];
                LOG(@"_%@_%d_👉👉👉请求结束(post)成功 url为->%@ 状态信息->%@",[self class] , __LINE__,url,response.msg);
                success(response);
            }else if ([responseObject isKindOfClass:[NSArray class]]){
                 LOG(@"_%@_%d_👉👉👉请求结束(post) url为->%@ 返回数据为arr, 数据内容为 : %@",[self class] , __LINE__,url,responseObject);
            }else{
                LOG(@"_%@_%d_👉👉👉请求结束(post) url为->%@ 返回数据非arr & Dic , 数据内容为 : %@",[self class] , __LINE__,url ,responseObject);

            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            [self.activetyIndicator stopAnimating];
             [self performActivetyIndicatorStopAnimating];
            LOG(@"_%@_%d_👉👉👉请求结束(post) url为->%@ 错误信息为%@,",[self class] , __LINE__,url,error);
            failure(error);
        }];
    }else if (type==GET){
         LOG(@"_%@_%d_👉👉👉请求开始(get) url为->%@ ,",[self class] , __LINE__,url);
        
        [self.mar GET:url parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            [self.activetyIndicator stopAnimating];
             [self performActivetyIndicatorStopAnimating];
//                        LOG(@"_%@_%d_%@",[self class] , __LINE__,responseObject)
            
            if ([url isEqualToString:@"V2/IndexPage/rest"]) {////////////要改要改//////////
                
                ResponseObject * response = [[ResponseObject alloc]initWithDict:responseObject];
                [response save];
                NSDictionary * dict = ( NSDictionary * ) responseObject;
                NSString *docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
                NSString *path=[docPath stringByAppendingPathComponent:@"HomeData.plist"];
                
                BOOL chenggong =  [dict writeToFile:path atomically:YES];
                LOG(@"_%@_%d_更新首页数据至沙盒成功与否 - > %d",[self class] , __LINE__,chenggong);

            }
            
//            if ([url isEqualToString:@"V2/IndexPage/rest"]) {////////////要改要改//////////
//                NSDictionary * dict = ( NSDictionary * ) responseObject;
//                NSString *docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//                NSString *path=[docPath stringByAppendingPathComponent:@"HomeData.plist"];
//                
//                BOOL chenggong =  [dict writeToFile:path atomically:YES];
//                LOG(@"_%@_%d_更新首页数据至沙盒成功与否 - > %d",[self class] , __LINE__,chenggong);
//            }
            
//            if ([url isEqualToString:@"V2/MyPage/rest"]) {////////////要改要改//////////
//                NSDictionary * dict = ( NSDictionary * ) responseObject;
//                NSString *docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
//                NSString *path=[docPath stringByAppendingPathComponent:@"ProfileData.plist"];
//                
//                BOOL chengtong =  [dict writeToFile:path atomically:YES];
//                LOG(@"_%@_%d_写入个人数据结果%d",[self class] , __LINE__,chengtong);
//            }
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                NSLog(@"%@, %d ,%@",[self class],__LINE__,responseObject);
                ResponseObject * response = [[ResponseObject alloc]initWithDict:responseObject];
                

                
                  LOG(@"_%@_%d_👉👉👉请求结束(get)成功 url为->%@ 状态信息->%@",[self class] , __LINE__,url,response.msg);
                success(response);
            }else if ([responseObject isKindOfClass:[NSArray class]]){
                LOG(@"_%@_%d_👉👉👉请求结束(get) url为->%@ 返回数据为arr",[self class] , __LINE__,url);
            }else{
               LOG(@"_%@_%d_👉👉👉请求结束(get) url为->%@ 返回数据非arr & Dic",[self class] , __LINE__,url);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            [self.activetyIndicator stopAnimating];
            LOG(@"_%@_%d_👉👉👉请求结束(get) url为->%@ 错误信息为%@,",[self class] , __LINE__,url,error);
             [self performActivetyIndicatorStopAnimating];
            failure(error);
            //          LOG(@"_%@_%d_%@",[self class] , __LINE__,error.userInfo[@"NSLocalizedDescription"])
            LOG(@"_%@_%d_%@",[self class] , __LINE__,error)
        }];
    }else if (type==PUT){
         LOG(@"_%@_%d_👉👉👉请求开始(put) url为->%@ ,",[self class] , __LINE__,url);
        [self.mar PUT:url parameters:para success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            [self.activetyIndicator stopAnimating];
             [self performActivetyIndicatorStopAnimating];
//            LOG(@"_%@_%d_%@",[self class] , __LINE__,responseObject)
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                ResponseObject * response = [[ResponseObject alloc]initWithDict:responseObject];
                LOG(@"_%@_%d_👉👉👉请求结束(put)成功 url为->%@ 状态信息->%@",[self class] , __LINE__,url,response.msg);
                success(response);
            }else if ([responseObject isKindOfClass:[NSArray class]]){
                LOG(@"_%@_%d_👉👉👉请求结束(put) url为->%@ 返回数据为arr",[self class] , __LINE__,url);
                
            }else{
                LOG(@"_%@_%d_👉👉👉请求结束(put) url为->%@ 返回数据非arr & Dic",[self class] , __LINE__,url);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            [self.activetyIndicator stopAnimating];
            LOG(@"_%@_%d_👉👉👉请求结束(put) url为->%@ 错误信息为%@,",[self class] , __LINE__,url,error);
             [self performActivetyIndicatorStopAnimating];
            failure(error);
            //            LOG(@"_%@_%d_%@",[self class] , __LINE__,error.userInfo[@"NSLocalizedDescription"])
        }];
    }
    
}

/** 注册接口 */
-(void)registerWithUser:(UserInfo*)user Success:(void(^)(ResponseObject *response))success failure:(void(^)(NSError*error))failure{
    LOG(@"_%@_%d_%@",[self class] , __LINE__ , user.mobileCode);
    
    NSDictionary * parameters = @{
                   @"name": user.name,
                   @"password": user.password,
                   @"mobilecode":user.mobileCode,
                   @"mobile":user.mobile
                    };
    NSString *url  =  @"Register";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:POST success:^(ResponseObject *response) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
        
//        [self loginWithUser:user success:^(ResponseStatus response) {
//            
////            success(response);
//        } failure:^(NSError *error) {
//            failure(error);
//        }];
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/**推送*/
-(void)registerPushNotificationID:(UserInfo*)user deviceToken:(NSString*)deviceToken registerID:(NSString*) registerID Success:(void(^)(ResponseObject *response))success failure:(void(^)(NSError*error))failure{
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init] ;
    if (registerID) {
        [parameters setValue:registerID forKey:@"registrationID"];
    }else if (deviceToken) {
        [parameters setValue:deviceToken forKey:@"devicetoken"];
    }else{
        return;
    }
    [parameters setValue:@2 forKey:@"app_type"];
     NSLog(@"_%d_%@",__LINE__,parameters);
     NSLog(@"💥_%d_%@",__LINE__,registerID);
     NSLog(@"💥_%d_%@",__LINE__,deviceToken);
    NSString *url  =  @"Push";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:POST success:^(ResponseObject *response) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

//

//#pragma 这个接口要改, 添加一个类型参数
-(void)gotMobileCodeWithUser:(UserInfo*)user mobileCodeType:(MobileCodeType)type Success:(void(^)(ResponseStatus response))success failure:(void(^)(NSError*error))failure{
    [self initializationWithUser:user success:^(ResponseStatus response) {
        
        NSDictionary * parameters = @{
                               @"mobile":user.mobile,
                               @"type":@(type)//1注册2找回密码
                               };
        NSString * url = @"ShortMessage";
        [self remoteLoadDataWithUrl:url Parameters:parameters actionType:POST success:^(ResponseObject *response) {
//            LOG(@"_%@_%d_%@",[self class] , __LINE__,response.msg)
            success(response.status);
        } failure:^(NSError *error) {
            failure(error);
        }];
    } failure:^(NSError *error) {
        failure(error);
    }];
}
-(void)loginWithUser:(UserInfo *)user success:(void (^)(ResponseStatus response))success failure:(void (^)(NSError *))failure{//这个成功回调值有两种可能
    
        NSDictionary * parameters = @{
                               @"username": user.name,
                               @"password": user.password
                               };
        NSString * url =   @"Login";
    
        [self remoteLoadDataWithUrl:url Parameters:parameters actionType:POST success:^(ResponseObject *response) {
            if (response.status>0 ) {
                
                LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data)
                NSString * result =  response.data;
                user.member_id = result ;
                [self gotPersonalInfWithUser:user success:^(ResponseStatus response) {
                    [[GDXmppStreamManager ShareXMPPManager]loginWithJID:[XMPPJID jidWithUser:user.imName domain:JabberDomain resource:@"iOS"] passWord:user.token];
                } failure:^(NSError *error) {
                    failure(error);
                }];
                [self gotShopingCarWithUser:user success:^(ResponseStatus response) {
                    
                } failure:^(NSError *error) {
                     failure(error);
                }];
                
                
                
//                [[GDXmppStreamManager ShareXMPPManager]loginWithJID:[XMPPJID jidWithUser:user.imName domain:@"jabber.zjlao.com" resource:@"iOS"] passWord:user.token];
            }
            success(response.status);//登录成功回调
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSUCCESS object:nil];
        } failure:^(NSError *error) {
              failure(error);
        }];
}

-(void)gotPersonalInfWithUser:(UserInfo *)user success:(void (^)(ResponseStatus response))success failure:(void (^)(NSError *))failure{
    
    NSDictionary * parameters = @{
                           @"member_id":user.member_id
                           };
    NSString * url =  @"UserInfo";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
//        if (response.status==GET_USERINFO_SUCESS) {
        LOG(@"_%@_%d_获取的个人信息\n%@\n",[self class] , __LINE__,response.msg);
    if (response.status>0) {
        NSArray * arr = response.data;
            NSDictionary * result = arr.firstObject;
            [user setValuesForKeysWithDictionary:result];
            user.password = nil;
            [user save];
        }
        success(response.status);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma mark 注释: 腾讯云文件上传签名
-(void)gotTencentYunSign:(UserInfo*)user Success:(void(^)(ResponseObject *response))success failure:(void(^)(NSError*error))failure{
    NSDictionary * parameters = @{};
    LOG(@"_%@_%d_%@",[self class] , __LINE__,parameters);
    //http://api.zjlao.com/V2/Autograph/auth
    NSString*url =  @"Autograph/auth";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma mark 注释: 获取历史消息
-(void)gotHistoryMessage:(UserInfo*)user from:(NSString*)from to:(NSString*)to messageID:(NSString*)messageID Success:(void(^)(ResponseObject *response))success failure:(void(^)(NSError*error))failure{
//POST: http://api.zjlao.com/V2/MessageRoaming/rest
    if (!from || !to ) {
        GDlog(@"获取历史消息时 , 有参数为空")
        return;
    }
    NSString * tempMsgID = messageID;
    NSDictionary * parameters = nil ;
    
    if ( !messageID || messageID.length < 5) {
        
        parameters = @{
                       @"username":from ,
                       @"bare_peer":to
                       };
    }else{

         parameters = @{
                      @"username":from ,
                      @"bare_peer":to ,
                      @"ID":tempMsgID
                      };
    }
    GDlog(@"请求消息历史的参数%@",parameters)
    //http://api.zjlao.com/V2/Autograph/auth
    NSString*url =  @"MessageRoaming";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
        GDlog(@"|%@" , response.data)
    } failure:^(NSError *error) {
        failure(error);
    }];
    

}
#pragma 购物车操作
/** 添加购物车 */
-(void)addShopingCarWithUser:(UserInfo*)user goods_id:(NSString *)goods_id goodsNum:(NSInteger)num sub_id:(NSInteger)sub_id now:(NSString *)now Success:(void(^)(ResponseObject *response))success failure:(void(^)(NSError*error))failure{
    
        NSDictionary * parameters = @{
                               @"member_id":user.member_id,
                               @"goods_id":goods_id,
                               @"num":@(num),
                               @"spec":@(sub_id),
                               @"now":now
                               };
    LOG(@"_%@_%d_%@",[self class] , __LINE__,parameters);
        NSString*url =  @"ShopCart";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:POST success:^(ResponseObject *response) {
//        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.msg)
        if (response.status>0) {
             [[NSNotificationCenter defaultCenter] postNotificationName:SHOPCARDATACHANGED object:nil];
        }
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
/** 获取购物车数据 */
-(void)gotShopingCarWithUser:(UserInfo*)user  success:(void(^)(ResponseStatus response))success failure:(void(^)(NSError*error))failure{

    NSDictionary * parameters = @{
                           @"member_id":user.member_id
                           };
    NSString * url = @"ShopCart" ;
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        //获取购物车商品信息
        
        if (response.status > 0 &&response.data!=nil && [response.data isKindOfClass:[NSDictionary class]]) {
            LOG(@"_%@_%d_%@",[self class] , __LINE__,response.msg)
            LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
            id goodsnumObject =response.data[@"goodsnum"];
            if ([goodsnumObject isKindOfClass:[NSNumber class]]) {
               user.shoppingCarGoodsCount = [goodsnumObject integerValue];
            }
            NSMutableArray * shopS = [NSMutableArray array];
            for (int i = 0 ;  i< [response.data[@"list"] count]; i++) {
                NSDictionary * shopDict = response.data[@"list"][i];
                SVCShop * shopModel =  [[SVCShop alloc] initWithDict:shopDict];
                NSMutableArray * goodses = [NSMutableArray array];
                for (int j  = 0 ;  j <shopModel.list.count ;  j ++) {
                    NSMutableArray * sub_itemsArrM = [NSMutableArray array];
                    NSDictionary * goodsDict = shopModel.list[j];
                    if ([goodsDict[@"sub_items"] isKindOfClass:[NSArray class]] && [goodsDict[@"sub_items"] count] >0) {
                        NSArray * sub_items  = goodsDict[@"sub_items"];
                        for (int i = 0 ; i<sub_items.count; i++) {
                            if ([sub_items[i] isKindOfClass:[NSDictionary class]]) {
                                SpecModel * specModel = [[SpecModel alloc]initWithDict:sub_items[i]];
                                [sub_itemsArrM addObject:specModel];
                            }
                        }
//                        [goodsDict setValue:sub_itemsArrM forKey:@"sub_items"];
                    }
                    
                    
                    SVCGoods * goods =    [[SVCGoods alloc]initWithDict:goodsDict];
                    goods.sub_items = sub_itemsArrM;
                    [goodses  addObject:goods];
                }
                shopModel.list = goodses;
                NSMutableArray * shopCoupons = [NSMutableArray array];
                for (int j  = 0 ;  j <shopModel.coupons.count ;  j ++) {
                    NSDictionary * goodsDict = shopModel.coupons[j];
                    ShopCoupon * shopCoupon =    [[ShopCoupon alloc]initWithDict:goodsDict];
                    [shopCoupons  addObject:shopCoupon];
                }
                shopModel.coupons = shopCoupons;
                [shopS addObject:shopModel];
            }
            user.shoppingCarData=shopS;
        }else{
            user.shoppingCarData=nil;
        }
        success(response.status);//再在tableView的控制器判断状态码 做出相应的操作   成功的话刷新tableView
    } failure:^(NSError *error) {
        user.shoppingCarData=nil;;;;;;;;;;;;;
        failure(error);
        LOG(@"_%@_%d_%@",[self class] , __LINE__,error)
    }];
}
/**获取购物车数量*/
- (void)gotShopCarNumberWithUser:(UserInfo *)user Success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"ShopCartNumber";
    NSDictionary *paramete = @{};
    [self remoteLoadDataWithUrl:url Parameters:paramete actionType:GET success:^(ResponseObject *response) {
         NSLog(@"\n\n\n\n\n\n_%d_%@\n\n\n\n\n\n\n\n",__LINE__,response.data);
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 删除购物车 */
-(void)deleteShopingCarWithUser:(UserInfo *)user goodsID:(NSInteger)goodsID success:(void (^)(ResponseStatus response))success failure:(void (^)(NSError *))failure{
    
    NSDictionary * parameters = @{
                           @"member_id":user.member_id,
                           @"_method":@"delete",
                           @"select_id":@(goodsID)
//                           @"id":@(goodsID)
                           };
    NSString * url = @"ShopCart" ;
    LOG(@"_%@_%d_%ld",[self class] , __LINE__,goodsID);
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:POST success:^(ResponseObject *response) {
        if (response.status>0) {
             [[NSNotificationCenter defaultCenter] postNotificationName:SHOPCARDATACHANGED object:nil];
        }
        success(response.status);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 更改购物车商品数量 */
-(void) changeCountOfGoodsInShopingCarWithUser:(UserInfo*)user goodsId:(NSUInteger)goodsId goodsNum:(NSUInteger)goodsNum success:(void(^)(ResponseObject *response))success failure:(void(^)(NSError*error))failure{
    NSDictionary * parameters = @{
                                  @"member_id":user.member_id,
                                  @"number":@(goodsNum),
                                  @"id":@(goodsId),
                                  @"_method":@"put"
                                  };
    NSString * url = @"ShopCart" ;
    LOG(@"_%@_%d_%ld",[self class] , __LINE__,goodsId);

    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:POST success:^(ResponseObject *response) {
        success(response);
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.msg)
    } failure:^(NSError *error) {
        failure(error);
    }];

}

/** 确认订单接口 , 商品id通过字符串的形式传递给goods_id 字段  多个goodsid就用 , 连接 */
-(void)confirmOrderWithUser:(UserInfo*)user goodsId:(NSString*)goodsId addressID:(NSString*)addressID success:(void(^)(ResponseObject *response))success failure:(void(^)(NSError*error))failure{
    LOG(@"_%@_%d_%@",[self class] , __LINE__,goodsId)
    NSDictionary * parameters =nil ;
    if (addressID) {
         parameters = @{
                                      @"member_id":user.member_id,
                                      @"select_id":goodsId,
                                      @"address_id":addressID
                                      };
    }else{
         parameters = @{
                                      @"member_id":user.member_id,
                                      @"select_id":goodsId,
                                      };
    }

    NSString * url = @"ConfirmOrder" ;

    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}
//TODO
/** 首页点击进入获取优惠券 */
-(void)gotCouponsDataWithUser:(UserInfo*)user  pageNum:(NSUInteger)pageNum price_id:(NSUInteger)price_id classify_id:(NSUInteger)classify_id  success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
LOG(@"_%@_%d_%ld",[self class] , __LINE__,pageNum);
LOG(@"_%@_%d_%ld",[self class] , __LINE__,price_id);
LOG(@"_%@_%d_%ld",[self class] , __LINE__,classify_id);
    NSDictionary * parameters = @{
                                  @"member_id":user.member_id,
                                  @"price_id":@(price_id),
                                  @"classify_id":@(classify_id),
                                  @"page":@(pageNum)
                                  };
    NSString * url = @"Coupons" ;
    /** GET: http://api.zjlao.com/Coupons&a=rest */
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        LOG(@"_%@_%d_%d",[self class] , __LINE__,response.status);
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    

}
#pragma mark -- 厂家直销页面
- (void)gotFactorySellWithUser:(UserInfo *)user success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"DirectDeail";
    [self remoteLoadDataWithUrl:url Parameters:nil actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma mark -- 女婴管
- (void)gotBabyWithUser:(UserInfo *)user success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"Baby";
    [self remoteLoadDataWithUrl:url Parameters:nil actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}
#pragma mark -- 特许经营
- (void)gotFranchiseWithUser:(UserInfo *)user succss:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"Franchise";
    [self remoteLoadDataWithUrl:url Parameters:@{} actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark -- 超市
- (void)gotSuperMarketWithUser:(UserInfo *)user succss:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"superMarket";
    [self remoteLoadDataWithUrl:url Parameters:@{} actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma mark -- 超市分类
- (void)gotSuperMarketClassisyWithUser:(UserInfo *)user success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"SupMarketClassfy";
    [self remoteLoadDataWithUrl:url Parameters:@{} actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
- (void)gotSuperMarketThreeLevelClassisyWithUser:(UserInfo *)user andClassID:(NSUInteger)classID channel_id:(NSString *)channel_id success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"SupMarketSubClassfy";
    [self remoteLoadDataWithUrl:url Parameters:@{@"class_id":@(classID),@"channel_id":channel_id} actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark -- 电器城
- (void)gotHomeAppliancesCenterWithUser:(UserInfo *)user succss:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"EA";
    [self remoteLoadDataWithUrl:url Parameters:@{} actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}


#pragma 商品收藏操作
-(void)addGoodsFavoriteWithUser:(UserInfo*)user goods_id:(NSString *)goods_id   Success:(void(^)(ResponseObject *))success failure:(void(^)(NSError*))failure{
    NSDictionary * parameters = @{
                           @"member_id":user.member_id,
                           @"goods_id":goods_id
                           };
    NSString * url = @"GoodsCollect"  ;
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:POST success:^(ResponseObject *response) {
        if (response.status==POST_GOODS_COLLECT_SUCESS) {
            //收藏成功 , tips详细状态码已被服务器端启用 用正负来标识成功与否
        }
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
-(void)gotGoodsFavoriteWithUser:(UserInfo*)user  success:(void(^)(ResponseObject* response))success failure:(void(^)(NSError*error))failure{
    NSLog(@"%@, %d ,%@",[self class],__LINE__,user.member_id);

    NSDictionary * parameters = @{
                           @"member_id":user.member_id
                           };
    NSString*url =  @"GoodsCollect"  ;
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
/**判断店铺是否收藏*/
- (void)judgeShopIsCollectionWithUser:(UserInfo *)user shopID:(NSString *)shopID success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
     LOG(@"%d,%@",__LINE__,user.member_id)
    NSDictionary *paramete =@{@"member_id":user.member_id,
                              @"shop_id":shopID
                              };
    NSString *url = @"IsShopCollect";
    [self remoteLoadDataWithUrl:url Parameters:paramete actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
/**咨询与反馈*/
- (void)gotAskAndFeedWithUser:(UserInfo *)user success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"MyAdvice";
    NSDictionary *paramete = @{};
    [self remoteLoadDataWithUrl:url Parameters:paramete actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
/**体验问题*/
- (void)gotFeedBackDataWithUser:(UserInfo *)user Success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSDictionary *dic = @{@"did":UUID};
    NSString *url = @"Feedback";
    [self remoteLoadDataWithUrl:url Parameters:dic actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
/**获得体验问题*/
- (void)postFeedBackDataWithUser:(UserInfo *)userInfo questionType:(NSString *)questionType questionDesc:(NSString *)questionDesc Success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"Feedback";
    NSDictionary *paramete = @{@"did":UUID,
                               @"questionType":questionType,
                               @"questionDesc":questionDesc};
    [self remoteLoadDataWithUrl:url Parameters:paramete actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}



/**投诉问题*/
- (void)gotComplaintDataWithUser:(UserInfo *)user Success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSDictionary *paramete = @{@"did":UUID};
    NSString *url = @"Complaint";
    [self remoteLoadDataWithUrl:url Parameters:paramete actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}



/**判断商品是否添加收藏*/
- (void)judgeGoodsIsCollectionWithUser:(UserInfo *)user GoodsID:(NSString *)goodsID success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSDictionary *paramete =@{@"member_id":user.member_id,
                              @"goods_id":goodsID
                              };
    NSString *url = @"IsGoodsCollect";
    [self remoteLoadDataWithUrl:url Parameters:paramete actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
-(void)deleteGoodsFavoriteWithUser:(UserInfo*)user  goodsID:(NSString *)goodsID success:(void(^)(ResponseStatus response))success failure:(void(^)(NSError*error))failure{
    NSDictionary * parameters = @{
                           @"member_id":user.member_id,
                           @"_method":@"delete",
                           @"goods_id":goodsID
                           };
    NSString* url =   @"GoodsCollect" ;
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:POST success:^(ResponseObject *response) {
        success(response.status);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma 店铺收藏操作

-(void)addShopFavoriteWithUser:(UserInfo*)user shop_id:(NSString *)shop_id   Success:(void(^)(ResponseObject*))success failure:(void(^)(NSError*error))failure{
    NSDictionary * parameters = @{
                           @"member_id":user.member_id,
                           @"shop_id":shop_id
                           };
    NSString*url = @"ShopCollect" ;
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
-(void)gotShopFavoriteWithUser:(UserInfo*)user  success:(void(^)(ResponseObject* response))success failure:(void(^)(NSError*error))failure{
    NSDictionary * parameters = @{
                           @"member_id":user.member_id
                           };
    NSString * url = @"ShopCollect" ;
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

-(void)deleteShopFavoriteWithUser:(UserInfo*)user  shop_id:(NSString *)shop_id success:(void(^)(ResponseStatus response))success failure:(void(^)(NSError*error))failure{
    NSDictionary * parameters = @{
                           @"member_id":user.member_id,
                           @"shop_id":shop_id,
                           @"_method":@"delete"
                           };
    NSString * url = @"ShopCollect";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:POST success:^(ResponseObject *response) {
        success(response.status);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma 获取所有分类
-(void)gotClassifyWithUser :(UserInfo*)user success:(void(^)(ResponseObject * response))success failure:(void(^)(NSError*error))failure{
    NSDictionary * Parameters = @{};
    NSString * url =@"GoodsClassfy";
    
    [self remoteLoadDataWithUrl:url Parameters:Parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

#pragma 获取子分类
-(void)gotSubClassifyWithUser :(UserInfo*)user andClassID:(NSUInteger)classID success:(void(^)(ResponseObject* response))success failure:(void(^)(NSError*error))failure{
    NSDictionary * Parameters = @{
                                  @"class_id": @(classID)
                                  };

    NSString * url =@"GoodsSubClass";

    [self remoteLoadDataWithUrl:url Parameters:Parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma mark -- 获取商品列表
- (void)gotListOfGoodsWithUser:(UserInfo *)user classID:(NSInteger)classID pageNumber:(NSInteger)pageNuber sort:(NSInteger)sort sortOrder:(NSString *)sortOrder success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    
    NSDictionary *parameters = @{
                                 @"by":sortOrder,
                                 @"cat_id":@(classID),
                                 @"order":@(sort),
                                 @"page":@(pageNuber)
                                 };
    NSString *url = @"GoodsList";
    
   
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}



#pragma 获取商品详情
-(void)gotGoodsDetailDataWithUser:(UserInfo*)user goodsID:(NSString *)goodsID success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    NSDictionary * Parameters = @{
                                  @"goods_id": goodsID
                                  };

    NSString * url =@"GoodsItem";
    [self remoteLoadDataWithUrl:url Parameters:Parameters actionType:GET success:^(ResponseObject *response) {
        success(response);

    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma mark -- 获取商品详情页面的评价
- (void)gotEvaluateOfGoodsWithUser:(UserInfo *)user goodsID:(NSString *)goodsID evluation:(NSInteger)evluate  page:(NSInteger)page success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSDictionary *parameters = @{@"goods_id":goodsID,
                                @"search":@(evluate),
                                 @"page":@(page)};
    NSString *url = @"GoodsComment";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}
#pragma mark -- 商品详情页面
- (void)gotProductDetailWithUser:(UserInfo *)user goodID:(NSString *)goodID success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"GoodsDetail";
    NSDictionary *parameters = @{@"goods_id":goodID};
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma  mark -- 看了又看页面
- (void)gotProdectSeeAndSeeWithUser:(UserInfo *)user GoodID:(NSString *)goodID page:(NSInteger)page success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"LookAgain";
    NSDictionary *paramters = @{@"goods_id":goodID,
                                @"page":@(page)};
    [self remoteLoadDataWithUrl:url Parameters:paramters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma mark -- 添加商品足迹
- (void)addGoodsFootmarkWithUser:(UserInfo *)user member_id:(NSString*)member_id cat_id:(NSInteger)cat_id goods_id:(NSInteger)goods_id success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSDictionary *paramete = @{@"member_id":user.member_id,@"cat_id":@(cat_id),@"goods_id":@(goods_id)};
    NSString *url = @"GoodsFoot";
    [self.mar POST:url parameters:paramete progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        LOG(@"%@,%d,%@",[self class], __LINE__,@"商品足迹上传成功")
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        LOG(@"%@,%d,%@",[self class], __LINE__,@"商品足迹上传失败")
    }];
}

#pragma mark -- 获取商品规格
- (void)gotGoodsSpecWithUser:(UserInfo *)user goods_id:(NSString *)goodID succes:(void (^)(ResponseObject *))succes failure:(void (^)(NSError *))failure{
    NSString *url = @"SelectSpec";
    NSDictionary *paramete = @{@"goods_id":goodID};
    [self remoteLoadDataWithUrl:url Parameters:paramete actionType:GET success:^(ResponseObject *response) {
        succes(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}




#pragma 店铺首页

-(void)gotShopDetailDataWithUser:(UserInfo*)user shopID:(NSString *)shopID success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    LOG(@"_%@_%d_%@",[self class] , __LINE__,shopID);
    NSDictionary * Parameters = @{
                                  @"shop_id": shopID
                                  };
    
    NSString * url =@"myShop";
    [self remoteLoadDataWithUrl:url Parameters:Parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma mark -- 全部商品接口
- (void)gotShopShangXinWithUser:(UserInfo *)user storeID:(NSString *)storeID sort:(NSInteger)sort sortOrder:(NSString *)sortOrder pageNumber:(NSInteger)pageNumber success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"SearchShopNew";
    NSDictionary *parameters = @{@"shop_id":storeID,
                                 @"order":@(sort),
                                 @"by":sortOrder,
                                 @"page":@(pageNumber)
                                 };
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (void)gotShopAllGoodsWithUser:(UserInfo *)user storeID:(NSString *)storeID sort:(NSInteger)sort sortOrder:(NSString *)sortOrder pageNumber:(NSInteger)pageNumber success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSDictionary *parameters = @{@"shop_id":storeID,
                                 @"order":@(sort),
                                 @"by":sortOrder,
                                 @"page":@(pageNumber)
                                 };
    NSString *url = @"MyAllGoods";
    //    url = [self.midPath stringByAppendingString:url];
    //    url = [url stringByAppendingString:self.endPath];
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma mark -- 店铺全部分类接口
- (void)gotShopAllClassDataWithUser:(UserInfo *)user shopID:(NSInteger)shopID success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSDictionary *parameters =@{@"shop_id":@(shopID)};
    NSString *url = @"ShopClassify";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
/**全部分类查询*/
- (void)gotShopGoodsDataWithUser:(UserInfo *)user classID:(NSString *)classID sort:(NSInteger)sort sortOrder:(NSString *)sortOrder pageNumber:(NSInteger)pageNumber success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    
    NSDictionary *parameters = @{@"id":classID,
                                 @"order":@(sort),
                                 @"by":sortOrder,
                                 @"page":@(pageNumber)
                                 };
    NSString *url = @"ShopClassify2Goods";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark -- 店铺故事
- (void)gotShopStoryDataWithUser:(UserInfo *)user shopID:(NSInteger)shopID success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSDictionary *paramete = @{@"shop_id":@(shopID)};
    NSString *url = @"shopStory";
    [self remoteLoadDataWithUrl:url Parameters:paramete actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma mark -- 店铺搜索
- (void)gotShopSearchDataWithUser:(UserInfo *)user shopID:(NSString *)shopID keyword:(NSString *)keyword page:(NSInteger)page sort:(NSInteger)sort sortOrder:(NSString*)sortOrdr success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSDictionary *parmaete =@{@"shop_id":shopID,@"keyword":keyword,@"page":@(page),@"order":@(sort),@"by":sortOrdr};
    NSString *ure = @"SearchShop";
    [self remoteLoadDataWithUrl:ure Parameters:parmaete actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
#pragma mark -- 店铺资质
- (void)gotShopAptiudeDataWithUwer:(UserInfo *)user shopID:(NSInteger)shopID success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"MyQuali";
    NSDictionary *paramete = @{@"shop_id":@(shopID)};
    [self remoteLoadDataWithUrl:url Parameters:paramete actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}


/** 获取个人中心数据 */
-(void)gotProfileDataWithUser:(UserInfo*)user success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://api.zjlao.com/V2/MyPage/rest */
    NSDictionary * parameters = @{
                                  @"member_id":user.member_id
                                  };
    NSString * url = @"MyPage";
    LOG(@"_%@_%d_通过这个memberiD获取个人信息%@",[self class] , __LINE__,parameters);
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}
/** 获取首页信息 */
-(void)gotHomeDataWithUser:(UserInfo*)user success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{

        NSDictionary * parameters = @{};
        NSString * url = @"NewIndex";
        
        [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
            success(response);
        } failure:^(NSError *error) {
            failure(error);
        }];
}

-(void)gotGuessLikeDataWithUser:(UserInfo*)user Channel_id:(NSString *)channel_id pageNum:(NSUInteger)pageNum success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    LOG(@"_%@_%d_%ld",[self class] , __LINE__,pageNum);
        NSDictionary * parameters = @{
                                      @"page":@(pageNum),
                                      @"channel_id":channel_id
                                      };
        NSString * url = @"GuessLike";
        [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
            success(response);
             NSLog(@"🍯🍅_%d_%@",__LINE__,response.data);
        } failure:^(NSError *error) {
            failure(error);
        }];
}
#pragma 捞便宜
-(void)gotLaoCheapDataWithUser:(UserInfo*)user  pageNum:(NSUInteger)pageNum  success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    NSString * url = @"LaoCheap";
    
    LOG(@"_%@_%d_%lu",[self class] , __LINE__,pageNum);
    NSDictionary * prama = @{@"page":@(pageNum)};
    [self remoteLoadDataWithUrl:url Parameters:prama actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma 捞故事
-(void)gotLaoStoryDataWithUser:(UserInfo*)user  pageNum:(NSUInteger)pageNum  success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{

    LOG(@"_%@_%d_%ld",[self class] , __LINE__,pageNum);
    NSString * url = @"LaoStory";
    NSDictionary * prama = @{@"page":@(pageNum)};
    [self remoteLoadDataWithUrl:url Parameters:prama actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 获取首页个体自产数据 */
-(void)gotIndividualDataWithUser:(UserInfo*)user success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /**
     GET: http://www.zjlao.com/Single&a=rest
     */
    NSDictionary * parame = @{};
    NSString * url = @"Single";
    
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}

/** 获取首页田园牧歌数据 */
-(void)gotCountrysideDataWithUser:(UserInfo*)user success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://api.zjlao.com/V2/Countryside/rest*/
    NSDictionary * parame = @{};
    NSString * url = @"Countryside";
    
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

/** 获取首页民族兄弟数据 */
-(void)gotNationalDataWithUser:(UserInfo*)user success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://api.zjlao.com/V2/National/rest */
    NSDictionary * parame = @{};
    NSString * url = @"National";
    
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}


/** 领取优惠券 */
-(void)gotCouponsWithUser:(UserInfo*)user  couponsID:(NSString*)couponsID   success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /**
     POST: http://www.zjlao.com/CouponsTake&a=rest
     */
    NSDictionary * parame = @{
                              @"member_id":user.member_id,
                              @"cid":couponsID
                              };
    NSString * url = @"CouponsTake";
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}


/** 获取优惠券详情数据 */
-(void)gotCouponsDetailDataWithUser:(UserInfo*)user  couponsID:(NSUInteger)couponsID   success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{

    /**
     GET: http://www.zjlao.com/CouponsDetail&a=rest
     */
    NSDictionary * parame = @{
                              @"cid":@(couponsID),
                              @"member_id":user.member_id
                              };
    NSString * url = @"CouponsDetail";
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}

/** 全站搜索商品 */
-(void)searchGoodsInGlobleWithUser:(UserInfo*)user keyWord:(NSString*)keyWord  order:(NSUInteger)order sortOrder:(NSString *)sortOrder pageNum:(NSUInteger)pageNum channel_id:(NSString *)channel_id success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    /**
     GET: http://www.zjlao.com/SearchSite&a=rest
     */
    LOG(@"_%@_%d_搜索商品的关键词是:-> %@",[self class] , __LINE__,keyWord);
    NSDictionary * parame=nil;
    if (keyWord) {

         parame = @{
                                  @"keyword":keyWord,
                                  @"order":@(order),
                                  @"page":@(pageNum),
                                  @"by":sortOrder,
                                  @"channel_id":channel_id
                                  };
    
    }else{
    
        parame=@{};
    }
    
    NSString * url = @"SearchSite";
    
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 搜索页（热、历史） */
-(void)gotSearchPageDataWithUser:(UserInfo*)user    success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /**
     GET: http://www.zjlao.com/SearchSite&a=rest
     */
    NSDictionary * parame = @{};
    
    NSString * url = @"SearchPage";
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}
/** 消息中心接口 */
-(void)gotMessageCenterDataWithUser:(UserInfo*)user  success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://www.zjlao.com/index.php?&m=Api&c=V2/MessageCenter
 */
    NSString * url = @"MessageCenter";
    NSDictionary * parame = @{
                              @"member_id":user.member_id
                              };
    
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 提交订单后 , 查看订单商品列表 */
-(void)gotOrderGoodsDetailWithUser:(UserInfo*)user goodsID:(NSString*)goodsID addressID:(NSString*)addressID success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    // POST: http://www.zjlao.com/ConfirmGoodsList
    NSDictionary *parameters = nil;
    if (addressID) {
            parameters = @{@"select_id":goodsID,@"member_id":user.member_id ,@"address_id":addressID};
    }else{
            parameters = @{@"select_id":goodsID,@"member_id":user.member_id};
    }
    LOG(@"_%@_%d_%@",[self class] , __LINE__,goodsID);
    NSString *url = @"ConfirmGoodsList";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}

/** 提交订单后 , 查看订单商品对应的优惠券 */
-(void)gotOrderCouponseListWithUser:(UserInfo*)user goodsID:(NSString*)goodsID success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://www.zjlao.com/OrderCoupons */
    NSDictionary *parameters = @{@"select_id":goodsID,@"member_id":user.member_id};
    NSString *url = @"OrderCoupons";
    [self remoteLoadDataWithUrl:url Parameters:parameters actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 生成订单 */
-(void)creatOrderWithUserInfo:(UserInfo*)user goods_ID:(NSString*)goodsID payMent:(NSString*)payment shipingType:(NSString*)shipingType invoiceOrNot:(NSString*)invoice couponsIDs:(NSString*)couponsIDs LBCount:(NSString*)lbCount addressID:(NSString*)addressID  success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** POST: http://www.zjlao.com/Order */
    NSString * url = @"Order";
    
    LOG(@"_%@_%d_%@",[self class] , __LINE__,goodsID);
    LOG(@"_%@_%d_%@",[self class] , __LINE__,payment);
    LOG(@"_%@_%d_%@",[self class] , __LINE__,invoice);
    LOG(@"_%@_%d_%@",[self class] , __LINE__,couponsIDs);
    LOG(@"_%@_%d_%@",[self class] , __LINE__,lbCount);
    LOG(@"_%@_%d_%@",[self class] , __LINE__,addressID);
    NSDictionary * parame = @{
                              @"member_id":user.member_id,
//                              @"goods_id":goodsID,
                              @"select_id":goodsID,
                              @"payment":payment,
                              @"shipping": @"",
                              @"invoice":invoice ,
                              @"coupons":couponsIDs ,
                              @"Lcoins": lbCount,
                              @"num":@"",
                              @"address_id":addressID
                              };
    
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        if (response.status>0) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SHOPCARDATACHANGED object:nil];
        }
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}

/** 获取订单详情 */
-(void)gotOrderDetailWithUser:(UserInfo*)user orderID:(NSString*)orderID success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://www.zjlao.com/Order */
    NSString * url = @"Order";
    NSDictionary * parame = @{
                              @"member_id":user.member_id,
                              @"order_id":orderID
                              };
    
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/**取消订单*/
- (void)cancleOrderWithUser:(UserInfo *)user orderID:(NSString *)orderID success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
    NSString *url = @"DeleteOrder";
    if (!orderID) return;
    NSDictionary *dic = @{@"member_id":user.member_id,
                          @"order_id":orderID,
                          @"_method":@"delete"};
    [self remoteLoadDataWithUrl:url Parameters:dic actionType:POST success:^(ResponseObject *response) {
        LOG(@"%@,%d,%@",[self class], __LINE__,@"取消订单成功")
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
//    [self.mar POST:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        LOG(@"%@,%d,%@",[self class], __LINE__,@"取消订单成功")
//        success(responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        failure(error);
//    } ];
}

/** 获取地址列表 */
//GET: http://www.zjlao.com/GetAddressList
/** 获取地址列表 */

-(void)gotAddressWithUser:(UserInfo*)user success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    NSString * url = @"GetAddressList";
    NSDictionary * parame = @{
                              @"member_id":user.member_id
                              };
    
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 新建收货地址 */
-(void)creatNewAddressWithUser:(UserInfo *)user addressModel:(AMCellModel*)addressModel  success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** POST: http://www.zjlao.com/Address
 */
    NSString * url = @"Address";
//    LOG(@"_%@_%d_%@",[self class] , __LINE__,[NSString stringWithFormat:@"%@%@%@",addressModel.country,addressModel.province,addressModel.city]);
    LOG(@"_%@_%d_%@",[self class] , __LINE__,addressModel.area_id);
    NSDictionary * parame=nil ;
    if (addressModel.id_number.length > 0 ) {
        parame = @{
                   @"member_id":user.member_id,
                   @"id_number":addressModel.id_number,
                   @"username":addressModel.username,
                   @"mobile": addressModel.mobile,
                   @"area":[NSString stringWithFormat:@"%@",addressModel.area] ,
                   @"address":addressModel.address ,
                   @"default": @(addressModel.isDefaultAddress),
                   @"area_id":addressModel.area_id
                   };

    }else{
    
        parame = @{
                   @"id_number":@"",
                   @"member_id":user.member_id,
                   @"username":addressModel.username,
                   @"mobile": addressModel.mobile,
                   @"area":[NSString stringWithFormat:@"%@",addressModel.area] ,
                   @"address":addressModel.address ,
                   @"default": @(addressModel.isDefaultAddress),
                   @"area_id":addressModel.area_id
                   };
    }
    
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}
/** 修改收货地址 */
-(void)editAddressWithUser:(UserInfo *)user addressModel:(AMCellModel*)addressModel success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    NSString * url = @"Address";
    LOG(@"_%@_%d_%@%@%@%@%@",[self class] , __LINE__,addressModel.username,addressModel.mobile,addressModel.area,addressModel.ID,addressModel.address);
    NSDictionary * parame=nil ;
    if (addressModel.id_number.length > 0 ) {
        parame = @{
                   @"id_number":addressModel.id_number,
                   @"member_id":user.member_id,
                   @"username":addressModel.username,
                   @"mobile": addressModel.mobile,
                   @"area":[NSString stringWithFormat:@"%@",addressModel.area] ,
                   @"address":addressModel.address ,
                   @"default": @(addressModel.isDefaultAddress),
                   @"id":addressModel.ID,
                   @"area_id":addressModel.area_id,
                   @"_method":@"put"
                   };

    }else{
    
        parame = @{
                   @"id_number":@"",
                   @"member_id":user.member_id,
                   @"username":addressModel.username,
                   @"mobile": addressModel.mobile,
                   @"area":[NSString stringWithFormat:@"%@",addressModel.area] ,
                   @"address":addressModel.address ,
                   @"default": @(addressModel.isDefaultAddress),
                   @"id":addressModel.ID,
                   @"area_id":addressModel.area_id,
                   @"_method":@"put"
                   };
    }
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 删除收货地址 */
-(void)deleteAddressWithUser:(UserInfo *)user addressModel:(AMCellModel*)addressModel success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
//POST: http://www.zjlao.com/Address
    NSString * url = @"Address";

    LOG(@"_%@_%d_%@",[self class] , __LINE__,addressModel.ID);
    NSDictionary * parame = @{
                              @"member_id":user.member_id,
                              @"_method": @"delete",
                              @"address_id":addressModel.ID
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 设置为默认地址 */
-(void)setDefaultAddressWithUser:(UserInfo *)user addressModel:(AMCellModel*)addressModel success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    //POST: http://www.zjlao.com/DefaultAddress
    
    NSString * url = @"DefaultAddress";
    
    NSDictionary * parame = @{
                              @"member_id":user.member_id,
                              @"_method": @"put",
                              @"address_id":addressModel.ID
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}
/** 获取国家列表 */
-(void)gotCountryListWithUser:(UserInfo*)user success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://www.zjlao.com/Country */

    NSString * url = @"Country";
    NSDictionary * parame = @{};
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}
/** 获取省份列表 */
-(void)gotProvinceListWithUser:(UserInfo*)user country_id:(NSString*)country_id success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://www.zjlao.com/Province */
    LOG(@"_%@_%d_国家id%@",[self class] , __LINE__,country_id);
    NSString * url = @"Province";
    NSDictionary * parame = @{
                              @"country_id":country_id
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}
/** 获取城市列表 */
-(void)gotCityListWithUser:(UserInfo*)user  province_id:(NSString*)province_id success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://www.zjlao.com/City */
    LOG(@"_%@_%d_城市id%@",[self class] , __LINE__,province_id);

    NSString * url = @"City";
    NSDictionary * parame = @{@"province_id": province_id};
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
/** 获取国省市区的总接口(改) */
-(void)gotAreaListWithUser:(UserInfo*)user  areaType:(int)areaType areaID:(NSString*)areaID success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://www.zjlao.com/Country */
//    if (!areaID) {
//        areaID=@"0";
//    }
    LOG(@"_%@_%d_地址类型是%d    地址id是%@",[self class] , __LINE__,areaType , areaID);
    NSString * url = @"Country";
    NSDictionary * parame = @{@"id":areaID,@"type":@(areaType)};
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 余额支付 */
-(void)payByBalanceWithUser:(UserInfo*)user orderID:(NSString*)orderID success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
//GET: http://www.zjlao.com/Balance
    NSString * url = @"Balance";
    LOG(@"_%@_%d_%@",[self class] , __LINE__,orderID);
    NSDictionary * parame = @{@"member_id":user.member_id,@"order_code":orderID};
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}

/** 支付宝订单信息rsa加密 */
/** 支付宝订单信息加密 */
-(void)encryptAlipayOrderDataWithUserInfo:(UserInfo*)user orderID:(NSString*)orderID success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
/** POST: http://www.zjlao.com/Rsa */
    
    NSString * url = @"Rsa";
    NSDictionary * parame = @{@"member_id":user.member_id,@"order_id":orderID};
    
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}
/** 验证支付宝支付结果 */
-(void)verifyAlipayResultWithUserInfo:(UserInfo*)user alipayResult:(NSString*)alipayResult success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
/**POST: http://www.zjlao.com/VerifyNotify*/
    NSString * url = @"VerifyNotify";
    NSDictionary * parame = @{@"member_id":user.member_id,@"data":alipayResult};
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}




/** 获取银联流水号tn */
-(void)gotUnionTnWithUserInfo:(UserInfo*)user orderInfo:(NSString*)orderInfo success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{

    NSString * url = @"Upmp";
    NSDictionary * parame = @{@"member_id":user.member_id,@"orderId":orderInfo};
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}
/**微信统一下单接口*/
- (void)gotWeiXinUniformOrderWithUser:(UserInfo *)user order_code:(NSString *)order_code Success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure {
    NSString *url = @"WXunifiedorder";
    NSLog(@"%@, %d ,%@",[self class],__LINE__,order_code);

    NSDictionary *paramete = @{@"member_id":user.member_id,
                               @"out_trade_no":order_code};
    [self remoteLoadDataWithUrl:url Parameters:paramete actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 检查用户名或者手机号或者邮箱是否已经被注册 以及验证码的有效性 */
-(void)checkUserNameOrMobileWithUserInfo:(UserInfo*)user userName:(NSString*)userName mobile:(NSString*)mobile email:(NSString*)email mobilecode:(NSString*)mobilecode success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    NSString * url = @"RegisterVerify";
    LOG(@"_%@_%d_%@",[self class] , __LINE__,userName);
    LOG(@"_%@_%d_%@",[self class] , __LINE__,mobile);
    LOG(@"_%@_%d_%@",[self class] , __LINE__,mobilecode);
    NSDictionary * parame = nil ;
    if (userName.length>0) {
//        parame = @{
//                   @"name":userName,
//                   @"mobile":[NSNull new],
//                   @"password":[NSNull new],
//                   @"mobilecode":[NSNull new]
//                   };
        parame = @{
                   @"name":userName
                   };
    }else if (mobile.length>0&& mobilecode.length==0){
        parame = @{@"mobile":mobile};
    }else if (mobilecode.length>0 &&mobile.length>0){
        parame = @{@"mobilecode":mobilecode,@"mbl":mobile};
        
    }else{
        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"出问题了");
    }
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
//POST: http://www.api.zjlao.com/RegisterVerify
    
}
/** 找回密码时 验证用户名是否存在 , 检查用户名时有返回值的,返回手机或者邮箱 跟上个方法属于同一个接口 , 为了明了分开写了*/
-(void)checkUserNameOrMobileWithUserInfo:(UserInfo*)user findbackname:(NSString*)findbackname findbackmobile:(NSString*)findbackmobile findbackemail:(NSString*)findbackemail  success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{

    NSString * url = @"RegisterVerify";
    LOG(@"_%@_%d_%@",[self class] , __LINE__,findbackname);
    LOG(@"_%@_%d_%@",[self class] , __LINE__,findbackmobile);
    LOG(@"_%@_%d_%@",[self class] , __LINE__,findbackemail);
    NSDictionary * parame = nil ;
    if (findbackname.length>0) {
        parame = @{
                   @"findbackname":findbackname
                   };
    }else if (findbackmobile.length>0){
        parame = @{@"findbackmobile":findbackmobile};
    }else if (findbackemail.length>0 ){
        parame = @{@"findbackemail":findbackemail};
    }else{
        LOG(@"_%@_%d_%@",[self class] , __LINE__,@"出问题了");
    }
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    //POST: http://www.api.zjlao.com/RegisterVerify

}
/** 通过用户名或者手机找回密码 , 改邮箱找回时  , 判断用户是否绑定邮箱 跟上个方法属于同一个接口 , 为了明了分开写了*/
-(void)gotEmaileWithUser:(UserInfo*)user byUsernameOrMobile:(NSString*)content success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** POST: http://api.zjlao.com/V2/RegisterVerify/rest */
    NSString * url = @"RegisterVerify";
    NSDictionary * parame = @{
                              @"findbindemail":content
                              } ;

    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
/** 修改个人信息 */
-(void)editUserInfo:(UserInfo*)user withNewUserInfo:(UserInfo*)newUserInfo success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** POST:http://api.zjlao.com/V2/UserInfo/rest */
    NSString * url = @"UserInfo";
//    NSDictionary * parame = @{
//                              @"_method":@"put",
//                              @"member_id":user.member_id
//                              };
    NSMutableDictionary * parame = [[NSMutableDictionary alloc]init];
    [parame setValue:@"put" forKey:@"_method"];
    [parame setValue:user.member_id forKey:@"member_id"];
    if (newUserInfo.birthday.length>0)[parame setValue:newUserInfo.birthday forKey:@"birthday"];
    
    if (newUserInfo.sex>0) [parame setValue:[NSString stringWithFormat:@"%ld",newUserInfo.sex] forKey:@"sex"];
    if (newUserInfo.nickname.length>0) [parame setValue:newUserInfo.nickname forKey:@"nickname"];

    LOG(@"_%@_%d_%@",[self class] , __LINE__,parame);
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}

/** 重置密码 */
-(void)resetPasswordWithUserInfo:(UserInfo*)user withAuthType:(NSString*)authType password:(NSString*)password success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** POST: http://api.zjlao.com/V2/Password/rest */
    NSString * url = @"Password";
    NSDictionary * parame = @{
                              @"newpassword":password,
                              @"mobile":authType
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:PUT success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
/** 设置图片质量模式 */
/**  0:waifai状态 1：非waifai状态*/
-(void)setupNetworkStatesWithUserInfo:(UserInfo*)user status:(NSUInteger)satus success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://api.zjlao.com/V2/InitWaiFai/rest */

    NSString * url = @"InitWaiFai";
    NSDictionary * parame = @{
                              @"wf":@(satus)//,
                              //  @"mobile":authType
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}
/** 获取当前账户余额 */
-(void)gotBanlanceWithUserInfo:(UserInfo*)user success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
/**GET: http://api.zjlao.com/V2/MyBalance/rest*/
    
    NSString * url = @"MyBalance";
    NSDictionary * parame = @{
                              @"member_id":user.member_id
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

/** 验证旧登录密码的正确性 */
-(void)checkOldLoginPasswordWithUser:(UserInfo*)user oldLoginPassword:(NSString*)oldLoginPassword success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
/**POST: http://api.zjlao.com/V2/CheckOldPwd/rest*/
    NSString * url = @"CheckOldPwd";
    NSDictionary * parame = @{
                              @"member_id":user.member_id,
                              @"oldpassword":oldLoginPassword
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST  success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    
}



/** 执行修改登录密码的正确性 */
-(void)changeNewLoginPasswordWithUser:(UserInfo*)user newLoginPassword:(NSString*)newLoginPassword success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    
    /** POST: http://api.zjlao.com/V2/ModifyLoginPwd/rest */
    NSString * url = @"ModifyLoginPwd";
    NSDictionary * parame = @{
                              @"member_id":user.member_id,
                              @"newpassword":newLoginPassword
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST  success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    

}

/** 验证旧支付密码的正确性 *///就不能合成一个接口吗 -_-!
-(void)checkOldPayPasswordWithUser:(UserInfo*)user oldPayPassword:(NSString*)oldPayPassword success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** POST: http://api.zjlao.com/V2/CheckBalancePwd/rest  */
    NSString * url = @"CheckBalancePwd";
    NSDictionary * parame = @{
                              @"member_id":user.member_id,
                              @"balancepwd":oldPayPassword
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST  success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 执行修改支付密码的正确性 */
-(void)changeNewPayPasswordWithUser:(UserInfo*)user newPayPassword:(NSString*)newPayPassword success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** POST: http://api.zjlao.com/V2/ModifyBalancePwd/rest  */
    NSString * url = @"ModifyBalancePwd";
    NSDictionary * parame = @{
                              @"member_id":user.member_id,
                              @"balancepwd":newPayPassword
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST  success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}


/** 获取国家编码 */
-(void)gotCountryNumberWithUser:(UserInfo*)user success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
/** POST: http://api.zjlao.com/V2 / CountryNumber/rest */
    NSString * url = @"CountryNumber";
    NSDictionary * parame = @{ };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST  success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];


}

/** 修改绑定手机 */

-(void)changeBoundMobileWithUser:(UserInfo*)user boundMobile:(NSString*)boundMobile success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{

    /** POST: http://api.zjlao.com/V2/ModifyBoundMobile/rest */
    NSString * url = @"ModifyBoundMobile";
    NSDictionary * parame = @{
                              @"newmobile":boundMobile,
                              @"member_id":user.member_id
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST  success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

    
}
/** 获取账户安全相关信息 */
-(void)gotAccountSafeWithUser:(UserInfo*)user success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
    /** GET: http://api.zjlao.com/V2/SafeAccount/rest */

    NSString * url = @"SafeAccount";
    NSDictionary * parame = @{ @"member_id":user.member_id};
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET   success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];

}

/** 通过邮箱找回密码 */
-(void)findPasswordBackByEmailWithUser:(UserInfo*)user email:(NSString*)email success:(void(^)(ResponseObject * responseObject))success failure:(void(^)(NSError*error))failure{
/** POST:http://api.zjlao.com/V2/FindPasswordEmail/rest */
    NSString * url = @"FindPasswordEmail";
    NSDictionary * parame = @{ @"email":email};
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST   success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}
/**获取全部订单*/
- (void)gotMyAllOrderWithUser:(UserInfo *)user Success:(void (^)(ResponseObject *))success failure:(void (^)(NSError *))failure{
//    NSString *url = @"MyAllOrder";
    
}
/** 检查版本 */
-(void)checkVersionSuccess:(void(^)(ResponseObject *responseObject))success failure:(void(^)(NSError *error))failure{
    /** GET: http://api.zjlao.com/V2/InitVersion/rest */
    NSString * url = @"InitVersion";
    NSDictionary * parame = @{};
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET   success:^(ResponseObject *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

/** 退出登录 */
-(void)loginOutWithUser:(UserInfo*)user success:(void(^)(ResponseObject *responseObject))success failure:(void(^)(NSError *error))failure{
    /** POST: http://api.zjlao.com/V2/LoginOut/rest */
    NSString * url = @"LoginOut";
        NSDictionary * parame = @{ @"member_id":user.member_id};
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST    success:^(ResponseObject *response) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
        [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:MESSAGECOUNTCHANGED];
        [[NSNotificationCenter defaultCenter]  postNotificationName:MESSAGECOUNTCHANGED object:nil];
        success(response);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}
/** (2,绑定手机)首次第三方登录时 验证手机号码 */
-(void)authorMobileAfterThirdPlayformWithUser:(UserInfo*)user mobile:(NSString*)mobile mobileCode:(NSString*)mobileCode accessToken:(NSString*)accessToken success:(void(^)(ResponseObject *responseObject))success failure:(void(^)(NSError *error))failure{
    /** POST: http://api.zjlao.com/V2/Author/rest */
    NSString * url = @"Author";
    if (!(mobile&&mobileCode&&accessToken)) {
        return;
    }
    NSDictionary * parame = @{
                              @"mobile":mobile,
                              @"mobilecode":mobileCode,
//                              @"accessToken":accessToken,
                              @"openId":accessToken
                               };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:POST   success:^(ResponseObject *response) {
        [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:MESSAGECOUNTCHANGED];
        [[NSNotificationCenter defaultCenter]  postNotificationName:MESSAGECOUNTCHANGED object:nil];
        success(response);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    

}


/** (1)第三方登录后,保存相关数据 source有三种 QQ sian weixin*/
-(void)saveThirdPlayromAccountInfomation:(UserInfo*)user openID:(NSString*)openID accessToken:(NSString*)accessToken source:(NSString*)source success:(void(^)(ResponseObject *responseObject))success failure:(void(^)(NSError *error))failure{
/** POST: http://api.zjlao.com/V2/Author/rest */
    if (!(openID&&source&&accessToken)) {
        return;
    }
    NSString * url = @"Author";
    
    NSDictionary * parame = @{
                              @"openId":openID,
                              @"source":source,
                              @"accessToken":accessToken
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET   success:^(ResponseObject *response) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
        [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:MESSAGECOUNTCHANGED];
        [[NSNotificationCenter defaultCenter]  postNotificationName:MESSAGECOUNTCHANGED object:nil];
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
        success(response);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}


-(void)saveThirdPlayromAccountInfomation:(UserInfo*)user andSnsAccount:(UMSocialAccountEntity *)snsAccount origenRespons:(UMSocialResponseEntity *)origenRespons success:(void(^)(ResponseObject *responseObject))success failure:(void(^)(NSError *error))failure{
    /** POST: http://api.zjlao.com/V2/Author/rest */
    NSString * url = @"Author";

    NSMutableDictionary * parame = [[NSMutableDictionary alloc]init];
    if (snsAccount.openId) {
        [parame setObject:snsAccount.openId forKey:@"openId"];
    }else if (snsAccount.usid){
        [parame setObject:snsAccount.usid forKey:@"openId"];
    }
    if (snsAccount.platformName) {
        [parame setObject:snsAccount.platformName forKey:@"source"];
    }
    if (snsAccount.accessToken) {
        [parame setObject:snsAccount.accessToken forKey:@"accessToken"];
    }

    
    
    NSMutableDictionary * info = [[NSMutableDictionary alloc]init];
    if (snsAccount.userName) {
        [info setObject:snsAccount.userName forKey:@"name"];
    }else{
         [info setObject:@"" forKey:@"name"];
    }
    if (snsAccount.iconURL) {
        [info setObject:snsAccount.iconURL forKey:@"headImage"];
    }else{
        [info setObject:@"" forKey:@"headImage"];
    }
    if ([origenRespons.thirdPlatformUserProfile isKindOfClass:[NSDictionary class]] && origenRespons.thirdPlatformUserProfile[@"birthday"]) {
        [info setObject:origenRespons.thirdPlatformUserProfile[@"birthday"] forKey:@"birthday"];
    }else{
        [info setObject:@"" forKey:@"birthday"];
    }
    if ([origenRespons.thirdPlatformUserProfile isKindOfClass:[NSDictionary class]] && origenRespons.thirdPlatformUserProfile[@"sex"]) {
        [info setObject:origenRespons.thirdPlatformUserProfile[@"sex"] forKey:@"sex"];
    }else if ([origenRespons.thirdPlatformUserProfile isKindOfClass:[NSDictionary class]] && origenRespons.thirdPlatformUserProfile[@"gender"]){
        [info setObject:origenRespons.thirdPlatformUserProfile[@"gender"] forKey:@"sex"];
    }else {
        [info setObject:@"" forKey:@"sex"];
    }
    
    
    
    [parame setObject:info.mj_JSONString forKey:@"info"];
    
    
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET   success:^(ResponseObject *response) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
        [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:MESSAGECOUNTCHANGED];
        [[NSNotificationCenter defaultCenter]  postNotificationName:MESSAGECOUNTCHANGED object:nil];
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
        success(response);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}


/** 支付宝支付结果处理 */
-(void)dealTheResultAfterAlipayWithUser:(UserInfo*)user payType:(NSString*)payType payResult:(NSString*)payResult success:(void(^)(ResponseObject *responseObject))success failure:(void(^)(NSError *error))failure{
/** POST: http://api.zjlao.com/V2/Pay/rest */
    
    NSString * url = @"Pay";
    
    NSDictionary * parame = @{
                              @"pay_type":@"1",
                              @"order_code":payResult
                              };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET   success:^(ResponseObject *response) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
        success(response);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}
/** 清楚足迹 */
-(void)clearFootHistoryWith:(UserInfo*)user success:(void(^)(ResponseObject *responseObject))success failure:(void(^)(NSError *error))failure{
    
    /** GET: http://api.zjlao.com/V2/CleanMyFoot/rest */
    NSString * url = @"CleanMyFoot";
    
    NSDictionary * parame =  @{
                                //@"member_id":user.member_id
                                };
    [self remoteLoadDataWithUrl:url Parameters:parame actionType:GET   success:^(ResponseObject *response) {
        LOG(@"_%@_%d_%@",[self class] , __LINE__,response.data);
        success(response);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}
@end

//
//  TWUpdateAppVersion.h
//  86YYZX
//
//  Created by apple on 2017/8/14.
//  Copyright © 2017年 jztw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWUpdateAppVersion : NSObject

@property (nonatomic, strong) NSDictionary *appVersionInfo;

+ (instancetype)shareInstance;

+ (void)hs_updateWithAPPID:(NSString *)appid block:(void(^)(NSString *currentVersion,NSString *storeVersion, NSString *openUrl,BOOL isUpdate))block;

@end
